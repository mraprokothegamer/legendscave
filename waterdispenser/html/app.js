const nuiRoot = document.getElementById('nui-root');
const fillUi = document.getElementById('fill-ui');
const water = document.querySelector('.water');
const stream = document.querySelector('.stream');
const progressFill = document.querySelector('.progress-fill');
const percentLabel = document.querySelector('.percent');
let fillTimer = null;

function applyPosition(position, paddingRight) {
    if (!nuiRoot) return;

    nuiRoot.classList.remove('pos-bottom-right', 'pos-bottom-left');

    if (position === 'bottom-left') {
        nuiRoot.classList.add('pos-bottom-left');
        nuiRoot.style.padding = '0 0 100px 32px';
        return;
    }

    nuiRoot.classList.add('pos-bottom-right');
    const pad = Number(paddingRight);
    const safePad = Number.isFinite(pad) ? pad : 4;
    nuiRoot.style.padding = `0 ${safePad}px 100px 0`;
}

function setFillOpen(isOpen) {
    if (!fillUi) return;

    if (isOpen) {
        fillUi.classList.remove('hidden');
        fillUi.classList.add('visible');
    } else {
        fillUi.classList.remove('visible');
        fillUi.classList.add('hidden');
    }
}

function resetFillUi() {
    if (fillTimer) {
        clearInterval(fillTimer);
        fillTimer = null;
    }

    if (water) water.style.height = '0%';
    if (progressFill) progressFill.style.width = '0%';
    if (percentLabel) percentLabel.textContent = '0%';
    if (stream) stream.classList.remove('active');
    setFillOpen(false);
}

function updateProgress(progress) {
    const clamped = Math.min(Math.max(progress, 0), 100);
    if (water) water.style.height = `${clamped}%`;
    if (progressFill) progressFill.style.width = `${clamped}%`;
    if (percentLabel) percentLabel.textContent = `${Math.round(clamped)}%`;
}

function startFill(duration, position, paddingRight) {
    if (fillTimer) {
        clearInterval(fillTimer);
        fillTimer = null;
    }

    if (water) water.style.height = '0%';
    if (progressFill) progressFill.style.width = '0%';
    if (percentLabel) percentLabel.textContent = '0%';

    applyPosition(position || 'bottom-right', paddingRight);
    setFillOpen(true);

    if (stream) stream.classList.add('active');

    const totalMs = Math.max(Number(duration) || 7000, 5000);
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

applyPosition('bottom-right', 4);

window.addEventListener('message', (event) => {
    const data = event.data;

    if (!data || !data.action) {
        return;
    }

    if (data.action === 'startFill') {
        startFill(data.duration, data.position, data.paddingRight);
    }

    if (data.action === 'hideFill') {
        resetFillUi();
    }
});
