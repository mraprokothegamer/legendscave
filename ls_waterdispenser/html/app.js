const app = document.getElementById("app");
const cup = document.querySelector(".cup");
const water = document.querySelector(".water");
const fill = document.querySelector(".progress-fill");
const sound = document.getElementById("pour-sound");

// Target fill level of the cup (leaves a little headroom at the top).
const WATER_TARGET = "85%";

function startDrink(durationMs, soundFile, volume) {
    const seconds = (durationMs || 5000) / 1000;

    app.classList.remove("hidden");
    cup.classList.add("pouring");

    // Reset instantly (no transition) so repeated uses start from empty.
    water.style.transition = "none";
    water.style.height = "0%";
    fill.style.transition = "none";
    fill.style.width = "0%";

    // Force reflow so the reset is committed before we animate.
    void water.offsetWidth;

    water.style.transition = `height ${seconds}s linear`;
    fill.style.transition = `width ${seconds}s linear`;
    water.style.height = WATER_TARGET;
    fill.style.width = "100%";

    if (soundFile) {
        sound.src = `sounds/${soundFile}`;
        sound.volume = typeof volume === "number" ? volume : 0.5;
        sound.currentTime = 0;
        sound.play().catch(() => {});
    }
}

function stopDrink() {
    cup.classList.remove("pouring");
    app.classList.add("hidden");
    if (!sound.paused) {
        sound.pause();
    }
}

window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.action === "startDrink") {
        startDrink(data.duration, data.sound, data.volume);
    } else if (data.action === "stopDrink") {
        stopDrink();
    }
});

// Dev preview: open html/index.html?demo=1 in a browser to loop the animation
// without a running FiveM server. This never triggers inside the game client
// (CEF loads the page without query params).
if (new URLSearchParams(window.location.search).get("demo") === "1") {
    const duration = 5000;
    const loop = () => {
        startDrink(duration, null, 0.5);
        setTimeout(() => {
            stopDrink();
            setTimeout(loop, 900);
        }, duration);
    };
    loop();
}
