describe("OWTL_Player.Data", function()
  local function loadPlayerData()
    dofile("Player/OWTL_Player/media/lua/shared/OWTL_Player_Constants.lua")
    dofile("Player/OWTL_Player/media/lua/shared/OWTL_Player_Data.lua")
  end

  before_each(function()
    OWTL_ResetTestEnvironment()
    loadPlayerData()
  end)

  it("creates per-player mod data with schema defaults", function()
    local player = OWTL_MakeTestPlayer()

    local data = OWTL_Player.Data.Ensure(player)

    assert.are.equal(1, data.schemaVersion)
    assert.are.same(data, player._modData.OWTL_Player)
  end)

  it("uses the single-player key outside client mode", function()
    local player = OWTL_MakeTestPlayer({ username = "alice", onlineId = 17 })

    assert.are.equal("single_player", OWTL_Player.Data.GetPlayerKey(player))

    local data = OWTL_Player.Data.GetPersistent(player)
    assert.are.equal(1, data.schemaVersion)

    local root = OWTL_Player.Data.GetGameRoot()
    assert.are.same(data, root.players.single_player)
  end)

  it("uses username, descriptor, online id, then local fallback in client mode", function()
    OWTL_SetClientMode(true)

    assert.are.equal("alice", OWTL_Player.Data.GetPlayerKey(OWTL_MakeTestPlayer({ username = "alice" })))
    local descriptorPlayer = OWTL_MakeTestPlayer({ forename = "Jane", surname = "Doe" })
    assert.are.equal("Jane_Doe", OWTL_Player.Data.GetPlayerKey(descriptorPlayer))
    assert.are.equal("online_42", OWTL_Player.Data.GetPlayerKey(OWTL_MakeTestPlayer({ onlineId = 42 })))
    assert.are.equal("local", OWTL_Player.Data.GetPlayerKey(OWTL_MakeTestPlayer()))
  end)
end)
