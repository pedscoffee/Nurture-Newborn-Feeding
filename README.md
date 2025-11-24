<p align="center">
  <img src="icon.png" alt="Nurture Logo" width="120" height="120">
</p>

<h1 align="center">Nurture</h1>

<p align="center">
  <strong>A calming newborn feeding timer and tracker</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#license">License</a>
</p>

---

## About

**Nurture** is a minimalist, offline-capable Progressive Web App (PWA) designed to help new parents track feeding schedules and diaper changes during those exhausting first months. With gentle reminders, soothing aesthetics, and a focus on simplicity, Nurture helps you stay on top of your newborn's needs without adding stress.

## Features

### 🍼 Feeding Timer
- **Countdown Mode** — See exactly how long until the next scheduled feed
- **Stopwatch Mode** — Track how long since the last feed
- **Customizable Intervals** — Set feeding schedules from 2 to 4 hours
- **Quick Logging** — One tap to log a new feed

### 🧷 Diaper Tracking
- Log wet, dirty, or combo diapers with a single tap
- Track 24-hour diaper counts in the stats view

### 📊 History & Statistics
- View all feeding and diaper history
- See 24-hour feeding counts and average intervals
- Export your data as JSON for backup or analysis

### 🔔 Smart Notifications
- Browser/push notifications when a feed is due
- Soothing synthesized chime sounds (Soft Chime, Gentle Bell, Harp)
- Test sound and notification features in settings

### 🎨 Beautiful Design
- Dark and light theme support
- Calming color palette designed for late-night use
- Responsive mobile-first design
- Encouraging messages to support tired parents

### 📱 PWA Features
- **Install to Home Screen** — Works like a native app
- **Offline Support** — Full functionality without internet
- **Service Worker Caching** — Fast load times

## Installation

### Option 1: Use Online
Simply visit the hosted version and add it to your home screen:
1. Open the app in your mobile browser
2. Tap the browser menu (⋮ or Share icon)
3. Select "Add to Home Screen" or "Install App"

### Option 2: Self-Host
Clone the repository and serve the files:

```bash
git clone https://github.com/pedscoffee/nurture.git
cd nurture
```

Serve with any static file server:

```bash
# Using Python
python -m http.server 8000

# Using Node.js (npx)
npx serve .

# Using PHP
php -S localhost:8000
```

Then open `http://localhost:8000` in your browser.

## Usage

### Quick Start
1. **Start a Feed** — Tap the main "Start Feed" button when beginning a feeding
2. **Track Diapers** — Use the quick buttons (💧 Wet, 💩 Dirty, 💧💩 Both)
3. **View History** — Tap "History & Stats" to see all logged events
4. **Edit Entries** — Tap "Edit" on any entry to modify time, duration, or add notes

### Settings
Access settings via the ⚙️ gear icon:
- **Feed Interval** — Set your target time between feeds
- **Theme** — Switch between dark and light modes
- **Alarm Sound** — Choose your notification chime
- **Default Formula Type** — Pre-fill formula brand for bottle feeds
- **Test Sound/Notification** — Verify alerts are working
- **Clear All Data** — Reset the app (use with caution!)

### Feed Types
When editing a feed, you can specify:
- **Left** / **Right** / **Both** — For breastfeeding
- **Bottle** — For expressed milk
- **Formula** — With optional brand/type field
- **Duration** — Quick buttons for 5-30 minute increments
- **Amount** — Optional ml tracking
- **Notes** — Any additional information

## Screenshots

| Home Screen | History & Stats | Edit Entry |
|:-----------:|:---------------:|:----------:|
| Timer countdown with quick actions | 24h statistics and full history | Modify any logged entry |

## Tech Stack

- **Pure Vanilla JavaScript** — No frameworks, no build step
- **CSS3** — Custom properties, flexbox, grid
- **Web Audio API** — Synthesized notification sounds
- **Service Workers** — Offline caching and background notifications
- **localStorage** — Client-side data persistence
- **PWA Manifest** — Installable web app

## Project Structure

```
nurture/
├── index.html          # Main HTML structure
├── styles.css          # All styling with CSS variables
├── app.js              # Application logic and state management
├── service-worker.js   # PWA caching and offline support
├── manifest.json       # PWA configuration
├── icons/
│   ├── icon-192.png    # App icon (192x192)
│   └── icon-512.png    # App icon (512x512)
├── LICENSE             # MIT License
└── README.md           # This file
```

## Data Privacy

**Your data stays on your device.** Nurture uses `localStorage` exclusively — no data is ever sent to any server. You can export your data anytime as a JSON file for backup.

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with 💜 for sleep-deprived parents everywhere
</p>

<p align="center">
  <sub>© 2025 pedscoffee</sub>
</p>
