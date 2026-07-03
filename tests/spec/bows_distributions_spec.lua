describe("OWTL_Bows.Distributions", function()
  local function target()
    return { items = { "Base.Book", 1.0 } }
  end

  before_each(function()
    OWTL_ResetTestEnvironment()
    _G.SuburbsDistributions = {
      bookstore = { other = target() },
      gigamart = { shelvesmag = target() },
      all = {
        shelves = target(),
        shelvesmag = target(),
        sidetable = target(),
        postbox = target(),
      },
      cornerstore = { shelvesmag = target() },
      garage = { metal_shelves = target() },
      garagestorage = { other = target() },
      poststorage = { all = target() },
    }
  end)

  local function assertAppended(distribution, chance)
    assert.are.equal(4, #distribution.items)
    assert.are.equal("Base.Book", distribution.items[1])
    assert.are.equal(1.0, distribution.items[2])
    assert.are.equal("OWTLweapons.OWTL_BowyerNotes", distribution.items[3])
    assert.are.equal(chance, distribution.items[4])
  end

  it("adds Bowyer Notes to implemented loot distributions", function()
    dofile("Bows/OWTL_Bows/media/lua/server/items/OWTL_Bows_Distributions.lua")

    assertAppended(_G.SuburbsDistributions.bookstore.other, 0.25)
    assertAppended(_G.SuburbsDistributions.gigamart.shelvesmag, 0.25)
    assertAppended(_G.SuburbsDistributions.all.shelves, 0.08)
    assertAppended(_G.SuburbsDistributions.garage.metal_shelves, 0.12)
    assertAppended(_G.SuburbsDistributions.all.postbox, 0.12)
  end)
end)
