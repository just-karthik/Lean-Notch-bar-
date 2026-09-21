# NotchTodo 📋

A lightweight, distraction-free macOS to-do checklist and reminder app that lives directly in your MacBook's notch.

- **Unobtrusive:** Runs as a background agent (`LSUIElement`) with no Dock icon cluttering your workspace.
- **Dynamic Notch Integration:** Anchored seamlessly to your MacBook camera notch. Click the notch pill to drop down your checklist; click outside or hit `Esc` to collapse.
- **Checklist & Due Date Reminders:** Add tasks with optional reminders (`Today 5pm`, `Tomorrow 9am`, or custom time) using native macOS local banner alerts.
- **Local & Private:** Everything is stored locally on your device in `~/Library/Application Support/NotchTodo/tasks.json`.
- **Zero Local Xcode Required:** Builds in the cloud via GitHub Actions on-demand to keep your runner minutes strictly under control.

---

## 🚀 How to Build & Install via GitHub Actions

Because macOS GitHub Actions runners consume quota at a higher rate, the included workflow is configured for **on-demand manual trigger (`workflow_dispatch`)**. It will never run automatically on every push, ensuring you only use minutes when you actually want a new build!

### Step 1: Create a GitHub Repository & Push Your Code

1. Create a new repository on [GitHub](https://github.com/new) (e.g. `notch-todo`).
2. In your terminal inside this folder, run:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of NotchTodo"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/notch-todo.git
   git push -u origin main
   ```

---

### Step 2: Trigger the Build in GitHub Actions

1. Go to your repository on GitHub in your browser.
2. Click the **Actions** tab at the top.
3. In the left sidebar, click **"Build NotchTodo App"**.
4. Click the **"Run workflow"** dropdown button on the right, and click the green **"Run workflow"** button.
5. The build will start on a fresh `macos-14` runner and takes roughly **1 to 2 minutes** to compile and package.

---

### Step 3: Download & Install on Your Mac

1. Once the workflow run finishes with a green checkmark, click into that run.
2. Scroll down to the **Artifacts** section at the bottom of the page.
3. Click **`NotchTodo-macOS`** to download `NotchTodo.zip`.
4. Double-click the downloaded `NotchTodo.zip` to extract `NotchTodo.app`.
5. Drag `NotchTodo.app` into your Mac's `/Applications` folder.

---

### Step 4: First-Time Launch (One-Time Gatekeeper Bypass)

Because this personal app is not notarized with a $99/year Apple Developer certificate, macOS Gatekeeper requires a one-time approval before the first launch:

Open your **Terminal** and run:
```bash
xattr -dr com.apple.quarantine /Applications/NotchTodo.app
```

Then open `NotchTodo.app` by double-clicking it in your Applications folder or via Spotlight (`Cmd + Space` -> `NotchTodo`).

---

## 💡 How to Use

- **Notch Bar Pill:** You will see a sleek pill at the top center of your screen showing your pending task count (e.g. `1 task`).
- **Expand / Open:** Click the pill with your mouse. The notch expands smoothly into the task card.
- **Add a Task:** Type in the input field and press `Return`.
- **Set a Reminder:** Click the 🔔 bell icon next to the input field to pick a date & time before pressing `Return`.
- **Complete a Task:** Click the circle to mark it done.
- **Collapse / Dismiss:** Click anywhere outside the dropdown or press the `Esc` key.
- **Quit:** Click the power button ⏻ in the bottom right corner of the expanded card.

---

## 📂 Project Structure

```
notchbar app/
├── .github/
│   └── workflows/
│       └── build.yml               # Minimal on-demand GitHub Actions build pipeline
├── NotchTodo/
│   ├── App/
│   │   ├── NotchTodoApp.swift      # Entry point & NSApplicationDelegate (agent mode)
│   │   └── Info.plist              # Bundle metadata (LSUIElement = true)
│   ├── Window/
│   │   ├── NotchPanel.swift        # Floating borderless NSPanel overlay
│   │   └── NotchWindowManager.swift# Notch positioning & outside-click dismissal
│   ├── Models/
│   │   ├── TodoItem.swift          # Task data model
│   │   └── TodoStore.swift         # Local JSON persistence in ~/Library/Application Support/
│   ├── Services/
│   │   └── NotificationManager.swift # Native macOS UserNotifications alerts
│   └── Views/
│       ├── CollapsedNotchView.swift# Sleek notch pill with active task counter
│       ├── ExpandedNotchView.swift # Dropdown card with input bar & filters
│       └── TaskRowView.swift       # Checklist row with checkmark, due badge & delete
├── Package.swift                   # Swift Package Manager manifest
└── README.md                       # Instructions and usage guide
```
