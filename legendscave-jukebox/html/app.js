(() => {
  const app = document.getElementById('app');
  const playlistEl = document.getElementById('playlist');
  const playBtn = document.getElementById('playBtn');
  const playIcon = document.getElementById('playIcon');
  const selectBtn = document.getElementById('selectBtn');
  const menuBtn = document.getElementById('menuBtn');
  const eq = document.getElementById('eq');
  const progressFill = document.getElementById('progressFill');
  const elapsedEl = document.getElementById('elapsed');
  const durationEl = document.getElementById('duration');
  const nowTitle = document.getElementById('nowTitle');
  const nowArtist = document.getElementById('nowArtist');
  const lcdStatus = document.getElementById('lcdStatus');
  const ytUrl = document.getElementById('ytUrl');

  let coords = null;
  let playlist = [];
  let playing = false;
  let progressTimer = null;
  let elapsed = 0;
  let duration = 0;
  let activeId = null;
  let view = 'now';
  let focusIndex = 0;

  const resourceName = typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : 'legendscave-jukebox';

  function post(name, data = {}) {
    return fetch(`https://${resourceName}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    });
  }

  function formatTime(seconds) {
    const s = Math.max(0, Math.floor(Number(seconds) || 0));
    const mins = Math.floor(s / 60);
    const secs = s % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  function setView(name) {
    view = name;
    document.querySelectorAll('.lcd-view').forEach((el) => {
      el.classList.toggle('is-active', el.dataset.view === name);
    });
    if (name === 'menu') {
      focusIndex = Math.max(0, playlist.findIndex((t) => t.id === activeId));
      if (focusIndex < 0) focusIndex = 0;
      updateMenuFocus();
    }
  }

  function setPlayingUi(isPlaying) {
    playing = isPlaying;
    playBtn.classList.toggle('is-active', isPlaying);
    eq.classList.toggle('is-playing', isPlaying);
    playIcon.textContent = isPlaying ? '❚❚' : '▶❚❚';
    lcdStatus.textContent = isPlaying ? 'Now Playing' : 'Ready';
  }

  function stopProgress() {
    if (progressTimer) {
      clearInterval(progressTimer);
      progressTimer = null;
    }
    elapsed = 0;
    progressFill.style.width = '0%';
    elapsedEl.textContent = '0:00';
    setPlayingUi(false);
  }

  function startProgress(total, title, artist) {
    stopProgress();
    duration = Math.max(1, Number(total) || 180);
    durationEl.textContent = formatTime(duration);
    if (title) nowTitle.textContent = title;
    if (artist) nowArtist.textContent = artist;
    setPlayingUi(true);
    setView('now');

    progressTimer = setInterval(() => {
      elapsed += 1;
      const percent = Math.min((elapsed / duration) * 100, 100);
      progressFill.style.width = `${percent}%`;
      elapsedEl.textContent = formatTime(elapsed);
      if (percent >= 100) {
        clearInterval(progressTimer);
        progressTimer = null;
        setPlayingUi(false);
      }
    }, 1000);
  }

  function thumbFor(id) {
    return `https://img.youtube.com/vi/${id}/mqdefault.jpg`;
  }

  function extractId(input) {
    if (!input) return null;
    const trimmed = input.trim();
    const watch = trimmed.match(/[?&]v=([\w-]{6,})/);
    if (watch) return watch[1];
    const short = trimmed.match(/youtu\.be\/([\w-]{6,})/);
    if (short) return short[1];
    if (/^[\w-]{6,}$/.test(trimmed)) return trimmed;
    return null;
  }

  function menuItems() {
    return Array.from(playlistEl.querySelectorAll('.track, .menu-action'));
  }

  function updateMenuFocus() {
    const items = menuItems();
    items.forEach((el, i) => {
      el.classList.toggle('is-focus', i === focusIndex);
    });
    const focused = items[focusIndex];
    if (focused) focused.scrollIntoView({ block: 'nearest' });
  }

  function playTrack(track) {
    if (!track) return;
    activeId = track.id;
    nowTitle.textContent = track.title || 'Untitled';
    nowArtist.textContent = track.artist || 'Unknown';
    renderPlaylist();
    post('playTrack', {
      coords,
      id: track.id,
      title: track.title,
      artist: track.artist,
      duration: track.duration,
    });
    setView('now');
  }

  function renderPlaylist() {
    playlistEl.innerHTML = '';
    playlist.forEach((track) => {
      const li = document.createElement('li');
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = `track${track.id === activeId ? ' active' : ''}`;
      btn.innerHTML = `
        <img src="${thumbFor(track.id)}" alt="" loading="lazy" />
        <div class="track-info">
          <span class="title">${track.title || 'Untitled'}</span>
          <span class="artist">${track.artist || 'Unknown'}</span>
        </div>
      `;
      btn.addEventListener('click', () => playTrack(track));
      li.appendChild(btn);
      playlistEl.appendChild(li);
    });

    const urlLi = document.createElement('li');
    const urlBtn = document.createElement('button');
    urlBtn.type = 'button';
    urlBtn.className = 'menu-action';
    urlBtn.textContent = 'Paste YouTube URL ›';
    urlBtn.addEventListener('click', () => setView('url'));
    urlLi.appendChild(urlBtn);
    playlistEl.appendChild(urlLi);

    if (view === 'menu') updateMenuFocus();
  }

  function togglePlay() {
    if (playing) {
      post('stopTrack', { coords });
      stopProgress();
      return;
    }
    if (activeId) {
      const track = playlist.find((t) => t.id === activeId) || playlist[0];
      playTrack(track);
      return;
    }
    if (playlist[0]) playTrack(playlist[0]);
  }

  function selectAction() {
    if (view === 'now') {
      togglePlay();
      return;
    }
    if (view === 'url') {
      document.getElementById('playCustomBtn').click();
      return;
    }
    if (view === 'menu') {
      const items = menuItems();
      const el = items[focusIndex];
      if (el) el.click();
    }
  }

  function openUi(payload) {
    coords = payload.coords || null;
    playlist = Array.isArray(payload.playlist) ? payload.playlist : [];
    app.classList.remove('hidden');
    app.setAttribute('aria-hidden', 'false');
    setView('now');
    renderPlaylist();
  }

  function closeUi() {
    app.classList.add('hidden');
    app.setAttribute('aria-hidden', 'true');
    stopProgress();
    post('close');
  }

  document.getElementById('closeBtn').addEventListener('click', closeUi);

  menuBtn.addEventListener('click', () => {
    if (view === 'menu') setView('now');
    else setView('menu');
  });

  playBtn.addEventListener('click', togglePlay);
  selectBtn.addEventListener('click', selectAction);

  document.getElementById('nextBtn').addEventListener('click', () => {
    if (view === 'menu') {
      const items = menuItems();
      if (!items.length) return;
      focusIndex = (focusIndex + 1) % items.length;
      updateMenuFocus();
      return;
    }
    post('nextTrack', { coords });
  });

  document.getElementById('prevBtn').addEventListener('click', () => {
    if (view === 'menu') {
      const items = menuItems();
      if (!items.length) return;
      focusIndex = (focusIndex - 1 + items.length) % items.length;
      updateMenuFocus();
      return;
    }
    post('prevTrack', { coords });
  });

  document.getElementById('playCustomBtn').addEventListener('click', () => {
    const raw = ytUrl.value.trim();
    if (!raw) return;
    const id = extractId(raw);
    post('playTrack', {
      coords,
      url: raw,
      id: id || undefined,
      title: 'Custom Track',
      artist: 'YouTube',
      duration: 200,
    });
    nowTitle.textContent = 'Custom Track';
    nowArtist.textContent = 'YouTube';
    activeId = id;
    renderPlaylist();
    setView('now');
  });

  window.addEventListener('keydown', (e) => {
    if (app.classList.contains('hidden')) return;
    if (e.key === 'Escape') {
      if (view !== 'now') {
        setView(view === 'url' ? 'menu' : 'now');
        return;
      }
      closeUi();
    }
  });

  window.addEventListener('message', (event) => {
    const data = event.data || {};
    switch (data.action) {
      case 'open':
        openUi(data);
        break;
      case 'startProgress':
        startProgress(data.duration, data.title, data.artist);
        break;
      case 'stopProgress':
        stopProgress();
        break;
      default:
        break;
    }
  });
})();
