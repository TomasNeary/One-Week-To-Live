# OWTL Zombie Traps

Phase 7 adds buildable V1 Blood Moon defenses through the right-click build menu:

- Simple Spiked Pit: Carpentry 1, 2 planks, 4 nails, hammer, saw. 3 uses, 0.35 zombie health damage per trigger, 18 player body-part damage when player damage is enabled.
- Dug Spiked Pit: Carpentry 2, 4 planks, 8 nails, hammer, saw, shovel. 6 uses, 0.65 zombie health damage, 32 player body-part damage.
- Spiked Log Barricade: Carpentry 2, 2 logs, 4 nails, hammer, saw. 10 uses, 0.25 zombie health damage, 12 player body-part damage.

Repair values:

- Simple Spiked Pit: 1 plank, 2 nails.
- Dug Spiked Pit: 2 planks, 4 nails.
- Spiked Log Barricade: 1 log, 2 nails.

Implementation notes:

- The Dug Spiked Pit uses a shovel-required single build action. A reliable OWTL-specific multistage build definition was deferred because the current module has no existing multistage definitions and Phase 8 is responsible for recipe/progression integration.
- Multiplayer build, repair, durability/use loss, and zombie triggering are routed through `media/lua/server/OWTL_Traps_Server.lua`.
- Single-player placement, repair, and trigger handling are local equivalents because `isServer()` command routing is not available in the same way outside multiplayer.
- Existing legacy Trap items remain untouched for compatibility; new defenses are tagged with `owtlTrapId` modData.
- V1 uses right-click square placement plus timed actions. A full ghost-tile placement preview is not implemented in this slice.
