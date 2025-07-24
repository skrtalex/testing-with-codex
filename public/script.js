const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Allow custom Godot path via environment variable
const godotExecutable = process.env.GODOT_PATH || 'godot';

const newModuleBtn = document.getElementById('newModuleBtn');
const loadModuleBtn = document.getElementById('loadModuleBtn');
const viewModulesBtn = document.getElementById('viewModulesBtn');
const settingsBtn = document.getElementById('settingsBtn');
const toggleDebugBtn = document.getElementById('toggleDebug');
const debugPanel = document.getElementById('debugPanel');
const debugOutput = document.getElementById('debugOutput');
const moduleList = document.getElementById('moduleList');
const modulesContainer = document.getElementById('modulesContainer');
const mainMenu = document.getElementById('mainMenu');
const backBtn = document.getElementById('backBtn');

function logDebug(message) {
    const time = new Date().toLocaleTimeString();
    debugOutput.textContent += `[${time}] [DEBUG] ${message}\n`;
    debugOutput.scrollTop = debugOutput.scrollHeight;
    console.log(message);
}

function toggleDebug() {
    debugPanel.classList.toggle('hidden');
}

toggleDebugBtn.addEventListener('click', () => {
    toggleDebug();
});

newModuleBtn.addEventListener('click', () => {
    logDebug('New Module button clicked');
});

settingsBtn.addEventListener('click', () => {
    logDebug('Settings button opened');
});

viewModulesBtn.addEventListener('click', () => {
    logDebug('View All Modules button clicked');
    showModules();
});

loadModuleBtn.addEventListener('click', () => {
    logDebug('Load Module button clicked');
    showModules();
});

backBtn.addEventListener('click', () => {
    logDebug('Back to main menu');
    moduleList.classList.add('hidden');
    mainMenu.classList.remove('hidden');
});

function showModules() {
    moduleList.classList.remove('hidden');
    mainMenu.classList.add('hidden');
    modulesContainer.innerHTML = '';

    const entries = [];
    const modulesPath = path.join(__dirname, '..', 'modules');

    try {
        const folders = fs.readdirSync(modulesPath, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name);

        folders.forEach(folder => {
            const moduleDir = path.join(modulesPath, folder);
            const projectFile = path.join(moduleDir, 'project.godot');
            const metadataFile = path.join(moduleDir, 'metadata.json');

            if (!fs.existsSync(projectFile) || !fs.existsSync(metadataFile)) {
                return;
            }

            try {
                const data = fs.readFileSync(metadataFile);
                const metadata = JSON.parse(data);
                entries.push({
                    type: 'godot',
                    name: folder,
                    dir: moduleDir,
                    metadata
                });
            } catch (err) {
                logDebug(`Failed to read metadata for ${folder}`);
            }
        });
    } catch (err) {
        logDebug('No modules directory found.');
    }

    // Load HTML/Web modules from modules.json
    const htmlModulesFile = path.join(__dirname, 'modules.json');
    if (fs.existsSync(htmlModulesFile)) {
        try {
            const data = fs.readFileSync(htmlModulesFile);
            const htmlModules = JSON.parse(data);
            htmlModules.forEach(m => {
                entries.push({ type: 'html', meta: m });
            });
        } catch (err) {
            logDebug('Failed to read modules.json');
        }
    }

    if (entries.length === 0) {
        modulesContainer.textContent = 'No modules found.';
        logDebug('No modules found.');
        return;
    }

    entries.forEach(entry => {
        const moduleDiv = document.createElement('div');
        moduleDiv.className = 'moduleEntry';
        const title = document.createElement('span');
        if (entry.type === 'godot') {
            title.textContent = entry.metadata.name || entry.name;
        } else {
            title.textContent = entry.meta.title || entry.meta.name;
        }
        const launchBtn = document.createElement('button');
        launchBtn.textContent = entry.type === 'godot' ? 'Launch' : 'Open';
        launchBtn.addEventListener('click', () => {
            if (entry.type === 'godot') {
                logDebug(`Attempting to load module ${entry.name} using ${godotExecutable}...`);
                const child = spawn(godotExecutable, ['--path', entry.dir]);
                child.on('close', (code) => {
                    logDebug(`Module ${entry.name} exited with code ${code}`);
                });
                child.on('error', (err) => {
                    logDebug(`Failed to launch ${entry.name}: ${err}`);
                });
            } else {
                const url = path.join(__dirname, entry.meta.path);
                logDebug(`Opening HTML module ${entry.meta.name} at ${url}`);
                window.open(url);
            }
        });

        moduleDiv.appendChild(title);
        moduleDiv.appendChild(launchBtn);
        modulesContainer.appendChild(moduleDiv);
    });
}
