describe("OWTL_Traps.Definitions", function()
  local function loadTraps()
    dofile("Buildings/OWTL_Traps/media/lua/shared/OWTL_Traps_Definitions.lua")
  end

  before_each(function()
    OWTL_ResetTestEnvironment()
    loadTraps()
  end)

  it("exposes the implemented trap definitions in declared order", function()
    assert.are.same({
      "SimpleSpikedPit",
      "DugSpikedPit",
      "SpikedLogBarricade",
    }, OWTL_Traps.Definitions.ORDER)

    for _, trapId in ipairs(OWTL_Traps.Definitions.ORDER) do
      local trapDef = OWTL_Traps.Definitions.Get(trapId)
      assert.are.equal(trapId, trapDef.id)
      assert.is_true(trapDef.damage > 0)
      assert.is_true(trapDef.maxUses > 0)
      assert.is_table(trapDef.materials)
      assert.is_table(trapDef.repairMaterials)
    end
  end)

  it("checks recipe and natural carpentry unlocks", function()
    local player = OWTL_MakeTestPlayer({
      woodwork = 2,
      recipes = { "Build Dug Spiked Pit" },
    })
    local simple = OWTL_Traps.Definitions.Get("SimpleSpikedPit")
    local dug = OWTL_Traps.Definitions.Get("DugSpikedPit")
    local barricade = OWTL_Traps.Definitions.Get("SpikedLogBarricade")

    assert.is_true(OWTL_Traps.Definitions.HasNaturalUnlock(player, simple))
    assert.is_true(OWTL_Traps.Definitions.HasProgressionUnlock(player, dug))
    assert.is_false(OWTL_Traps.Definitions.HasProgressionUnlock(player, barricade))
  end)

  it("grants natural recipes based on carpentry level", function()
    local player = OWTL_MakeTestPlayer({ woodwork = 3 })

    OWTL_Traps.Definitions.GrantNaturalRecipes(player)

    assert.is_true(player._knownRecipes:contains("Build Simple Spiked Pit"))
    assert.is_true(player._knownRecipes:contains("Build Dug Spiked Pit"))
    assert.is_false(player._knownRecipes:contains("Build Spiked Log Barricade"))
  end)

  it("identifies OWTL trap items and player-damage sandbox setting", function()
    assert.is_false(OWTL_Traps.Definitions.IsOWTLTrapItem(nil))
    assert.is_false(OWTL_Traps.Definitions.IsOWTLTrapItem(OWTL_MakeTestItem({})))
    assert.is_true(OWTL_Traps.Definitions.IsOWTLTrapItem(OWTL_MakeTestItem({ owtlTrapId = "SimpleSpikedPit" })))

    assert.is_true(OWTL_Traps.Definitions.IsPlayerDamageEnabled())
    SandboxVars.OWTL_Traps = { PlayerDamageEnabled = false }
    assert.is_false(OWTL_Traps.Definitions.IsPlayerDamageEnabled())
  end)
end)
