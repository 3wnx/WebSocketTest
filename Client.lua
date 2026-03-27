<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <title>Delta Controller</title>
    <link
        href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Syne:wght@700;800&display=swap"
        rel="stylesheet" />
    <style>
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --bg: #0d0f14;
            --surface: #13161e;
            --border: #1e2330;
            --accent: #e8b86d;
            --accent2: #5c7cfa;
            --danger: #ff5c5c;
            --success: #4ade80;
            --text: #c9d1e0;
            --muted: #4a5168;
            --header-h: 48px;
            --toolbar-h: 38px;
        }

        html,
        body {
            height: 100%;
            overflow: hidden;
            background: var(--bg);
            color: var(--text);
            font-family: 'JetBrains Mono', monospace;
        }

        /* ── TOP BAR ── */
        #topbar {
            height: var(--header-h);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 16px;
            gap: 12px;
            user-select: none;
        }

        #topbar .logo {
            font-family: 'Syne', sans-serif;
            font-weight: 800;
            font-size: 15px;
            letter-spacing: .08em;
            color: var(--accent);
            text-transform: uppercase;
        }

        #topbar .logo span {
            color: var(--text);
        }

        #conn-status {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 7px;
            font-size: 11px;
            color: var(--muted);
            letter-spacing: .04em;
        }

        #conn-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--danger);
            box-shadow: 0 0 6px var(--danger);
            transition: background .3s, box-shadow .3s;
        }

        #conn-dot.connected {
            background: var(--success);
            box-shadow: 0 0 6px var(--success);
        }

        /* ── LAYOUT ── */
        #workspace {
            display: flex;
            height: calc(100vh - var(--header-h));
        }

        /* ── EDITOR PANEL ── */
        #editor-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            border-right: 1px solid var(--border);
            min-width: 0;
        }

        #editor-toolbar {
            height: var(--toolbar-h);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 10px;
            gap: 8px;
        }

        .tab {
            font-size: 11px;
            color: var(--muted);
            padding: 4px 12px;
            border-radius: 4px;
            cursor: pointer;
            transition: color .2s, background .2s;
            letter-spacing: .04em;
        }

        .tab.active {
            color: var(--accent);
            background: rgba(232, 184, 109, .08);
        }

        .toolbar-sep {
            width: 1px;
            height: 18px;
            background: var(--border);
            margin: 0 4px;
        }

        .tb-btn {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 11px;
            font-family: 'JetBrains Mono', monospace;
            color: var(--muted);
            background: none;
            border: 1px solid transparent;
            padding: 3px 10px;
            border-radius: 4px;
            cursor: pointer;
            transition: all .2s;
            letter-spacing: .03em;
        }

        .tb-btn:hover {
            color: var(--text);
            border-color: var(--border);
        }

        .tb-btn.run {
            color: var(--bg);
            background: var(--accent);
            border-color: var(--accent);
            font-weight: 600;
            margin-left: auto;
        }

        .tb-btn.run:hover {
            background: #f0c878;
            box-shadow: 0 0 12px rgba(232, 184, 109, .4);
        }

        .tb-btn.run:active {
            transform: scale(.97);
        }

        .kbd {
            font-size: 9px;
            background: rgba(255, 255, 255, .08);
            border: 1px solid rgba(255, 255, 255, .12);
            border-radius: 3px;
            padding: 1px 5px;
            color: var(--muted);
        }

        #editor-container {
            flex: 1;
            position: relative;
            overflow: hidden;
        }

        /* ── LOG PANEL ── */
        #log-panel {
            width: 380px;
            min-width: 280px;
            display: flex;
            flex-direction: column;
            background: var(--surface);
        }

        #log-toolbar {
            height: var(--toolbar-h);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 12px;
            gap: 8px;
        }

        #log-toolbar .panel-label {
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--muted);
        }

        #clear-btn {
            margin-left: auto;
            font-size: 10px;
            font-family: 'JetBrains Mono', monospace;
            color: var(--muted);
            background: none;
            border: none;
            cursor: pointer;
            transition: color .2s;
            letter-spacing: .04em;
        }

        #clear-btn:hover {
            color: var(--danger);
        }

        #log {
            flex: 1;
            overflow-y: auto;
            padding: 10px 14px;
            font-size: 12px;
            line-height: 1.8;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        #log::-webkit-scrollbar {
            width: 4px;
        }

        #log::-webkit-scrollbar-thumb {
            background: var(--border);
            border-radius: 2px;
        }

        .log-entry {
            display: flex;
            gap: 8px;
            align-items: flex-start;
            padding: 2px 0;
            animation: fadeSlide .15s ease-out;
        }

        @keyframes fadeSlide {
            from {
                opacity: 0;
                transform: translateY(4px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .log-time {
            color: var(--muted);
            font-size: 10px;
            padding-top: 2px;
            white-space: nowrap;
            flex-shrink: 0;
        }

        .log-msg {
            color: var(--text);
            word-break: break-all;
            flex: 1;
        }

        .log-msg.system {
            color: var(--muted);
            font-style: italic;
        }

        .log-msg.sent {
            color: var(--accent2);
        }

        .log-msg.success {
            color: var(--success);
        }

        .log-msg.error {
            color: var(--danger);
        }

        .log-msg.warn {
            color: var(--accent);
        }

        /* ── RESIZE HANDLE ── */
        #resize-handle {
            width: 4px;
            background: var(--border);
            cursor: col-resize;
            transition: background .2s;
            flex-shrink: 0;
        }

        #resize-handle:hover {
            background: var(--accent2);
        }

        /* ── STATUS BAR ── */
        #statusbar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 22px;
            background: var(--accent2);
            display: flex;
            align-items: center;
            padding: 0 12px;
            gap: 16px;
            font-size: 10px;
            color: rgba(255, 255, 255, .8);
            letter-spacing: .04em;
            z-index: 10;
        }

        #statusbar span {
            opacity: .7;
        }

        #cursor-pos {
            margin-left: auto;
        }

        /* Monaco override — hide status bar Monaco adds */
        .monaco-editor .margin {
            background: var(--bg) !important;
        }

        .decorationsOverviewRuler {
            display: none !important;
        }
    </style>
</head>

<body>

    <!-- TOP BAR -->
    <div id="topbar">
        <div class="logo">Delta<span>Controller</span></div>
        <div style="width:1px;height:20px;background:var(--border)"></div>
        <div style="font-size:11px;color:var(--muted)">WebSocket Panel</div>
        <div id="conn-status">
            <div id="conn-dot"></div>
            <span id="conn-label">Disconnected</span>
        </div>
    </div>

    <!-- WORKSPACE -->
    <div id="workspace">

        <!-- EDITOR PANEL -->
        <div id="editor-panel">
            <div id="editor-toolbar">
                <div class="tab active">script.lua</div>
                <div class="toolbar-sep"></div>
                <button class="tb-btn" onclick="clearEditor()">⊘ Clear</button>
                <button class="tb-btn" onclick="copyCode()">⎘ Copy</button>
                <button class="tb-btn run" onclick="sendExec()">
                    ▶ Execute <span class="kbd">Ctrl+↵</span>
                </button>
            </div>
            <div id="editor-container"></div>
        </div>

        <!-- RESIZE HANDLE -->
        <div id="resize-handle"></div>

        <!-- LOG PANEL -->
        <div id="log-panel">
            <div id="log-toolbar">
                <div class="panel-label">Output</div>
                <button id="clear-btn" onclick="clearLog()">clear</button>
            </div>
            <div id="log"></div>
        </div>

    </div>

    <!-- STATUS BAR -->
    <div id="statusbar">
        <span>Lua 5.1</span>
        <span>|</span>
        <span>ws://localhost:9000</span>
        <div id="cursor-pos">Ln 1, Col 1</div>
    </div>

    <!-- Monaco Loader -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.45.0/min/vs/loader.min.js"></script>
    <script>
        // ── Monaco Setup ────────────────────────────────────────────────
        require.config({ paths: { vs: 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.45.0/min/vs' } });

        let editor;

        require(['vs/editor/editor.main'], function () {

            // Register Lua language if not already
            if (!monaco.languages.getLanguages().find(l => l.id === 'lua')) {
                monaco.languages.register({ id: 'lua' });
            }

            // Lua token rules
            monaco.languages.setMonarchTokensProvider('lua', {
                keywords: ['and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function',
                    'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true',
                    'until', 'while'],
                builtins: ['print', 'type', 'tostring', 'tonumber', 'pairs', 'ipairs', 'next', 'select',
                    'unpack', 'rawget', 'rawset', 'rawequal', 'rawlen', 'assert', 'error', 'pcall',
                    'xpcall', 'require', 'load', 'loadstring', 'dofile', 'loadfile', 'collectgarbage',
                    'gcinfo', 'newproxy', 'setmetatable', 'getmetatable', 'setfenv', 'getfenv'],
                tokenizer: {
                    root: [
                        [/--\[\[/, 'comment', '@blockComment'],
                        [/--.*$/, 'comment'],
                        [/\[\[/, 'string', '@blockString'],
                        [/"([^"\\]|\\.)*"/, 'string'],
                        [/'([^'\\]|\\.)*'/, 'string'],
                        [/0x[0-9a-fA-F]+/, 'number.hex'],
                        [/\d+\.?\d*([eE][+-]?\d+)?/, 'number'],
                        [/[a-zA-Z_]\w*/, {
                            cases: {
                                '@keywords': 'keyword',
                                '@builtins': 'variable.predefined',
                                '@default': 'identifier'
                            }
                        }],
                        [/[{}()\[\]]/, '@brackets'],
                        [/[+\-*/%^#&|~<>=!;:,.]+/, 'operator'],
                    ],
                    blockComment: [
                        [/\]\]/, 'comment', '@pop'],
                        [/./, 'comment'],
                    ],
                    blockString: [
                        [/\]\]/, 'string', '@pop'],
                        [/./, 'string'],
                    ],
                }
            });

            // Theme
            monaco.editor.defineTheme('delta', {
                base: 'vs-dark',
                inherit: true,
                rules: [
                    { token: 'comment', foreground: '4a5168', fontStyle: 'italic' },
                    { token: 'keyword', foreground: '5c7cfa', fontStyle: 'bold' },
                    { token: 'string', foreground: '4ade80' },
                    { token: 'number', foreground: 'e8b86d' },
                    { token: 'number.hex', foreground: 'e8b86d' },
                    { token: 'identifier', foreground: 'c9d1e0' },
                    { token: 'variable.predefined', foreground: 'f472b6' },
                    { token: 'operator', foreground: '94a3b8' },
                    { token: '@brackets', foreground: '7dd3fc' },
                ],
                colors: {
                    'editor.background': '#0d0f14',
                    'editor.foreground': '#c9d1e0',
                    'editorLineNumber.foreground': '#2e3347',
                    'editorLineNumber.activeForeground': '#4a5168',
                    'editor.selectionBackground': '#1e2a45',
                    'editor.lineHighlightBackground': '#13161e',
                    'editorCursor.foreground': '#e8b86d',
                    'editorIndentGuide.background1': '#1e2330',
                    'editorIndentGuide.activeBackground1': '#2e3347',
                }
            });

            editor = monaco.editor.create(document.getElementById('editor-container'), {
                value: `-- Delta Controller · Lua Script\n-- Press Ctrl+Enter to execute\n\nprint("Hello from Delta!")`,
                language: 'lua',
                theme: 'delta',
                fontSize: 13,
                fontFamily: "'JetBrains Mono', monospace",
                fontLigatures: true,
                lineHeight: 22,
                minimap: { enabled: true, scale: 1 },
                scrollBeyondLastLine: false,
                renderLineHighlight: 'line',
                cursorStyle: 'line',
                cursorBlinking: 'smooth',
                smoothScrolling: true,
                tabSize: 2,
                wordWrap: 'off',
                padding: { top: 12, bottom: 40 },
                automaticLayout: true,
            });

            // Cursor position → status bar
            editor.onDidChangeCursorPosition(e => {
                document.getElementById('cursor-pos').textContent =
                    `Ln ${e.position.lineNumber}, Col ${e.position.column}`;
            });

            // Ctrl+Enter → execute
            editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, sendExec);
        });


        // ── WebSocket ────────────────────────────────────────────────────
        let ws;

        function connect() {
            ws = new WebSocket("ws://localhost:9000");

            ws.onopen = () => {
                setConnected(true);
                ws.send(JSON.stringify({ type: "Identify", clientType: "Admin", username: "webAdmin" }));
                log("Connected to ws://localhost:9000", "success");
            };

            ws.onmessage = (msg) => {
                try {
                    const packet = JSON.parse(msg.data);
                    if (packet.type === "Log") {
                        const type = packet.logType?.toLowerCase() === 'error' ? 'error'
                            : packet.logType?.toLowerCase() === 'warn' ? 'warn'
                                : 'success';
                        log(`[${packet.logType}] ${packet.value}`, type);
                    }
                } catch {
                    log(`← ${msg.data}`, 'system');
                }
            };

            ws.onclose = () => {
                setConnected(false);
                log("Disconnected — retrying in 3s…", "error");
                setTimeout(connect, 3000);
            };

            ws.onerror = () => {
                log("WebSocket error", "error");
            };
        }

        function setConnected(v) {
            document.getElementById('conn-dot').classList.toggle('connected', v);
            document.getElementById('conn-label').textContent = v ? 'Connected' : 'Disconnected';
        }

        connect();


        // ── Actions ──────────────────────────────────────────────────────
        function sendExec() {
            if (!editor) return;
            const code = editor.getValue();
            if (!code.trim()) return;
            if (!ws || ws.readyState !== WebSocket.OPEN) {
                log("Not connected", "error"); return;
            }
            ws.send(JSON.stringify({ type: 'Broadcast', value: JSON.stringify({type: "Execution", value: code}) }));
            log("▶ Execution sent", "sent");
        }

        function clearEditor() {
            if (editor) editor.setValue('');
        }

        function copyCode() {
            if (!editor) return;
            navigator.clipboard.writeText(editor.getValue())
                .then(() => log("Code copied to clipboard", "system"))
                .catch(() => log("Copy failed", "error"));
        }

        function clearLog() {
            document.getElementById('log').innerHTML = '';
        }


        // ── Log ──────────────────────────────────────────────────────────
        function log(text, type = '') {
            const box = document.getElementById('log');
            const now = new Date();
            const ts = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;

            const entry = document.createElement('div');
            entry.className = 'log-entry';
            entry.innerHTML = `<span class="log-time">${ts}</span><span class="log-msg ${type}">${escHtml(text)}</span>`;
            box.appendChild(entry);
            box.scrollTop = box.scrollHeight;
        }

        function escHtml(s) {
            return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }


        // ── Resize Handle ─────────────────────────────────────────────────
        const handle = document.getElementById('resize-handle');
        const logPanel = document.getElementById('log-panel');
        let dragging = false, startX, startW;

        handle.addEventListener('mousedown', e => {
            dragging = true;
            startX = e.clientX;
            startW = logPanel.offsetWidth;
            document.body.style.cursor = 'col-resize';
            document.body.style.userSelect = 'none';
        });

        document.addEventListener('mousemove', e => {
            if (!dragging) return;
            const delta = startX - e.clientX;
            const newW = Math.max(200, Math.min(700, startW + delta));
            logPanel.style.width = newW + 'px';
        });

        document.addEventListener('mouseup', () => {
            dragging = false;
            document.body.style.cursor = '';
            document.body.style.userSelect = '';
        });
    </script>
</body>

</html>
