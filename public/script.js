const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const newModuleBtn = document.getElementById('newModuleBtn');
const loadModuleBtn = document.getElementById('loadModuleBtn');
const viewModulesBtn = document.getElementById('viewModulesBtn');
const settingsBtn = document.getElementById('settingsBtn');
const toggleDebugBtn = document.getElementById('toggleDebug');
const debugPanel = document.getElementById('debugPanel');
const debugOutput = document.getElementById('debugOutput');
const moduleList = document.getElementById('moduleList');
const modulesContainer = document.getElementById('modulesContainer');

function logDebug(message) {
    const time = new Date().toLocaleTimeString();
    debugOutput.textContent += `[${time}] ${message}\n`;
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

function showModules() {
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
