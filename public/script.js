const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const { ipcRenderer } = require('electron');

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
const newModuleSection = document.getElementById('newModuleSection');
const settingsSection = document.getElementById('settingsSection');
const quitBtn = document.getElementById('quitBtn');
const quitConfirm = document.getElementById('quitConfirm');
const quitYesBtn = document.getElementById('quitYes');
const quitNoBtn = document.getElementById('quitNo');
const backButtons = document.querySelectorAll('.backBtn');

function logDebug(message) {
    const time = new Date().toLocaleTimeString();
    debugOutput.textContent += `[${time}] ${message}\n`;
    debugOutput.scrollTop = debugOutput.scrollHeight;
    console.log(message);
}

function toggleDebug() {
    debugPanel.classList.toggle('hidden');
}

toggleDebugBtn.addEventListener('click', toggleDebug);

backButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        logDebug('Back button clicked');
        showMainMenu();
    });
});

newModuleBtn.addEventListener('click', () => {
    logDebug('New Module button clicked');
    hideAll();
    newModuleSection.classList.remove('hidden');
});

settingsBtn.addEventListener('click', () => {
    logDebug('Settings button opened');
    hideAll();
    settingsSection.classList.remove('hidden');
});

viewModulesBtn.addEventListener('click', () => {
    logDebug('View All Modules button clicked');
    showModules();
});

loadModuleBtn.addEventListener('click', () => {
    logDebug('Load Module button clicked');
    showModules();
});

quitBtn.addEventListener('click', () => {
    logDebug('Quit button clicked');
    mainMenu.classList.add('hidden');
    quitConfirm.classList.remove('hidden');
});

quitYesBtn.addEventListener('click', () => {
    logDebug('Quit confirmed');
    ipcRenderer.send('quit-app');
});

quitNoBtn.addEventListener('click', () => {
    logDebug('Quit canceled');
    quitConfirm.classList.add('hidden');
    mainMenu.classList.remove('hidden');
});

function showMainMenu() {
    hideAll();
    mainMenu.classList.remove('hidden');
}

function hideAll() {
    mainMenu.classList.add('hidden');
    moduleList.classList.add('hidden');
    newModuleSection.classList.add('hidden');
    settingsSection.classList.add('hidden');
    quitConfirm.classList.add('hidden');
}

function showModules() {
    hideAll();
    moduleList.classList.remove('hidden');
    modulesContainer.innerHTML = '';
    const modulesPath = path.join(__dirname, '..', 'modules');

    let folders = [];
    try {
        folders = fs.readdirSync(modulesPath, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name);
    } catch (err) {
        logDebug('No modules directory found.');
        return;
    }

    if (folders.length === 0) {
        modulesContainer.textContent = 'No modules found.';
        logDebug('No modules found.');
        return;
    }

    folders.forEach(folder => {
        const moduleDir = path.join(modulesPath, folder);
        const projectFile = path.join(moduleDir, 'project.godot');
        const metadataFile = path.join(moduleDir, 'metadata.json');

        if (!fs.existsSync(projectFile) || !fs.existsSync(metadataFile)) {
            return;
        }

        let metadata = {};
        try {
            const data = fs.readFileSync(metadataFile);
            metadata = JSON.parse(data);
        } catch (err) {
            logDebug(`Failed to read metadata for ${folder}`);
            return;
        }

        const moduleDiv = document.createElement('div');
        moduleDiv.className = 'moduleEntry';
        const title = document.createElement('span');
        title.textContent = metadata.name || folder;
        const launchBtn = document.createElement('button');
        launchBtn.textContent = 'Launch';
        launchBtn.addEventListener('click', () => {
            logDebug(`Attempting to load module ${folder}...`);
            const child = spawn('godot', ['--path', moduleDir]);
            child.on('close', (code) => {
                logDebug(`Module ${folder} exited with code ${code}`);
            });
            child.on('error', (err) => {
                logDebug(`Failed to launch ${folder}: ${err}`);
            });
        });

        moduleDiv.appendChild(title);
        moduleDiv.appendChild(launchBtn);
        modulesContainer.appendChild(moduleDiv);
    });
}
