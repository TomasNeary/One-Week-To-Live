# Lua Test Environment Setup

This file describes the exact local setup for testing Project Zomboid Lua code in this repository.

Project Zomboid uses Kahlua, which is Lua 5.1-like. Tests should target Lua 5.1 syntax and avoid Lua 5.2+ features unless verified against the game runtime.

## Files To Add

Add these project files:

```text
.luarc.json
.luacheckrc
tests/spec_helper.lua
tests/helpers/pz_stubs.lua
```

Add test files beside that structure as needed:

```text
tests/**/*_spec.lua
```

Do not move existing mod files only to make them easier to test. Keep Project Zomboid layout intact:

```text
Player/OWTL_Player/media/lua/client/
Player/OWTL_Player/media/lua/server/
Player/OWTL_Player/media/lua/shared/
Bows/OWTL_Bows/media/lua/client/
Bows/OWTL_Bows/media/lua/server/
Bows/OWTL_Bows/media/lua/shared/
```

Prefer putting pure, testable Lua logic in `media/lua/shared/OWTL_*.lua`. Keep `client` and `server` files focused on game event wiring, game object lookup, and calls into shared code.

## Commands To Install Tooling

Run these from a normal terminal, not from Codex, unless you intentionally grant Codex network permission for installation:

```sh
brew install lua-language-server
cd /Users/tneary/Documents/Codex/2026-06-30/we/One-Week-To-Live
python3 -m venv .venv-tools
./.venv-tools/bin/python -m pip install --upgrade pip
./.venv-tools/bin/python -m pip install hererocks
./.venv-tools/bin/hererocks .luaenv -l 5.1.5 -r latest
./.luaenv/bin/luarocks install busted
./.luaenv/bin/luarocks install luacheck
```

Use repository-local tool directories so Lua, LuaRocks, and test dependencies stay inside this workspace:

```text
.luaenv/
.venv-tools/
```

Recommended `.gitignore` addition if `.gitignore` exists or is added later:

```gitignore
.luaenv/
.venv-tools/
luacov.*
```

## Commands To Run Tests

Run these from the repository root:

```sh
cd /Users/tneary/Documents/Codex/2026-06-30/we/One-Week-To-Live
./.luaenv/bin/lua -v
./.luaenv/bin/busted tests
./.luaenv/bin/luacheck Player/OWTL_Player Bows/OWTL_Bows tests
```

Expected Lua version output:

```text
Lua 5.1.5
```

## `.luarc.json`

Create `.luarc.json` with:

```json
{
  "runtime.version": "Lua 5.1",
  "runtime.path": [
    "?.lua",
    "?/init.lua"
  ],
  "workspace.library": [
    "Player/OWTL_Player/media/lua/shared",
    "Player/OWTL_Player/media/lua/client",
    "Player/OWTL_Player/media/lua/server",
    "Bows/OWTL_Bows/media/lua/shared",
    "Bows/OWTL_Bows/media/lua/client",
    "Bows/OWTL_Bows/media/lua/server",
    "tests/helpers"
  ],
  "diagnostics.globals": [
    "Events",
    "SandboxVars",
    "getPlayer",
    "getSpecificPlayer",
    "getWorld",
    "getCell",
    "isClient",
    "isServer"
  ],
  "workspace.checkThirdParty": false,
  "telemetry.enable": false
}
```

## `.luacheckrc`

Create `.luacheckrc` with:

```lua
std = "lua51"

files["Player/OWTL_Player/**/*.lua"] = {
  globals = {
    "Events",
    "SandboxVars",
    "getPlayer",
    "getSpecificPlayer",
    "getWorld",
    "getCell",
    "isClient",
    "isServer",
  },
}

files["Bows/OWTL_Bows/**/*.lua"] = {
  globals = {
    "Events",
    "SandboxVars",
    "getPlayer",
    "getSpecificPlayer",
    "getWorld",
    "getCell",
    "isClient",
    "isServer",
  },
}

files["tests/**/*.lua"] = {
  globals = {
    "describe",
    "it",
    "before_each",
    "after_each",
    "assert",
  },
}
```

Add additional Project Zomboid globals only when the implementation actually uses them.

## `tests/spec_helper.lua`

Create `tests/spec_helper.lua` with:

```lua
package.path = table.concat({
  "./?.lua",
  "./?/init.lua",
  "./tests/helpers/?.lua",
  "./Player/OWTL_Player/media/lua/shared/?.lua",
  "./Player/OWTL_Player/media/lua/client/?.lua",
  "./Player/OWTL_Player/media/lua/server/?.lua",
  "./Bows/OWTL_Bows/media/lua/shared/?.lua",
  "./Bows/OWTL_Bows/media/lua/client/?.lua",
  "./Bows/OWTL_Bows/media/lua/server/?.lua",
  package.path,
}, ";")

require("pz_stubs")
```

## `tests/helpers/pz_stubs.lua`

Create `tests/helpers/pz_stubs.lua` with:

```lua
Events = Events or {}
SandboxVars = SandboxVars or {}

local function event()
  return {
    handlers = {},
    Add = function(self, handler)
      table.insert(self.handlers, handler)
    end,
    Remove = function(self, handler)
      for index = #self.handlers, 1, -1 do
        if self.handlers[index] == handler then
          table.remove(self.handlers, index)
        end
      end
    end,
    Trigger = function(self, ...)
      for _, handler in ipairs(self.handlers) do
        handler(...)
      end
    end,
  }
end

Events.OnGameStart = Events.OnGameStart or event()
Events.OnCreatePlayer = Events.OnCreatePlayer or event()
Events.OnPlayerUpdate = Events.OnPlayerUpdate or event()
Events.OnTick = Events.OnTick or event()

local currentPlayer = nil

function getPlayer()
  return currentPlayer
end

function getSpecificPlayer()
  return currentPlayer
end

function OWTL_SetTestPlayer(player)
  currentPlayer = player
end

function isClient()
  return false
end

function isServer()
  return false
end

return {
  event = event,
  setPlayer = OWTL_SetTestPlayer,
}
```

Keep this file intentionally small. Add Project Zomboid API stubs only when a test needs them.

## Codex Permission Scope

Current repository-local Codex config is already close to the minimum required shape:

```toml
approval_policy = "on-request"
default_permissions = "zomboid-mod"

[permissions.zomboid-mod.filesystem]
":minimal" = "read"
":tmpdir" = "write"
":slash_tmp" = "write"

[permissions.zomboid-mod.filesystem.":workspace_roots"]
"." = "write"
".git" = "write"
".codex" = "read"
"**/*.env" = "deny"

[permissions.zomboid-mod.network]
enabled = false
```

No extra filesystem permission is required for normal Lua tests if dependencies are installed into:

```text
/Users/tneary/Documents/Codex/2026-06-30/we/One-Week-To-Live/.luaenv
/Users/tneary/Documents/Codex/2026-06-30/we/One-Week-To-Live/.venv-tools
```

Do not grant Codex read access to:

```text
/Users/tneary
/Users/tneary/Zomboid
/Users/tneary/Library
Project Zomboid install directories
Steam directories
```

If Codex must run the install commands itself, temporarily enable network or approve the exact install commands interactively. Revert network to disabled after installation:

```toml
[permissions.zomboid-mod.network]
enabled = false
```

For routine test execution, keep network disabled.

## Optional Codex Command Rules

To reduce prompts for local test runs, add only these command rules to `.codex/rules/default.rules`:

```text
prefix_rule(
    pattern = ["./.luaenv/bin/busted"],
    decision = "allow",
    justification = "Runs repository-local Lua tests.",
)

prefix_rule(
    pattern = ["./.luaenv/bin/luacheck"],
    decision = "allow",
    justification = "Runs static analysis on repository Lua files.",
)

prefix_rule(
    pattern = ["./.luaenv/bin/lua"],
    decision = "allow",
    justification = "Runs Lua 5.1 scripts for repository-local testing.",
)
```

Do not add broad rules such as:

```text
pattern = ["brew"]
pattern = ["luarocks"]
pattern = ["sh"]
pattern = ["zsh"]
pattern = ["python"]
pattern = ["python3"]
```

Dependency installation should remain explicit because it requires network access. The commands above keep Python tooling, Lua, LuaRocks, and installed rocks inside the repository, but network access should still be approved per install session rather than permanently enabled.

## Optional Game Verification Permission

Only if game behavior or symlink visibility is being verified, grant read-only access to the exact mod symlink path under:

```text
/Users/tneary/Zomboid/mods/<exact-mod-folder>
```

Use the exact folder only, for example:

```text
/Users/tneary/Zomboid/mods/OWTL_Player
/Users/tneary/Zomboid/mods/OWTL_Bows
```

Do not grant read access to all of `/Users/tneary/Zomboid`.

## Test Boundary

Use this setup for:

```text
pure Lua behavior
data normalization
sandbox option defaults
event registration shape
guard clauses around nil game objects
inventory and player logic with explicit stubs
```

Do not treat these tests as proof of in-game behavior. Anything involving real Java-exposed Project Zomboid objects, world state, loaded cells, multiplayer state, animation, recipes, distributions, or timed actions still needs in-game verification.
