# Godot validation

Godot runtime validation is allowed and expected when relevant to a change.

Project directory: E:/Godot Projects/stardewish_demo
Godot executable: D:/SteamLibrary/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe

Use the configured executable directly; it does not need to be on PATH.
Before claiming Godot is unavailable, check this path and attempt validation. If the executable is missing, check Godot on PATH and report the actual failure.

Run these commands in PowerShell:

```powershell
& 'D:/SteamLibrary/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe' --headless --path 'E:/Godot Projects/stardewish_demo' --editor --quit
& 'D:/SteamLibrary/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe' --headless --path 'E:/Godot Projects/stardewish_demo' --quit-after 120
```

Inspect output for parser, import, resource, scene-load, and runtime errors; an exit code alone is not sufficient. Report commands, results, and any actual execution restrictions. Request the needed execution permission when the environment restricts running Godot.

Headless validation checks technical behavior. Visual appearance, input feel, and manual interactions require interactive playtesting or suitable automated tests. State what was actually tested and identify remaining manual checks.

Do not assume Godot cannot run locally. Historical notes about earlier environments are not current execution restrictions.
