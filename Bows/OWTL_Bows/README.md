# OWTL Bows

Phase 9 V1 adds craftable bows and arrows for early Blood Moon preparation.

## Scope

- Basic Bow and Basic Arrows are craftable from game start.
- Improved Bow and Improved Arrows require `Bowyer Notes`.
- No crossbows are added in V1.
- No bow, arrow, or crossbow zombie-attached spawns are added.
- No bow or arrow loot distributions are added.
- Only `Bowyer Notes` is added to literature-style loot.
- Missed shots do not create world or ground recovery items.
- Arrows that hit zombies can be recovered from the corpse.

## Best-Guess Tuning

These values are script-level estimates pending in-game Blood Moon testing.

Basic Bow:

- Damage: `0.55-1.10`
- Hit chance: `38`
- Aiming hit modifier: `+10` per Aiming level
- Critical chance: `25`
- Aiming critical modifier: `+3` per Aiming level
- Range: `0.6-9`
- Reload time: `24`
- Aiming time: `28`
- Sound radius: `3`
- Condition: `8`, lower chance `1/38`

Improved Bow:

- Damage: `0.85-1.55`
- Hit chance: `46`
- Aiming hit modifier: `+12` per Aiming level
- Critical chance: `35`
- Aiming critical modifier: `+4` per Aiming level
- Range: `0.6-11`
- Reload time: `18`
- Aiming time: `24`
- Sound radius: `4`
- Condition: `10`, lower chance `1/48`

Arrow recovery:

- Basic Arrow: `65%` intact, `25%` broken, `10%` lost.
- Improved Arrow: `80%` intact, `15%` broken, `5%` lost.

Balance intent:

- Prepared players can build enough arrows for early horde defense.
- Firearms remain better for burst killing through higher damage, multi-shot magazines, and faster sustained fire.
- Bows are quieter but slower and less reliable at low Aiming/Reloading.
- `AimingPerkHitChanceModifier` and `AimingPerkCritModifier` are the explicit Aiming hooks.
- `ReloadTime` and firearm-style reload handling are the Reloading hook; higher Reloading should shorten the draw/load cycle through vanilla reload-speed handling.
