const DEBUG = true;

const pulseElem = document.getElementById('pulse');
const progressElem = document.getElementById('progress');
const resultElem = document.getElementById('result');
const restartBtn = document.getElementById('restartBtn');
const backBtn = document.getElementById('backBtn');

let beatLength = 1000; // ms
let intervalId = null;
let lastBeat = 0;
let perfectStreak = 0;
let combo = 0;

window.pulseTapScore = { combo: 0 };

function logDebug(msg) {
    if (DEBUG) {
        const t = new Date().toLocaleTimeString();
        console.log(`[${t}] [DEBUG] ${msg}`);
    }
}

function pulse() {
    lastBeat = performance.now();
    pulseElem.classList.add('active');
    // reset progress bar
    progressElem.style.transition = 'none';
    progressElem.style.width = '0%';
    setTimeout(() => {
        pulseElem.classList.remove('active');
        progressElem.style.transition = `width ${beatLength}ms linear`;
        progressElem.style.width = '100%';
    }, 20);
}

function startGame() {
    logDebug('Game started');
    beatLength = 1000;
    perfectStreak = 0;
    combo = 0;
    window.pulseTapScore.combo = 0;
    resultElem.textContent = 'Press Space in time with the pulse';
    restartBtn.classList.add('hidden');
    clearInterval(intervalId);
    // start progress bar animation
    progressElem.style.transition = `width ${beatLength}ms linear`;
    progressElem.style.width = '100%';
    pulse();
    intervalId = setInterval(pulse, beatLength);
}

function adjustTempo() {
    if (perfectStreak > 0 && perfectStreak % 5 === 0) {
        beatLength = Math.max(300, beatLength - 100);
        clearInterval(intervalId);
        intervalId = setInterval(pulse, beatLength);
        logDebug(`Tempo increased. New beat length: ${beatLength}ms`);
    }
}

function handleKey(e) {
    if (e.code !== 'Space') return;
    const now = performance.now();
    let delta = now - lastBeat;
    if (delta > beatLength / 2) {
        delta -= beatLength;
    }
    const abs = Math.abs(delta);
    let msg = '';
    if (abs <= 50) {
        msg = 'Perfect!';
        perfectStreak++;
        combo++;
    } else if (abs <= 100) {
        msg = 'Good!';
        perfectStreak = 0;
        combo = 0;
    } else {
        msg = delta < 0 ? 'Too early!' : 'Too late!';
        perfectStreak = 0;
        combo = 0;
    }
    window.pulseTapScore.combo = combo;
    resultElem.textContent = msg;
    logDebug(`Key press delta: ${delta.toFixed(1)}ms | ${msg}`);
    restartBtn.classList.remove('hidden');
    adjustTempo();
}

function back() {
    window.close();
}

window.addEventListener('DOMContentLoaded', () => {
    startGame();
    document.addEventListener('keydown', handleKey);
    restartBtn.addEventListener('click', startGame);
    backBtn.addEventListener('click', back);
});
