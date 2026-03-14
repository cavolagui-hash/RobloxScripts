// --- Configurações Globais ---
const CORRECT_KEY = 'guyxiter';
const TAB_NAMES = ['Aimbot', 'Visual', 'Player', 'Misc', 'Config'];
let isRGBEnabled = true;
let savedConfigs = {};

// --- Função Principal de Inicialização ---
function initCheatMenu() {
    // Cria estilos globais
    createGlobalStyles();
    
    // Cria elementos principais
    const loginScreen = createLoginScreen();
    const matrixBg = createMatrixBackground();
    const gameOverlay = createGameOverlay();
    const mainPanel = createMainPanel();

    // Adiciona elementos ao body
    document.body.appendChild(loginScreen);
    document.body.appendChild(matrixBg);
    document.body.appendChild(gameOverlay);
    document.body.appendChild(mainPanel);

    // Inicializa funcionalidades após login
    setupLoginHandler(loginScreen, () => {
        initMatrixEffect(matrixBg);
        initDraggablePanel(mainPanel);
        initTabs(mainPanel);
        initRGBToggle(mainPanel);
        initColorPicker(mainPanel);
        initFOVControl(mainPanel);
        initOverlayToggle(gameOverlay, mainPanel);
        initConfigSaveLoad(mainPanel);
        initMobileSupport(mainPanel);
    });
}

// --- Criação de Estilos Globais ---
function createGlobalStyles() {
    const style = document.createElement('style');
    style.textContent = `
        * { margin: 0; padding: 0; box-sizing: border-box; user-select: none; }
        body { overflow: hidden; font-family: 'Segoe UI', sans-serif; background: #000; }

        /* Efeito Matrix */
        .matrix-bg { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 0; }
        .matrix-canvas { display: block; background: #000; }

        /* Tela de Login */
        .login-screen {
            position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
            background: #000; z-index: 20; display: flex; flex-direction: column;
            justify-content: center; align-items: center; gap: 20px;
        }
        .login-input {
            padding: 15px 20px; width: 80%; max-width: 300px;
            border: 2px solid #ff00ff; border-radius: 8px; background: #222; color: #fff;
            font-size: 1rem; outline: none;
        }
        .login-btn {
            padding: 12px 30px; border: none; border-radius: 8px;
            background: #ff00ff; color: #000; font-weight: bold; cursor: pointer;
            transition: background 0.2s ease;
        }
        .login-btn:hover { background: #cc00cc; }

        /* Painel Flutuante */
        .draggable-panel {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            width: 90vw; max-width: 600px; background: #1a1a1a;
            border: 2px solid #ff00ff; border-radius: 12px;
            box-shadow: 0 0 20px rgba(255,0,255,0.5); z-index: 10;
            overflow: hidden; transition: all 0.3s ease;
        }
        .panel-header {
            padding: 15px; background: linear-gradient(90deg, #ff00ff, #00ffff, #ff00ff);
            background-size: 200% 100%; animation: rgbGradient 3s linear infinite;
            cursor: move; display: flex; justify-content: space-between; align-items: center;
        }
        @keyframes rgbGradient { 0% { background-position: 0% 0%; } 100% { background-position: 200% 0%; } }
        .header-title { color: #000; font-weight: bold; font-size: 1.2rem; }
        .rgb-toggle {
            padding: 5px 10px; border: none; border-radius: 5px;
            background: #333; color: #fff; cursor: pointer;
            transition: background 0.2s ease;
        }
        .rgb-toggle:hover { background: #444; }

        /* Tabs */
        .tabs-container { display: flex; background: #222; overflow-x: auto; }
        .tab-btn {
            padding: 12px 20px; border: none; background: transparent; color: #aaa;
            cursor: pointer; transition: all 0.2s ease; position: relative;
            font-size: 1rem;
        }
        .tab-btn.active { color: #00ffff; font-weight: bold; }
        .tab-btn.active::after {
            content: ''; position: absolute; bottom: 0; left: 0; width: 100%;
            height: 3px; background: linear-gradient(90deg, #ff00ff, #00ffff);
            animation: tabSlide 0.3s ease forwards;
        }
        @keyframes tabSlide { 0% { width: 0; left: 50%; } 100% { width: 100%; left: 0; } }
        .tab-content { display: none; padding: 20px; color: #fff; }
        .tab-content.active { display: block; animation: fadeIn 0.3s ease; }
        @keyframes fadeIn { 0% { opacity: 0; } 100% { opacity: 1; } }

        /* Componentes */
        .color-picker { margin: 10px 0; display: flex; align-items: center; gap: 10px; }
        .fov-control { margin: 15px 0; }
        .fov-circle {
            width: 100px; height: 100px; border: 3px solid #00ffff; border-radius: 50%;
            margin: 10px auto; position: relative; transition: all 0.2s ease;
        }
        .overlay-toggle { margin: 10px 0; display: flex; gap: 15px; flex-wrap: wrap; }
        .toggle-btn {
            padding: 8px 12px; border: 2px solid #ff00ff; border-radius: 5px;
            background: #333; color: #fff; cursor: pointer; transition: all 0.2s ease;
        }
        .toggle-btn.active { background: #ff00ff; color: #000; }
        .config-btn {
            padding: 10px 20px; border: none; border-radius: 5px;
            background: linear-gradient(90deg, #ff00ff, #00ffff); color: #000;
            font-weight: bold; cursor: pointer; margin: 10px 5px 10px 0;
            transition: opacity 0.2s ease;
        }
        .config-btn:hover { opacity: 0.9; }

        /* Overlay */
        .game-overlay {
            position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 5;
            pointer-events: none; display: none;
        }
        .sim-box {
            position: absolute; width: 150px; height: 250px; border: 2px solid #00ffff;
            box-shadow: 0 0 10px rgba(0,255,255,0.8);
        }
        .sim-line {
            position: absolute; width: 2px; background: #ff00ff;
            box-shadow: 0 0 10px rgba(255,0,255,0.8);
        }
    `;
    document.head.appendChild(style);
}

// --- Criação de Elementos DOM ---
function createLoginScreen() {
    const screen = document.createElement('div');
    screen.className = 'login-screen';

    const input = document.createElement('input');
    input.className = 'login-input';
    input.placeholder = 'Digite a chave de acesso...';
    input.type = 'text';

    const btn = document.createElement('button');
    btn.className = 'login-btn';
    btn.textContent = 'Entrar';

    screen.appendChild(input);
    screen.appendChild(btn);
    return screen;
}

function createMatrixBackground() {
    const bg = document.createElement('div');
    bg.className = 'matrix-bg';
    
    const canvas = document.createElement('canvas');
    canvas.className = 'matrix-canvas';
    bg.appendChild(canvas);
    return bg;
}

function createGameOverlay() {
    const overlay = document.createElement('div');
    overlay.className = 'game-overlay';

    // Cria elementos de overlay simulado
    const boxes = [
        { top: '20%', left: '15%' },
        { top: '40%', left: '70%' }
    ];
    boxes.forEach(pos => {
        const box = document.createElement('div');
        box.className = 'sim-box';
        box.style.top = pos.top;
        box.style.left = pos.left;
        overlay.appendChild(box);
    });

    const lines = [
        { top: '30%', left: '50%', height: '200px', rotate: '45deg' },
        { top: '60%', left: '30%', height: '150px', rotate: '-30deg' }
    ];
    lines.forEach(pos => {
        const line = document.createElement('div');
        line.className = 'sim-line';
        line.style.top = pos.top;
        line.style.left = pos.left;
        line.style.height = pos.height;
        line.style.transform = `rotate(${pos.rotate})`;
        overlay.appendChild(line);
    });

    return overlay;
}

function createMainPanel() {
    const panel = document.createElement('div');
    panel.className = 'draggable-panel';

    // Cabeçalho
    const header = document.createElement('div');
    header.className = 'panel-header';
    header.id = 'drag-handle';

    const title = document.createElement('div');
    title.className = 'header-title';
    title.textContent = 'CHEAT MENU PRO';

    const rgbToggle = document.createElement('button');
    rgbToggle.className = 'rgb-toggle';
    rgbToggle.id = 'rgb-toggle';
    rgbToggle.textContent = 'RGB: ON';

    header.appendChild(title);
    header.appendChild(rgbToggle);
    panel.appendChild(header);

    // Tabs
    const tabsContainer = document.createElement('div');
    tabsContainer.className = 'tabs-container';
    panel.appendChild(tabsContainer);

    const tabsContent = document.createElement('div');
    tabsContent.className = 'tabs-content-wrapper';
    panel.appendChild(tabsContent);

    // Cria cada tab
    TAB_NAMES.forEach((name, idx) => {
        // Botão da tab
        const tabBtn = document.createElement('button');
        tabBtn.className = `tab-btn ${idx === 0 ? 'active' : ''}`;
        tabBtn.dataset.tab = name.toLowerCase();
        tabBtn.textContent = name;
        tabsContainer.appendChild(tabBtn);

        // Conteúdo da tab
        const tabContent = document.createElement('div');
        tabContent.className = `tab-content ${idx === 0 ? 'active' : ''}`;
        tabContent.id = `${name.toLowerCase()}-tab`;
        
        switch(name) {
            case 'Aimbot':
                tabContent.innerHTML = `
                    <h3>AIMBOT CONFIG</h3>
                    <div class="fov-control">
                        <label>FOV: <span id="fov-value">50</span>px</label>
                        <input type="range" id="fov-slider" min="20" max="150" value="50">
                        <div id="fov-circle" class="fov-circle"></div>
                    </div>
                `;
                break;
            case 'Visual':
                tabContent.innerHTML = `
                    <h3>VISUAL SETTINGS</h3>
                    <div class="color-picker">
                        <label>Cor do Painel:</label>
                        <input type="color" id="panel-color" value="#ff00ff">
                    </div>
                    <div class="overlay-toggle">
                        <button class="toggle-btn" id="box-overlay-toggle">Boxes</button>
                        <button class="toggle-btn" id="line-overlay-toggle">Linhas</button>
                        <button class="toggle-btn" id="3d-overlay-toggle">3D Overlay</button>
                    </div>
                `;
                break;
            case 'Player':
                tabContent.innerHTML = `<h3>PLAYER OPTIONS</h3><p>Configurações específicas do jogador</p>`;
                break;
            case 'Misc':
                tabContent.innerHTML = `<h3>MISC SETTINGS</h3><p>Opções adicionais personalizáveis</p>`;
                break;
            case 'Config':
                tabContent.innerHTML = `
                    <h3>CONFIGURAÇÕES</h3>
                    <button class="config-btn" id="save-config">Salvar Configurações</button>
                    <button class="config-btn" id="load-config">Carregar Configurações</button>
                `;
                break;
        }

        tabsContent.appendChild(tabContent);
    });

    return panel;
}

// --- Implementação das Funcionalidades ---
function setupLoginHandler(loginScreen, onSuccess) {
    const input = loginScreen.querySelector('.login-input');
    const btn = loginScreen.querySelector('.login-btn');

    const validateKey = () => {
        if (input.value.trim() === CORRECT_KEY) {
            loginScreen.style.display = 'none';
            onSuccess();
        } else {
            alert('Chave inválida!');
            input.value = '';
        }
    };

    btn.addEventListener('click', validateKey);
    input.addEventListener('keypress', (e) => e.key === 'Enter' && validateKey());
}

function initMatrixEffect(matrixBg) {
    const canvas = matrixBg.querySelector('.matrix-canvas');
    const ctx = canvas.getContext('2d');

    const resize = () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', resize);
    resize();

    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZあいうえおかきくけこ';
    const columns = Math.floor(canvas.width / 20);
    const drops = Array(columns).fill(1);

    const draw = () => {
        ctx.fillStyle = 'rgba(0,0,0,0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#00ff00';
        ctx.font = '15px monospace';

        drops.forEach((drop, i) => {
            const text = chars[Math.floor(Math.random() * chars.length)];
            ctx.fillText(text, i * 20, drop * 20);
            if (drop * 20 > canvas.height && Math.random() > 0.975) drops[i] = 0;
            drops[i]++;
        });
    };
    setInterval(draw, 35);
}

function initDraggablePanel(panel) {
    const handle = panel.querySelector('#drag-handle');
    let isDragging = false;
    let offsetX, offsetY;

    const startDrag = (e) => {
        isDragging = true;
        const clientX = e.clientX || e.touches[0].clientX;
        const clientY = e.clientY || e.touches[0].clientY;
        const rect = panel.getBoundingClientRect();
        offsetX = clientX - rect.left;
        offsetY = clientY - rect.top;

        document.addEventListener('mousemove', drag);
        document.addEventListener('touchmove', drag, { passive: false });
        document.addEventListener('mouseup', stopDrag);
        document.addEventListener('touchend', stopDrag);
    };

    const drag = (e) => {
        if (!isDragging) return;
        e.preventDefault();
        const clientX = e.clientX || e.touches[0].clientX;
        const clientY = e.clientY || e.touches[0].clientY;
        panel
