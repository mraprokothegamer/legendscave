const nuiRoot = document.getElementById('nui-root');
const fillUi = document.getElementById('fill-ui');
const water = document.querySelector('.water');
const stream = document.querySelector('.stream');
const progressFill = document.querySelector('.progress-fill');
const percentLabel = document.querySelector('.percent');

let fillTimer = null;
let failsafeTimer = null;
let completeTimer = null;

function clearTimers() {
    if (fillTimer) { clearInterval(fillTimer); fillTimer = null; }
    if (failsafeTimer) { clearTimeout(failsafeTimer); failsafeTimer = null; }
    if (completeTimer) { clearTimeout(completeTimer); completeTimer = null; }
}

function applyNearPlayerLayout() {
    if (!nuiRoot) return;
    nuiRoot.style.justifyContent = 'center';
    nuiRoot.style.alignItems = 'flex-end';
    nuiRoot.style.padding = '0 0 20vh 26vw';
}

function setOpen(open) {
    if (!fillUi) return;
    if (open) {
        fillUi.classList.remove('hidden');
        fillUi.style.cssText = 'display:block;visibility:visible;opacity:1;';
        if (stream) stream.classList.add('active');
    } else {
        fillUi.classList.add('hidden');
        fillUi.style.cssText = 'display:none !important;visibility:hidden;opacity:0;';
        if (stream) stream.classList.remove('active');
    }
}

function updateProgress(p) {
    const v = Math.min(Math.max(p, 0), 100);
    if (water) water.style.height = v + '%';
    if (progressFill) progressFill.style.width = v + '%';
    if (percentLabel) percentLabel.textContent = Math.round(v) + '%';
}

function hideFill() {
    clearTimers();
    updateProgress(0);
    setOpen(false);
}

function startFill(duration) {
    hideFill();
    applyNearPlayerLayout();
    setOpen(true);

    const totalMs = Math.max(Number(duration) || 10000, 5000);
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

            // Hide NUI right after fill reaches 100%
            completeTimer = setTimeout(() => {
                hideFill();
            }, 400);
        }
    }, stepMs);

    // Hard failsafe — always hide
    failsafeTimer = setTimeout(() => {
        hideFill();
    }, totalMs + 1500);
}

applyNearPlayerLayout();
setOpen(false);

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'startFill') {
        startFill(data.duration);
    }

    if (data.action === 'hideFill' || data.action === 'forceHide') {
        hideFill();
    }
});
