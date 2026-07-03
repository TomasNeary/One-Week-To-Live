OWTL_Player = OWTL_Player or {}
OWTL_Player.Constants = OWTL_Player.Constants or {}

-- This shared file is loaded by both client files. In Lua, a table is often
-- used like a namespace; all constants are grouped under OWTL_Player.Constants
-- so other files can read the same names without copying literal strings.
OWTL_Player.Constants.MOD_ID = "OWTL_Player"
OWTL_Player.Constants.MOD_NAME = "OWTL Player"
OWTL_Player.Constants.DATA_VERSION = 1
OWTL_Player.Constants.PLAYER_DATA_KEY = "OWTL_Player"
OWTL_Player.Constants.GAME_DATA_KEY = "OWTL_Player"

-- These numeric values match the sandbox option for what happens to inventory
-- on death. Lua has no enum type, so small named constants are used instead.
OWTL_Player.Constants.DEATH_DROP_ALL = 1
OWTL_Player.Constants.DEATH_DROP_BACKPACK_ONLY = 2
OWTL_Player.Constants.DEATH_DROP_KEEP_INVENTORY = 3

-- HOME_SEARCH_RADIUS controls how far home respawn searches for an open square.
-- PROGRESSION_SNAPSHOT_TICKS throttles frequent progression saves.
OWTL_Player.Constants.HOME_SEARCH_RADIUS = 12
OWTL_Player.Constants.PROGRESSION_SNAPSHOT_TICKS = 30000
