const DEBUG = true; // set to false to disable debug logs

let audioContext;
let analyser;
let dataArray;
let source;
let processor;
let mediaStream;

const levelBar = document.getElementById('levelBar');
const levelNum = document.getElementById('levelNum');
const stopBtn = document.getElementById('stopBtn');

function logDebug(msg) {
    if (DEBUG) {
        const time = new Date().toLocaleTimeString();
        console.log(`[${time}] [DEBUG] ${msg}`);
    }
}

async function init() {
    try {
        mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        analyser = audioContext.createAnalyser();
        analyser.fftSize = 256;
        const bufferLength = analyser.frequencyBinCount;
        dataArray = new Uint8Array(bufferLength);

        source = audioContext.createMediaStreamSource(mediaStream);
        processor = audioContext.createScriptProcessor(256, 1, 1);

        processor.onaudioprocess = () => {
            analyser.getByteTimeDomainData(dataArray);
            let sum = 0;
            for (let i = 0; i < dataArray.length; i++) {
                const v = (dataArray[i] - 128) / 128;
                sum += v * v;
            }
            const rms = Math.sqrt(sum / dataArray.length);
            updateDisplay(rms);
        };

        source.connect(analyser);
        analyser.connect(processor);
        processor.connect(audioContext.destination);

        stopBtn.classList.remove('hidden');
        stopBtn.addEventListener('click', stop);

        levelBar.classList.add('active');

        logDebug('Noise meter started');
    } catch (err) {
        console.error('Microphone access denied or not available', err);
    }
}

function updateDisplay(level) {
    const percent = Math.min(1, level) * 100;
    levelBar.style.width = `${percent}%`;
    levelNum.textContent = level.toFixed(2);
    logDebug(`Noise level: ${level.toFixed(2)}`);
}

function stop() {
    if (processor) processor.disconnect();
    if (analyser) analyser.disconnect();
    if (source) source.disconnect();
    if (mediaStream) {
        mediaStream.getTracks().forEach(t => t.stop());
    }
    stopBtn.classList.add('hidden');
    levelBar.classList.remove('active');
    logDebug('Noise meter stopped');
}

window.addEventListener('DOMContentLoaded', init);
