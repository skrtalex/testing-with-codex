# testing-with-codex
Trying out OpenAI Codex


Game Mechanics Hub
Game Mechanics Hub is a modular desktop application that allows developers, designers, and hobbyists to create, organize, and test independent game mechanics rapidly.

This is not a full game engine or a complete game. It’s a launcher and organizer for gameplay micro-concepts — like AI behaviors, puzzle logic, or moral choice systems — each built independently in Godot.

Overview
The project consists of two parts:

Electron-based launcher (desktop app)

Godot-based gameplay modules (self-contained mechanics)

Each mechanic is its own Godot project with a metadata file and runs independently when launched.

How it works
Electron loads the list of available modules from the /modules/ directory.

Each module folder must contain:

a project.godot file (Godot project)

a metadata.json file (describes the module: name, tags, description, status)

The Electron app displays this info in a list, allowing the user to view and launch modules.

When "Load" is clicked, the selected Godot module is started using Node.js child_process.spawn(...).

Godot runs the mechanic as a standalone game.

When the Godot process exits, control returns to the Electron launcher.

Use Case
The goal is to test ideas like:

An NPC becoming paranoid when hearing gunfire

A dynamic dialogue system that adapts to player behavior

A turn-based combat system with unusual rules

Instead of building these into a full game, each mechanic lives in isolation and can be tested immediately.

Electron Menu Overview
Main menu contains:

New Module
(placeholder) Option to create/register a new mechanic project.

Load Module
Lists all detected modules with metadata.
Each entry shows name, description, status, and a Launch button.

View All Modules
Displays all modules in a bigger list, optionally with filters (by tag or status).

Settings
Placeholder for global settings like Godot path or UI themes.

Folder Structure
Game-Mechanics-Hub/
├── main.js (Electron main process)
├── package.json
├── public/
│ ├── index.html (UI interface)
│ ├── script.js (Frontend logic)
│ └── style.css
├── modules/
│ ├── ParanoiaNPC/
│ │ ├── project.godot
│ │ └── metadata.json
│ └── ... other modules ...

Technologies Used
Electron for the desktop UI

HTML/CSS/JavaScript for the interface

Godot Engine for building and testing gameplay

JSON for storing module metadata

Example metadata.json
{
"name": "Paranoia NPC",
"description": "NPC becomes paranoid when it hears gunfire.",
"tags": ["AI", "psychology"],
"status": "In Work"
}

Future Plans
Create new modules directly from the UI

Add filters by tag or status

Versioning and backup options

Cloud sync via GitHub or GitLab

Tag support and search

Why this project exists
Game development involves testing lots of ideas. Game Mechanics Hub allows you to rapidly prototype, organize, and revisit small game mechanics without creating an entire game around them.

License
MIT License – free to use, modify, and distribute.

