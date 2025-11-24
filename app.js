/**
 * Nurture PWA Logic
 * Stores data in localStorage under 'nurture_data'
 */

// --- State Management ---
let state = {
    events: [], // Unified list of feeds and diapers
    settings: {
        intervalMinutes: 150, // 2.5 hours
        theme: 'dark',
        sound: 'chime1',
        defaultFormulaType: '',
        defaultBreastfeedingSide: 'Both'
    },
    viewMode: 'countdown' // 'countdown' or 'stopwatch'
};

// --- DOM Elements ---
const els = {
    clock: document.getElementById('live-clock'),
    mainDisplay: document.getElementById('main-display'),
    subDisplay: document.getElementById('sub-display'),
    encouragement: document.getElementById('encouragement'),
    feedListPreview: document.getElementById('feed-list-preview'),
    feedListFull: document.getElementById('feed-list-full'),
    toggleCountdown: document.getElementById('toggle-countdown'),
    toggleStopwatch: document.getElementById('toggle-stopwatch'),
    startBtn: document.getElementById('btn-start-feed'),
    btnSettings: document.getElementById('btn-settings'),
    btnStats: document.getElementById('btn-view-stats'),
    views: {
        home: document.getElementById('view-home'),
        stats: document.getElementById('view-stats'),
        settings: document.getElementById('view-settings'),
        howto: document.getElementById('view-howto')
    },
    inputs: {
        theme: document.getElementById('setting-theme'),
        interval: document.getElementById('setting-interval'),
        sound: document.getElementById('setting-sound'),
        formulaType: document.getElementById('setting-formula-type'),
        testNotify: document.getElementById('btn-test-notify')
    },
    modal: {
        overlay: document.getElementById('modal-edit'),
        time: document.getElementById('edit-time'),
        typeGroup: document.getElementById('edit-type-group'),
        typeInput: document.getElementById('edit-type'),
        amount: document.getElementById('edit-amount'),
        duration: document.getElementById('edit-duration'),
        formulaType: document.getElementById('edit-formula-type'),
        notes: document.getElementById('edit-notes'),
        id: document.getElementById('edit-id'),
        saveBtn: document.getElementById('btn-save-entry'),
        delBtn: document.getElementById('btn-delete-entry'),
        speedButtons: document.getElementById('speed-buttons')
    }
};

const messages = [
    "You're doing great!", "One feed at a time.", "You got this!",
    "Deep breaths.", "Remember to hydrate.", "Super parent mode: ON",
    "Doing an amazing job.", "Love grows here."
];

// --- Initialization ---
function init() {
    loadData();
    applyTheme();
    setupEventListeners();
    startClock();
    renderEvents();
    updateTimerDisplay();

    // Check notification permission on load, but don't request it yet
    if ("Notification" in window && Notification.permission === "granted") {
        // Permission already granted
    }

    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('./service-worker.js');
    }
}

// --- Data Persistence ---
function loadData() {
    const stored = localStorage.getItem('nurture_data');
    if (stored) {
        const parsed = JSON.parse(stored);
        // Migration: if 'feeds' exists but 'events' doesn't, rename it
        if (parsed.feeds && !parsed.events) {
            state.events = parsed.feeds.map(f => ({ ...f, category: 'feed' }));
        } else {
            state.events = parsed.events || [];
        }
        state.settings = { ...state.settings, ...parsed.settings };
    }
    // Sync settings UI
    els.inputs.theme.value = state.settings.theme;
    els.inputs.interval.value = state.settings.intervalMinutes;
    els.inputs.sound.value = state.settings.sound;
    if (els.inputs.formulaType) els.inputs.formulaType.value = state.settings.defaultFormulaType || '';
}

function saveData() {
    localStorage.setItem('nurture_data', JSON.stringify({
        events: state.events,
        settings: state.settings
    }));
}

// --- Timer Logic ---
function startClock() {
    setInterval(() => {
        const now = new Date();
        els.clock.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        updateTimerDisplay();
    }, 1000);
}

function updateTimerDisplay() {
    const feeds = state.events.filter(e => e.category === 'feed');

    if (feeds.length === 0) {
        els.mainDisplay.textContent = "--:--";
        els.subDisplay.textContent = "No feeds recorded yet";
        return;
    }

    const lastFeed = feeds[0]; // Events are sorted DESC
    const lastTime = new Date(lastFeed.timestamp).getTime();
    const now = Date.now();
    const intervalMs = state.settings.intervalMinutes * 60 * 1000;
    const nextFeedTime = lastTime + intervalMs;

    if (state.viewMode === 'countdown') {
        const diff = nextFeedTime - now;

        if (diff <= 0) {
            // Overdue
            els.mainDisplay.textContent = "00:00";
            els.mainDisplay.style.color = "var(--danger-color)";
            els.subDisplay.textContent = "Feed Overdue";
        } else {
            els.mainDisplay.textContent = formatMs(diff);
            els.mainDisplay.style.color = "var(--text-primary)";
            els.subDisplay.textContent = `Due at ${new Date(nextFeedTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
        }

        checkAlarm(diff);

    } else {
        // Stopwatch
        const diff = now - lastTime;
        els.mainDisplay.textContent = formatMs(diff);
        els.mainDisplay.style.color = "var(--text-primary)";
        els.subDisplay.textContent = `Last feed: ${new Date(lastTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
    }
}

let alarmTriggered = false;
function checkAlarm(diff) {
    // Trigger alarm if we cross the 0 threshold (approx) and haven't triggered yet
    if (diff <= 0 && diff > -5000 && !alarmTriggered) {
        alarmTriggered = true;
        sendNotification();
        playChime(state.settings.sound);
    }
    // Reset alarm trigger if user adds a feed
    if (diff > 0) alarmTriggered = false;
}

function formatMs(ms) {
    const totalSeconds = Math.floor(Math.abs(ms) / 1000);
    const h = Math.floor(totalSeconds / 3600);
    const m = Math.floor((totalSeconds % 3600) / 60);
    const s = totalSeconds % 60;
    if (h > 0) return `${h}:${pad(m)}:${pad(s)}`;
    return `${m}:${pad(s)}`;
}

function pad(num) { return num.toString().padStart(2, '0'); }

// --- Core Actions ---
function startFeed() {
    const now = new Date();
    const newFeed = {
        id: Date.now().toString(),
        timestamp: now.toISOString(),
        category: 'feed',
        type: state.settings.defaultBreastfeedingSide || 'Both',
        amount: '',
        duration: '',
        formulaType: state.settings.defaultFormulaType || '',
        notes: ''
    };

    state.events.unshift(newFeed); // Add to beginning
    saveData();
    renderEvents();
    updateTimerDisplay();

    // Random Encouragement
    els.encouragement.textContent = messages[Math.floor(Math.random() * messages.length)];

    // Reset alarm state
    alarmTriggered = false;
}

function logDiaper(type) {
    const now = new Date();
    const newDiaper = {
        id: Date.now().toString(),
        timestamp: now.toISOString(),
        category: 'diaper',
        type: type, // 'Wet', 'Dirty', 'Both'
        notes: ''
    };

    state.events.unshift(newDiaper);
    saveData();
    renderEvents();
}

// --- Rendering Events ---
function renderEvents() {
    // Sort Descending
    state.events.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    const html = state.events.map(event => {
        const date = new Date(event.timestamp);
        const timeStr = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        const dateStr = date.toLocaleDateString();

        let icon = '';
        let info = '';
        let classes = 'feed-item';

        if (event.category === 'feed') {
            icon = '🤱';
            let details = [event.type];
            if (event.amount) details.push(`${event.amount}ml`);
            if (event.duration) details.push(`${event.duration}m`);
            if (event.type === 'Formula' && event.formulaType) details.push(event.formulaType);
            info = details.join(' • ');
        } else if (event.category === 'diaper') {
            classes += ' diaper-item';
            if (event.type === 'Wet') icon = '🌊';
            else if (event.type === 'Dirty') icon = '💩';
            else icon = '🌊💩'; // Both
            info = `${event.type} Diaper`;
        }

        return `
            <li class="${classes}" onclick="openEditModal('${event.id}')">
                <div class="feed-icon">${icon}</div>
                <div class="feed-info">
                    <h4>${timeStr} <span style="font-weight:400; opacity:0.7; font-size:0.8em">(${dateStr})</span></h4>
                    <p>${info} ${event.notes ? '• 📝' : ''}</p>
                </div>
                <button class="feed-edit-btn">Edit</button>
            </li>
        `;
    }).join('');

    els.feedListPreview.innerHTML = html;
    els.feedListFull.innerHTML = html;

    renderStats();
}

// --- Stats ---
function renderStats() {
    if (!state.events.length) return;

    const now = Date.now();
    const oneDay = 24 * 60 * 60 * 1000;

    const feeds = state.events.filter(e => e.category === 'feed');
    const diapers = state.events.filter(e => e.category === 'diaper');

    // Feeds last 24h
    const feeds24h = feeds.filter(f => (now - new Date(f.timestamp).getTime()) < oneDay);
    document.getElementById('stat-count-24').textContent = feeds24h.length;

    // Avg Interval (Feeds)
    if (feeds.length > 1) {
        let totalDiff = 0;
        let count = 0;
        for (let i = 0; i < Math.min(feeds.length - 1, 10); i++) {
            const t1 = new Date(feeds[i].timestamp);
            const t2 = new Date(feeds[i + 1].timestamp);
            totalDiff += (t1 - t2);
            count++;
        }
        const avgMs = totalDiff / count;
        const avgHrs = (avgMs / (1000 * 60 * 60)).toFixed(1);
        document.getElementById('stat-avg-time').textContent = `${avgHrs}h`;
    } else {
        document.getElementById('stat-avg-time').textContent = '--';
    }

    // Diaper Stats (24h)
    const diapers24h = diapers.filter(d => (now - new Date(d.timestamp).getTime()) < oneDay);
    const wetCount = diapers24h.filter(d => d.type === 'Wet' || d.type === 'Both').length;
    const dirtyCount = diapers24h.filter(d => d.type === 'Dirty' || d.type === 'Both').length;

    if (document.getElementById('stat-wet-24')) {
        document.getElementById('stat-wet-24').textContent = wetCount;
        document.getElementById('stat-dirty-24').textContent = dirtyCount;
    }
}

// --- Modals & Editing ---
function openEditModal(id) {
    const event = state.events.find(f => f.id === id);
    if (!event) return;

    els.modal.id.value = event.id;
    // Format datetime-local: YYYY-MM-DDThh:mm
    const d = new Date(event.timestamp);
    d.setMinutes(d.getMinutes() - d.getTimezoneOffset());
    els.modal.time.value = d.toISOString().slice(0, 16);

    els.modal.typeInput.value = event.type || 'Left';
    updateChipUI(event.type || 'Left');

    els.modal.notes.value = event.notes || '';

    // Show/Hide fields based on category
    const feedFields = document.querySelectorAll('.feed-only');
    const formulaFields = document.querySelectorAll('.formula-only');

    if (event.category === 'feed') {
        feedFields.forEach(el => el.classList.remove('hidden'));
        els.modal.amount.value = event.amount || '';
        els.modal.duration.value = event.duration || '';
        els.modal.formulaType.value = event.formulaType || '';

        // Show formula fields only if type is Formula
        if (event.type === 'Formula') {
            formulaFields.forEach(el => el.classList.remove('hidden'));
        } else {
            formulaFields.forEach(el => el.classList.add('hidden'));
        }

        // Update chips for Feed
        renderTypeChips(['Left', 'Right', 'Both', 'Bottle', 'Formula']);

    } else {
        // Diaper
        feedFields.forEach(el => el.classList.add('hidden'));
        formulaFields.forEach(el => el.classList.add('hidden'));

        // Update chips for Diaper
        renderTypeChips(['Wet', 'Dirty', 'Both']);
    }

    updateChipUI(event.type);

    els.modal.overlay.classList.remove('hidden');
}

function renderTypeChips(types) {
    els.modal.typeGroup.innerHTML = types.map(t =>
        `<button class="chip" data-val="${t}">${t}</button>`
    ).join('');
}

function closeEditModal() {
    els.modal.overlay.classList.add('hidden');
}

function saveEdit() {
    const id = els.modal.id.value;
    const idx = state.events.findIndex(f => f.id === id);
    if (idx > -1) {
        const current = state.events[idx];
        const updates = {
            timestamp: new Date(els.modal.time.value).toISOString(),
            type: els.modal.typeInput.value,
            notes: els.modal.notes.value
        };

        if (current.category === 'feed') {
            updates.amount = els.modal.amount.value;
            updates.duration = els.modal.duration.value;
            updates.formulaType = els.modal.formulaType.value;
        }

        state.events[idx] = { ...current, ...updates };
        saveData();
        renderEvents();
        closeEditModal();
    }
}

function deleteEntry() {
    if (!confirm("Delete this entry?")) return;
    const id = els.modal.id.value;
    state.events = state.events.filter(f => f.id !== id);
    saveData();
    renderEvents();
    closeEditModal();
}

// --- UI Helpers ---
function updateChipUI(val) {
    document.querySelectorAll('.chip').forEach(c => {
        if (c.dataset.val === val) c.classList.add('selected');
        else c.classList.remove('selected');
    });
    els.modal.typeInput.value = val;

    // Toggle formula fields if needed
    const formulaFields = document.querySelectorAll('.formula-only');
    if (val === 'Formula') {
        formulaFields.forEach(el => el.classList.remove('hidden'));
        // Pre-fill if empty
        if (!els.modal.formulaType.value) els.modal.formulaType.value = state.settings.defaultFormulaType || '';
    } else {
        formulaFields.forEach(el => el.classList.add('hidden'));
    }
}

function showView(viewName) {
    Object.values(els.views).forEach(el => el.classList.add('hidden'));
    if (els.views[viewName]) {
        els.views[viewName].classList.remove('hidden');
    }
}

function applyTheme() {
    document.body.setAttribute('data-theme', state.settings.theme);
}

// --- Audio (Web Audio API Synthesis) ---
const AudioContext = window.AudioContext || window.webkitAudioContext;
const audioCtx = new AudioContext();

function playChime(type) {
    if (audioCtx.state === 'suspended') audioCtx.resume();

    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.connect(gain);
    gain.connect(audioCtx.destination);

    const now = audioCtx.currentTime;

    if (type === 'chime1') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(440, now);
        osc.frequency.exponentialRampToValueAtTime(880, now + 0.5);
        gain.gain.setValueAtTime(0.1, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 1.5);
        osc.start(now);
        osc.stop(now + 1.5);
    } else if (type === 'chime2') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(600, now);
        gain.gain.setValueAtTime(0.1, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 2);
        osc.start(now);
        osc.stop(now + 2);
    } else {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(300, now);
        osc.frequency.linearRampToValueAtTime(500, now + 0.1);
        osc.frequency.linearRampToValueAtTime(800, now + 0.2);
        gain.gain.setValueAtTime(0.05, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 3);
        osc.start(now);
        osc.stop(now + 3);
    }
}

// --- Notifications ---
function requestNotificationPermission() {
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notifications");
        return;
    }

    Notification.requestPermission().then(permission => {
        if (permission === "granted") {
            new Notification("Notifications Enabled", {
                body: "You will now receive feeding reminders.",
                icon: 'icons/icon-192.png'
            });
        } else {
            alert("Notifications were denied. Please enable them in your browser settings.");
        }
    });
}

function sendNotification() {
    if (Notification.permission === "granted") {
        const intervalHr = (state.settings.intervalMinutes / 60).toFixed(1);

        // Try Service Worker registration first for mobile support
        if (navigator.serviceWorker && navigator.serviceWorker.controller) {
            navigator.serviceWorker.controller.postMessage({
                type: 'notify',
                title: "Time to Feed!",
                body: `${intervalHr} hours have passed since the last feed.`
            });
        } else {
            // Fallback to standard API
            new Notification("Time to Feed!", {
                body: `${intervalHr} hours have passed since the last feed.`,
                icon: 'icons/icon-192.png'
            });
        }
    }
}

// --- Event Listeners ---
function setupEventListeners() {
    // Toggles
    els.toggleCountdown.onclick = () => {
        state.viewMode = 'countdown';
        els.toggleCountdown.classList.add('active');
        els.toggleStopwatch.classList.remove('active');
        updateTimerDisplay();
    };
    els.toggleStopwatch.onclick = () => {
        state.viewMode = 'stopwatch';
        els.toggleStopwatch.classList.add('active');
        els.toggleCountdown.classList.remove('active');
        updateTimerDisplay();
    };

    // Buttons
    els.startBtn.onclick = startFeed;
    els.btnSettings.onclick = () => showView('settings');
    els.btnStats.onclick = () => showView('stats');

    // Diaper Buttons (Delegation or direct if added dynamically, but better to bind if they exist)
    // Note: These will be added to HTML next, so we bind them here assuming existence or use delegation
    document.body.addEventListener('click', (e) => {
        if (e.target.closest('.btn-diaper')) {
            const type = e.target.closest('.btn-diaper').dataset.type;
            logDiaper(type);
        }
        if (e.target.classList.contains('speed-btn')) {
            els.modal.duration.value = e.target.dataset.val;
        }
    });

    // Modal actions
    els.modal.saveBtn.onclick = saveEdit;
    els.modal.delBtn.onclick = deleteEntry;
    els.modal.typeGroup.addEventListener('click', (e) => {
        if (e.target.classList.contains('chip')) updateChipUI(e.target.dataset.val);
    });

    // Settings inputs
    els.inputs.theme.onchange = (e) => {
        state.settings.theme = e.target.value;
        applyTheme();
        saveData();
    };
    els.inputs.interval.onchange = (e) => {
        state.settings.intervalMinutes = parseInt(e.target.value);
        saveData();
        updateTimerDisplay();
    };
    els.inputs.sound.onchange = (e) => {
        state.settings.sound = e.target.value;
        saveData();
    };
    if (els.inputs.formulaType) {
        els.inputs.formulaType.onchange = (e) => {
            state.settings.defaultFormulaType = e.target.value;
            saveData();
        };
    }

    if (els.inputs.testNotify) {
        els.inputs.testNotify.onclick = () => {
            if (Notification.permission !== 'granted') {
                requestNotificationPermission();
            } else {
                sendNotification();
            }
        };
    }

    document.getElementById('btn-test-sound').onclick = () => playChime(state.settings.sound);
    document.getElementById('btn-clear-data').onclick = () => {
        if (confirm("Delete ALL history? This cannot be undone.")) {
            state.events = [];
            saveData();
            renderEvents();
        }
    };
    document.getElementById('btn-export').onclick = () => {
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state.events));
        const downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href", dataStr);
        downloadAnchorNode.setAttribute("download", "nurture_history.json");
        document.body.appendChild(downloadAnchorNode);
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
    };

    document.getElementById('btn-import').onclick = () => {
        document.getElementById('file-import').click();
    };

    document.getElementById('file-import').onchange = (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                const importedData = JSON.parse(event.target.result);

                // Basic Validation
                if (!Array.isArray(importedData) && !importedData.events) {
                    alert("Invalid file format. Expected Nurture JSON export.");
                    return;
                }

                // Handle both old array format and new object format
                let newEvents = [];
                if (Array.isArray(importedData)) {
                    newEvents = importedData;
                } else {
                    newEvents = importedData.events || [];
                    // Merge settings if present? Let's stick to events for now to avoid overwriting preferences unexpectedly, 
                    // or maybe ask? For simplicity, let's just import events.
                }

                if (confirm(`Found ${newEvents.length} entries. Merge with existing data?`)) {
                    // Merge Strategy: Add only if ID doesn't exist
                    let addedCount = 0;
                    const existingIds = new Set(state.events.map(e => e.id));

                    newEvents.forEach(evt => {
                        if (!existingIds.has(evt.id)) {
                            state.events.push(evt);
                            existingIds.add(evt.id);
                            addedCount++;
                        }
                    });

                    state.events.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
                    saveData();
                    renderEvents();
                    updateTimerDisplay();
                    alert(`Import successful! Added ${addedCount} new entries.`);
                }
            } catch (err) {
                console.error(err);
                alert("Error parsing file. Please ensure it is a valid JSON file.");
            }
            // Reset input
            e.target.value = '';
        };
        reader.readAsText(file);
    };

    // How-to Link
    document.getElementById('btn-howto-link').onclick = () => showView('howto');

    // Onboarding
    document.getElementById('btn-finish-onboarding').onclick = () => {
        document.getElementById('modal-onboarding').classList.add('hidden');
        localStorage.setItem('nurture_has_visited', 'true');
    };
}

function checkOnboarding() {
    if (!localStorage.getItem('nurture_has_visited')) {
        document.getElementById('modal-onboarding').classList.remove('hidden');
    }
}

// Init App
document.addEventListener('DOMContentLoaded', () => {
    init();
    checkOnboarding();
});
