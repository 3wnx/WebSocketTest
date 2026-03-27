-- RobloxClient.lua

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local LogService  = game:GetService("LogService")

-- ── Config ─────────────────────────────────────────────────────────────
local SERVER_IP     = "192.168.100.74"
local SERVER_PORT   = 9000
local WS_URL        = string.format("ws://%s:%d", SERVER_IP, SERVER_PORT)
local RETRY_DELAY   = 5

-- ── WebSocket ──────────────────────────────────────────────────────────
local ws
local connected = false

local function send(packet)
    if not (ws and connected) then return end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, packet)
    if ok then pcall(ws.Send, ws, encoded) end
end

-- ── LogService → WebSocket ──────────────────────────────────────────────
local LOG_TYPE_MAP = {
    [Enum.MessageType.MessageOutput]  = "Info",
    [Enum.MessageType.MessageWarning] = "Warning",
    [Enum.MessageType.MessageError]   = "Error",
    [Enum.MessageType.MessageInfo]    = "Info",
}

local function onLogMessage(msg, msgType)
    send({
        type = "Broadcast",
        value = HttpService:JSONEncode({
            type    = "Log",
            logType = LOG_TYPE_MAP[msgType] or "Info",
            value   = msg,
        })
    })
end

-- Hook all future messages
LogService.MessageOut:Connect(onLogMessage)

-- ── Output forwarding (keep print/warn working locally too) ─────────────
local _print = print
local _warn  = warn

local function concat(...)
    local parts = {}
    for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
    return table.concat(parts, "\t")
end

-- These just call the real print/warn — LogService picks them up automatically
local function fwdPrint(...) _print(concat(...)) end
local function fwdWarn(...)  _warn(concat(...))  end

local env = getfenv(0)
env.print = fwdPrint
env.warn  = fwdWarn

-- ── Message handler ─────────────────────────────────────────────────────
local function onMessage(rawMsg)
    
    local ok, data = pcall(HttpService.JSONDecode, HttpService, rawMsg)
    if not ok or type(data) ~= "table" then
        warn("[WebSocket] Invalid JSON: " .. rawMsg)
        return
    end

    if data.type == "Execution" and type(data.value) == "string" and #data.value > 0 then
        local fn, compileErr = loadstring(data.value)

        if not fn then
            warn("[WebSocket] Compile error: " .. tostring(compileErr))
            return
        end

        setfenv(fn, getfenv(0))

        local success, runErr = pcall(fn)
        if not success then
            warn("[WebSocket] Runtime error: " .. tostring(runErr))
        end
    end
end

-- ── Connection ──────────────────────────────────────────────────────────
local function connect()
    while true do
        local success, result = pcall(WebSocket.connect, WS_URL)

        if success then
            ws        = result
            connected = true
            print("[WebSocket] Connected → " .. WS_URL)

            ws.OnMessage:Connect(onMessage)
            ws.OnClose:Connect(function()
                connected = false
                warn("[WebSocket] Disconnected — retrying in " .. RETRY_DELAY .. "s")
            end)

            while connected do task.wait(1) end
        else
            warn("[WebSocket] Failed to connect: " .. tostring(result))
        end

        task.wait(RETRY_DELAY)
    end
end

-- ── Entry ───────────────────────────────────────────────────────────────
connect()
