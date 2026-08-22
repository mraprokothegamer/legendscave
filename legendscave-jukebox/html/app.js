(() => {
  const app = document.getElementById('app');
  const playlistEl = document.getElementById('playlist');
  const playBtn = document.getElementById('playBtn');
  const playIcon = document.getElementById('playIcon');
  const eq = document.getElementById('eq');
  const progressFill = document.getElementById('progressFill');
  const elapsedEl = document.getElementById('elapsed');
  const durationEl = document.getElementById('duration');
  const nowTitle = document.getElementById('nowTitle');
  const nowArtist = document.getElementById('nowArtist');
  const ytUrl = document.getElementById('ytUrl');

  let coords = null;
  let playlist = [];
  let playing = false;
  let progressTimer = null;
  let elapsed = 0;
  let duration = 0;
  let activeId = null;

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

  function setPlayingUi(isPlaying) {
    playing = isPlaying;
    playBtn.classList.toggle('is-active', isPlaying);
    eq.classList.toggle('is-playing', isPlaying);
    playIcon.textContent = isPlaying ? '■' : '▶';
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

  function renderPlaylist() {
    playlistEl.innerHTML = '';
    playlist.forEach((track) => {
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
      btn.addEventListener('click', () => {
        activeId = track.id;
        renderPlaylist();
        nowTitle.textContent = track.title;
        nowArtist.textContent = track.artist;
        post('playTrack', {
          coords,
          id: track.id,
          title: track.title,
          artist: track.artist,
          duration: track.duration,
        });
      });
      playlistEl.appendChild(btn);
    });
  }

  function openUi(payload) {
    coords = payload.coords || null;
    playlist = Array.isArray(payload.playlist) ? payload.playlist : [];
    app.classList.remove('hidden');
    app.setAttribute('aria-hidden', 'false');
    renderPlaylist();
  }

  function closeUi() {
    app.classList.add('hidden');
    app.setAttribute('aria-hidden', 'true');
    stopProgress();
    post('close');
  }

  document.getElementById('closeBtn').addEventListener('click', closeUi);

  playBtn.addEventListener('click', () => {
    if (playing) {
      post('stopTrack', { coords });
      stopProgress();
      return;
    }
    if (activeId) {
      const track = playlist.find((t) => t.id === activeId) || playlist[0];
      if (!track) return;
      post('playTrack', {
        coords,
        id: track.id,
        title: track.title,
        artist: track.artist,
        duration: track.duration,
      });
      return;
    }
    if (playlist[0]) {
      activeId = playlist[0].id;
      renderPlaylist();
      post('playTrack', {
        coords,
        id: playlist[0].id,
        title: playlist[0].title,
        artist: playlist[0].artist,
        duration: playlist[0].duration,
      });
    }
  });

  document.getElementById('stopBtn').addEventListener('click', () => {
    post('stopTrack', { coords });
    stopProgress();
  });

  document.getElementById('nextBtn').addEventListener('click', () => {
    post('nextTrack', { coords });
  });

  document.getElementById('prevBtn').addEventListener('click', () => {
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
  });

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !app.classList.contains('hidden')) {
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
