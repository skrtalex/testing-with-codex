const DEBUG = true;

let audioContext;
let analyser;
let dataArray;
let source;
let processor;
let mediaStream;

let isRunning = false;
let matchedTime = 0;
let lastTime = 0;

const targetMin = 0.35;
const targetMax = 0.45;
const requiredTime = 3.0;

const levelBar = document.getElementById('levelBar');
const levelNum = document.getElementById('levelNum');
const stopBtn = document.getElementById('stopBtn');
const backBtn = document.getElementById('backBtn');
const micWarning = document.querySelector('.micWarning');
const targetZone = document.getElementById('targetZone');
const timerInfo = document.getElementById('timerInfo');
const unlockMsg = document.getElementById('unlockMsg');

function logDebug(msg) {
    if (DEBUG) {
        const time = new Date().toLocaleTimeString();
        console.log(`[${time}] [DEBUG] ${msg}`);
    }
}

function setupRange() {
    const left = targetMin * 100;
    const width = (targetMax - targetMin) * 100;
    targetZone.style.left = `${left}%`;
    targetZone.style.width = `${width}%`;
    timerInfo.textContent = `Matched: 0.0 / ${requiredTime.toFixed(1)} seconds`;
    matchedTime = 0;
    unlockMsg.classList.add('hidden');
}

async function startCapture() {
    if (isRunning) return;
    try {
        mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
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
        logDebug('Voice lock started');
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

    const inRange = level >= targetMin && level <= targetMax;
    levelBar.style.background = inRange ? 'green' : 'red';

    if (inRange) {
        matchedTime += dt;
    }
    timerInfo.textContent = `Matched: ${matchedTime.toFixed(1)} / ${requiredTime.toFixed(1)} seconds`;

    if (matchedTime >= requiredTime && unlockMsg.classList.contains('hidden')) {
        unlockMsg.classList.remove('hidden');
        stopCapture();
        stopBtn.disabled = true;
    }

    logDebug(`Level: ${level.toFixed(2)} | In range: ${inRange}`);
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
    logDebug('Voice lock stopped');
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
    setupRange();
    startCapture();
    stopBtn.addEventListener('click', toggleStream);
    backBtn.addEventListener('click', back);
});
