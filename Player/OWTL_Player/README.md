# OWTL Player

Phase 6 implements the player lifecycle slice:

- Persistent progression snapshots for skills, partial XP where `getXP` is available, recipes, traits, and profession.
- Optional probes for map knowledge and known media. These are recorded only when the current Build 41 runtime exposes compatible methods.
- Respawn infection reset.
- Death drop modes: Drop All, Drop Backpack Only, and Keep Inventory.
- Disabled-by-default death penalties: broken limb, burn, severe pain, and exhaustion/fatigue.
- `Set as Home` context action on detected sleepable objects.
- Home respawn fallback: exact square, nearby safe square, old square if still accessible, then vanilla random spawn.

Implementation notes:

- Drop All leaves vanilla corpse inventory behavior untouched.
- Drop Backpack Only and Keep Inventory remove retained items during `OnPlayerDeath` and recreate retained item types on respawn. Item condition, nested contents, custom modData, and attachments are not yet guaranteed to survive without in-game API validation.
- Multiplayer safehouse checks use `SafeHouse.getSafehouseList()` and `safehouse:playerAllowed(player)` when available. Single-player bypasses safehouse restrictions.
- Map knowledge and known media persistence require in-game verification because no stable local Build 41 API examples were present in bundled reference mods.
