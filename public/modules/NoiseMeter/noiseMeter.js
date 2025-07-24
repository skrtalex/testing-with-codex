const DEBUG = true; // set to false to disable debug logs

let audioContext;
let analyser;
let dataArray;
let source;
let processor;
let mediaStream;

let micAccessGranted = false;
let isRunning = false;
let targetLevel = 0;
let matchedTime = 0;
let lastTime = 0;

const levelBar = document.getElementById('levelBar');
const levelNum = document.getElementById('levelNum');
const stopBtn = document.getElementById('stopBtn');
const backBtn = document.getElementById('backBtn');
const micWarning = document.querySelector('.micWarning');
const targetLine = document.getElementById('targetLine');
const targetInfo = document.getElementById('targetInfo');
const timerInfo = document.getElementById('timerInfo');
const unlockMsg = document.getElementById('unlockMsg');

function logDebug(msg) {
    if (DEBUG) {
        const time = new Date().toLocaleTimeString();
        console.log(`[${time}] [DEBUG] ${msg}`);
    }
}

function setupGame() {
    targetLevel = parseFloat((Math.random() * 0.35 + 0.25).toFixed(2));
    targetLine.style.left = `${targetLevel * 100}%`;
    targetInfo.textContent = `Target level: ${targetLevel.toFixed(2)}`;
    timerInfo.textContent = `Matched: 0.0 / 3.0 seconds`;
    matchedTime = 0;
    unlockMsg.classList.add('hidden');
}

async function startCapture() {
    if (isRunning) return;
    try {
        mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
        micAccessGranted = true;
        micWarning.classList.add('hidden');

        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        analyser = audioContext.createAnalyser();
        analyser.fftSize = 256;
        const bufferLength = analyser.frequencyBinCount;
        dataArray = new Uint8Array(bufferLength);

        source = audioContext.createMediaStreamSource(mediaStream);
        processor = audioContext.createScriptProcessor(256, 1, 1);

        lastTime = performance.now();
        processor.onaudioprocess = () => {
            analyser.getByteTimeDomainData(dataArray);
            let sum = 0;
            for (let i = 0; i < dataArray.length; i++) {
                const v = (dataArray[i] - 128) / 128;
                sum += v * v;
            }
            const rms = Math.sqrt(sum / dataArray.length);
            const adjusted = Math.min(1, rms * 2.5);
            updateDisplay(adjusted);
        };

        source.connect(analyser);
        analyser.connect(processor);
        processor.connect(audioContext.destination);

        levelBar.classList.add('active');
        stopBtn.textContent = 'Stop';
        stopBtn.classList.remove('hidden');
        isRunning = true;
        logDebug('Noise meter started');
    } catch (err) {
        console.error('Microphone access denied or not available', err);
        micWarning.classList.remove('hidden');
    }
}

function updateDisplay(level) {
    const now = performance.now();
    const dt = (now - lastTime) / 1000;
    lastTime = now;

    const percent = Math.min(1, level) * 100;
    levelBar.style.width = `${percent}%`;
    levelNum.textContent = level.toFixed(2);

    const match = Math.abs(level - targetLevel) <= 0.03;
    levelBar.style.background = match ? 'green' : 'red';
    if (match) {
        matchedTime += dt;
    }
    timerInfo.textContent = `Matched: ${matchedTime.toFixed(1)} / 3.0 seconds`;
    if (matchedTime >= 3 && unlockMsg.classList.contains('hidden')) {
        unlockMsg.classList.remove('hidden');
        stopCapture();
        stopBtn.disabled = true;
    }

    logDebug(`Level: ${level.toFixed(2)} | Target: ${targetLevel.toFixed(2)} | Match: ${match}`);
}

function stopCapture() {
    if (!isRunning) return;
    if (processor) processor.disconnect();
    if (analyser) analyser.disconnect();
    if (source) source.disconnect();
    if (mediaStream) {
        mediaStream.getTracks().forEach(t => t.stop());
    }
    levelBar.classList.remove('active');
    stopBtn.textContent = 'Resume';
    isRunning = false;
    logDebug('Noise meter stopped');
}

function toggleStream() {
    if (isRunning) {
        stopCapture();
    } else {
        startCapture();
    }
}

function back() {
    stopCapture();
    window.close();
}

window.addEventListener('DOMContentLoaded', () => {
    setupGame();
    startCapture();
    stopBtn.addEventListener('click', toggleStream);
    backBtn.addEventListener('click', back);
});
