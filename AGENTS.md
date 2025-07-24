This file provides guidelines and structure for GPT/Codex agents contributing to this repository.

🧩 Project Overview
Game Mechanics Hub is a desktop launcher built with Electron (JavaScript/HTML/CSS) that serves as a modular testbed for independent Godot mechanics (e.g. morality systems, puzzles, paranoia AI).

Frontend: Electron (with HTML/CSS)

Gameplay Modules: Godot mini-projects (each in /modules)

State & Metadata: Stored as JSON (e.g., module name, status, tags)

📁 Folder Structure
java
Copy
Edit
/public               → Main HTML, CSS files
/modules              → Individual Godot game mechanics (scenes)
/main.js              → Electron main process
/package.json         → App metadata and dependencies
/README.md            → Project introduction and install steps
/AGENTS.md            → Codex-specific agent guide (this file)
🧠 Agent Guidelines
🔘 UI Behavior
Main menu includes:

New Module

Load Module

View All Modules

Settings

Submenus must include a "Back" button returning to the main view.

Use .submenu classes for submenu styling and layout consistency.

Layout is vertical and simple, no visual clutter.

🐞 Debug Tool
A debug console toggle should exist (e.g., a button).

When enabled, button presses must log output like:

css
Copy
Edit
[DEBUG] Start button clicked
[DEBUG] Open Module menu triggered
This helps verify UI events during alpha testing.

⚙️ Electron Main Process
Clicking a module should:

Trigger a Godot executable via child_process.spawn.

Electron app stays open; modules run independently.

On Quit:

Show confirmation popup.

Exit app only if user confirms.

✅ Completed Tasks
 Main launcher UI (alpha version)

 Functional menu buttons

 Toggleable debug console

 Submenu support with Back buttons

 Quit confirmation popup

🚧 Upcoming Features / TODO
 Module metadata parsing (from JSON)

 Integration with Godot module launcher

 Live module info preview (thumbnails, status)

 Tag and search system for modules

 Settings panel for theme, paths, preferences
