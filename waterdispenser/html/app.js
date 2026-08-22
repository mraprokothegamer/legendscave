const fillUi = document.getElementById('fill-ui');
const water = document.querySelector('.water');
const stream = document.querySelector('.stream');
const progressFill = document.querySelector('.progress-fill');
const percentLabel = document.querySelector('.percent');
let fillTimer = null;

function resetFillUi() {
    if (fillTimer) {
        clearInterval(fillTimer);
        fillTimer = null;
    }

    water.style.height = '0%';
    progressFill.style.width = '0%';
    percentLabel.textContent = '0%';
    stream.classList.remove('active');
    fillUi.classList.remove('visible');
    fillUi.classList.add('hidden');
}

function updateProgress(progress) {
    const clamped = Math.min(Math.max(progress, 0), 100);
    water.style.height = `${clamped}%`;
    progressFill.style.width = `${clamped}%`;
    percentLabel.textContent = `${Math.round(clamped)}%`;
}

function startFill(duration) {
    resetFillUi();

    fillUi.classList.remove('hidden');
    requestAnimationFrame(() => {
        fillUi.classList.add('visible');
        stream.classList.add('active');
    });

    const totalMs = Math.max(duration || 7000, 5000);
    const stepMs = 50;
    const steps = Math.ceil(totalMs / stepMs);
    let currentStep = 0;

    fillTimer = setInterval(() => {
        currentStep += 1;
        const progress = Math.min((currentStep / steps) * 100, 100);
        updateProgress(progress);

        if (currentStep >= steps) {
            updateProgress(100);
            clearInterval(fillTimer);
            fillTimer = null;
        }
    }, stepMs);
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (!data || !data.action) {
        return;
    }

    if (data.action === 'startFill') {
        startFill(data.duration);
    }

    if (data.action === 'hideFill') {
        resetFillUi();
    }
});
