const fillUi = document.getElementById('fill-ui');
const water = document.querySelector('.water');
const stream = document.querySelector('.stream');
let fillTimer = null;

function resetFillUi() {
    if (fillTimer) {
        clearInterval(fillTimer);
        fillTimer = null;
    }

    water.style.height = '0%';
    stream.classList.remove('active');
    fillUi.classList.remove('visible');
    fillUi.classList.add('hidden');
}

function startFill(duration) {
    resetFillUi();

    fillUi.classList.remove('hidden');
    requestAnimationFrame(() => {
        fillUi.classList.add('visible');
        stream.classList.add('active');
    });

    const totalMs = Math.max(duration || 1800, 500);
    const stepMs = 50;
    const steps = Math.ceil(totalMs / stepMs);
    let currentStep = 0;

    fillTimer = setInterval(() => {
        currentStep += 1;
        const progress = Math.min((currentStep / steps) * 100, 100);
        water.style.height = `${progress}%`;

        if (currentStep >= steps) {
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
