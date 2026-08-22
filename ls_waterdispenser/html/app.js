const nuiRoot = document.getElementById('nui-root');
const fillUi = document.getElementById('fill-ui');
const water = document.querySelector('.water');
const stream = document.querySelector('.stream');
const progressFill = document.querySelector('.progress-fill');
const percentLabel = document.querySelector('.percent');
let fillTimer = null;

function setOpen(open) {
    if (!fillUi) return;
    if (open) {
        fillUi.classList.remove('hidden');
        if (stream) stream.classList.add('active');
    } else {
        fillUi.classList.add('hidden');
        if (stream) stream.classList.remove('active');
    }
}

function updateProgress(p) {
    const v = Math.min(Math.max(p, 0), 100);
    if (water) water.style.height = v + '%';
    if (progressFill) progressFill.style.width = v + '%';
    if (percentLabel) percentLabel.textContent = Math.round(v) + '%';
}

function startFill(duration) {
    if (fillTimer) clearInterval(fillTimer);
    updateProgress(0);
    setOpen(true);

    // Keep far right (never center — was blocking the player)
    if (nuiRoot) {
        nuiRoot.style.justifyContent = 'flex-end';
        nuiRoot.style.alignItems = 'flex-end';
        nuiRoot.style.padding = '0 8px 110px 0';
    }

    const totalMs = Math.max(Number(duration) || 7000, 5000);
    const stepMs = 50;
    const steps = Math.ceil(totalMs / stepMs);
    let step = 0;

    fillTimer = setInterval(() => {
        step += 1;
        updateProgress((step / steps) * 100);
        if (step >= steps) {
            updateProgress(100);
            clearInterval(fillTimer);
            fillTimer = null;
        }
    }, stepMs);
}

function hideFill() {
    if (fillTimer) {
        clearInterval(fillTimer);
        fillTimer = null;
    }
    updateProgress(0);
    setOpen(false);
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;
    if (data.action === 'startFill') startFill(data.duration);
    if (data.action === 'hideFill') hideFill();
});
