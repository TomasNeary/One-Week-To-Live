# Zomboid User Folder Inspection

Inspection target:

- `/Users/tneary/Zomboid`

Purpose:

- Record the visible Project Zomboid user-folder structure.
- Identify files worth inspecting when debugging or validating the OWTL mods.

## Observed Structure

Top-level entries:

- `/Users/tneary/Zomboid/Logs`
- `/Users/tneary/Zomboid/Lua`
- `/Users/tneary/Zomboid/Sandbox Presets`
- `/Users/tneary/Zomboid/Saves`
- `/Users/tneary/Zomboid/Server`
- `/Users/tneary/Zomboid/Workshop`
- `/Users/tneary/Zomboid/messaging`
- `/Users/tneary/Zomboid/mods`
- `/Users/tneary/Zomboid/console.txt`
- `/Users/tneary/Zomboid/logs.zip`
- `/Users/tneary/Zomboid/options.ini`

Empty or effectively unused folders at inspection time:

- `/Users/tneary/Zomboid/Server`
- `/Users/tneary/Zomboid/Workshop`
- `/Users/tneary/Zomboid/Sandbox Presets`
- `/Users/tneary/Zomboid/Lua/LastStand`

## OWTL-Relevant Files To Inspect

High priority:

- `/Users/tneary/Zomboid/mods`
  - Verifies which local mods are deployed to the game user folder.
  - Entries are symlinks back into this repository.
  - OWTL symlinks observed:
    - `/Users/tneary/Zomboid/mods/OWTL_Bows` -> `Bows/OWTL_Bows`
    - `/Users/tneary/Zomboid/mods/OWTL_Traps` -> `Buildings/OWTL_Traps`
  - OWTL symlinks not observed:
    - `OWTL_BloodMoon`
    - `OWTL_Player`

- `/Users/tneary/Zomboid/mods/default.txt`
  - Current global mod activation file.
  - Observed as empty:
    - `mods { }`
    - `maps { }`

- `/Users/tneary/Zomboid/Saves/Tutorial/94606291916626440887/mods.txt`
  - Save-specific active mod list.
  - Observed as empty:
    - `mods { }`
    - `maps { }`
  - This means the inspected Tutorial save was not using OWTL mods.

- `/Users/tneary/Zomboid/console.txt`
  - Current/last game console output.
  - Worth checking after any OWTL load or runtime test for Lua errors, missing assets, script parse errors, and mod load order.
  - Current file contains no `OWTL` hits.

- `/Users/tneary/Zomboid/Logs/*.txt`
  - Historical debug and game logs.
  - Current logs contain no `OWTL` hits.
  - Observed errors are dominated by repeated OpenGL render stack traces, not OWTL Lua failures.

Medium priority:

- `/Users/tneary/Zomboid/Saves/Tutorial/94606291916626440887/WorldDictionaryReadable.lua`
  - Human-readable world item registry for the Tutorial save.
  - Useful for confirming whether OWTL items entered a save's world dictionary.
  - Current inspected save appears vanilla-only for OWTL purposes.

- `/Users/tneary/Zomboid/Saves/Tutorial/94606291916626440887/players.db`
  - Player persistence database.
  - Worth inspecting only if testing OWTL player lifecycle, death penalties, death drops, or respawn state.

- `/Users/tneary/Zomboid/Saves/Tutorial/94606291916626440887/vehicles.db`
  - Vehicle database.
  - Low direct OWTL relevance unless vehicle interaction becomes part of the test.

- `/Users/tneary/Zomboid/options.ini`
  - Client options and display/gameplay settings.
  - Relevant mainly for reproducing graphics/logging or input behavior.

- `/Users/tneary/Zomboid/Lua/host.ini`
  - Host settings for local multiplayer.
  - Observed:
    - `servername=servertest`
    - `username=Svencredible`
    - `memory=4096`
  - Relevant when testing multiplayer OWTL behavior.

- `/Users/tneary/Zomboid/messaging/DebugOptions_list.xml`
  - Debug options state.
  - Useful if debug mode or debug UI behavior affects OWTL testing.

Low priority:

- `/Users/tneary/Zomboid/Lua/keys.ini`
  - Keybindings.
  - Relevant only if OWTL adds input bindings.

- `/Users/tneary/Zomboid/Lua/saved_builds.txt`
  - Saved build-menu presets.
  - Empty at inspection time.
  - Low relevance unless validating trap/build recipes through saved build workflows.

- `/Users/tneary/Zomboid/Lua/saved_outfits.txt`
  - Saved outfits.
  - No current OWTL relevance.

- `/Users/tneary/Zomboid/Lua/screenresolution.ini`
  - Display resolution state.
  - No direct OWTL relevance.

- `/Users/tneary/Zomboid/logs.zip`
  - Archived logs.
  - Worth inspecting only if current plain-text logs are insufficient.

## Current Findings

- `/Users/tneary/Zomboid/mods` is populated with symlinks to this repository.
- Only `OWTL_Bows` and `OWTL_Traps` are visible in the Zomboid user `mods` folder.
- `OWTL_BloodMoon` and `OWTL_Player` exist in this repository but are not currently linked under `/Users/tneary/Zomboid/mods`.
- The inspected active mod lists are empty, so the current Tutorial save is not a useful runtime source for OWTL behavior.
- No `OWTL` strings were found in current `console.txt` or `Logs`.
- The current log errors appear graphics/OpenGL-related, not Lua or OWTL-related.

## Next Inspection Steps For OWTL

1. Add or verify symlinks for every OWTL module that should be visible to Project Zomboid:
   - `Bows/OWTL_Bows`
   - `Buildings/OWTL_Traps`
   - `Horde_Night/OWTL_BloodMoon`
   - `Player/OWTL_Player`

2. Launch or load a save with OWTL mods enabled, then inspect:
   - `/Users/tneary/Zomboid/console.txt`
   - `/Users/tneary/Zomboid/Logs/*_DebugLog.txt`
   - the save's `mods.txt`
   - the save's `WorldDictionaryReadable.lua`

3. For Blood Moon and player lifecycle work, create or inspect a non-Tutorial save with the target OWTL modules enabled.

4. If multiplayer behavior matters, inspect or generate server config under:
   - `/Users/tneary/Zomboid/Server`

5. If sandbox options are added for OWTL, inspect:
   - `/Users/tneary/Zomboid/Sandbox Presets`
   - the active save's sandbox data
   - current `console.txt` for sandbox option parse errors
