describe("OWTL_BloodMoon", function()
  local function loadBloodMoon()
    dofile("Horde_Night/OWTL_BloodMoon/media/lua/shared/OWTL_BloodMoon_Constants.lua")
    dofile("Horde_Night/OWTL_BloodMoon/media/lua/shared/OWTL_BloodMoon_Sandbox.lua")
    dofile("Horde_Night/OWTL_BloodMoon/media/lua/server/OWTL_BloodMoon_State.lua")
  end

  before_each(function()
    OWTL_ResetTestEnvironment()
    loadBloodMoon()
  end)

  it("coerces sandbox defaults and bounds", function()
    assert.is_true(OWTL_BloodMoon.Sandbox.IsEnabled())
    assert.is_false(OWTL_BloodMoon.Sandbox.IsFixedInterval())
    assert.are.equal(5, OWTL_BloodMoon.Sandbox.GetMinRandomInterval())
    assert.are.equal(7, OWTL_BloodMoon.Sandbox.GetMaxRandomInterval())
    assert.are.equal(300, OWTL_BloodMoon.Sandbox.GetServerHordeCap())

    SandboxVars.OWTL_BloodMoon = {
      Enabled = false,
      IntervalMode = 2,
      MinRandomInterval = -4,
      MaxRandomInterval = 0,
      FixedInterval = 2.9,
      ServerHordeCap = -10,
      GroupHordeCap = 3.8,
      DebugLogging = true,
    }

    assert.is_false(OWTL_BloodMoon.Sandbox.IsEnabled())
    assert.is_true(OWTL_BloodMoon.Sandbox.IsFixedInterval())
    assert.are.equal(1, OWTL_BloodMoon.Sandbox.GetMinRandomInterval())
    assert.are.equal(1, OWTL_BloodMoon.Sandbox.GetMaxRandomInterval())
    assert.are.equal(2, OWTL_BloodMoon.Sandbox.GetFixedInterval())
    assert.are.equal(0, OWTL_BloodMoon.Sandbox.GetServerHordeCap())
    assert.are.equal(3, OWTL_BloodMoon.Sandbox.GetGroupHordeCap())
    assert.is_true(OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled())
  end)

  it("schedules fixed-interval events from world age", function()
    SandboxVars.OWTL_BloodMoon = {
      Enabled = true,
      IntervalMode = 2,
      FixedInterval = 7,
    }
    OWTL_SetWorldAgeHours(10)

    local data = OWTL_BloodMoon.State.Ensure()

    assert.are.equal(7, data.nextBloodMoonDay)
    assert.are.equal(21, data.nextBloodMoonStartHour)
    assert.are.equal(189, data.nextBloodMoonStartWorldHour)
    assert.are.equal(8, data.nextBloodMoonEndDay)
    assert.are.equal(6, data.nextBloodMoonEndHour)
    assert.are.equal(198, data.nextBloodMoonEndWorldHour)
    assert.are.equal(165, data.warningWorldHour)
    assert.are.equal("scheduled", data.lastTransition)
  end)

  it("ticks through warning, start, horde-marking, and dawn end", function()
    SandboxVars.OWTL_BloodMoon = {
      Enabled = true,
      IntervalMode = 2,
      FixedInterval = 7,
    }
    OWTL_SetWorldAgeHours(10)
    local data = OWTL_BloodMoon.State.Ensure()

    OWTL_SetWorldAgeHours(165)
    OWTL_BloodMoon.State.Tick()
    assert.is_true(data.warningIssued)
    assert.are.equal("warning-time", data.lastTransition)

    OWTL_SetWorldAgeHours(189)
    OWTL_BloodMoon.State.Tick()
    assert.is_true(data.isActive)
    assert.are.equal("started-at-21", data.lastTransition)

    OWTL_BloodMoon.State.MarkHordeGroupAllocated("group-a", 12.8, 4.2)
    assert.are.equal(1, OWTL_BloodMoon.State.CountActiveGroups(data))
    assert.are.equal(12, data.activeHordeCount)
    assert.are.equal(4, data.queuedHordeCount)
    assert.is_true(OWTL_BloodMoon.State.EventHadHordeGroup(data))

    OWTL_SetWorldAgeHours(198)
    OWTL_BloodMoon.State.Tick()
    assert.is_false(data.isActive)
    assert.are.equal(2, data.hordeStage)
    assert.is_true(data.lastEventAdvancedStage)
    assert.are.equal("scheduled", data.lastTransition)
    assert.are.equal(15, data.nextBloodMoonDay)
  end)

  it("reports horde groups as event participation", function()
    local empty = {
      activeHordeGroups = {},
      activeHordeCount = 0,
      queuedHordeCount = 0,
    }
    assert.is_false(OWTL_BloodMoon.State.EventHadHordeGroup(empty))

    assert.is_true(OWTL_BloodMoon.State.EventHadHordeGroup({
      activeHordeGroups = { a = {} },
      activeHordeCount = 0,
      queuedHordeCount = 0,
    }))
    assert.is_true(OWTL_BloodMoon.State.EventHadHordeGroup({
      activeHordeGroups = {},
      activeHordeCount = 3,
      queuedHordeCount = 0,
    }))
  end)
end)
