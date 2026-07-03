package.path = table.concat({
  "./?.lua",
  "./?/init.lua",
  "./tests/helpers/?.lua",
  "./tests/helpers/?/init.lua",
  "./tests/helpers/?/?.lua",
  "./Horde_Night/OWTL_BloodMoon/media/lua/shared/?.lua",
  "./Horde_Night/OWTL_BloodMoon/media/lua/client/?.lua",
  "./Horde_Night/OWTL_BloodMoon/media/lua/server/?.lua",
  "./Player/OWTL_Player/media/lua/shared/?.lua",
  "./Player/OWTL_Player/media/lua/client/?.lua",
  "./Player/OWTL_Player/media/lua/server/?.lua",
  "./Bows/OWTL_Bows/media/lua/shared/?.lua",
  "./Bows/OWTL_Bows/media/lua/client/?.lua",
  "./Bows/OWTL_Bows/media/lua/server/?.lua",
  "./Bows/OWTL_Bows/media/lua/server/items/?.lua",
  "./Buildings/OWTL_Traps/media/lua/shared/?.lua",
  "./Buildings/OWTL_Traps/media/lua/client/?.lua",
  "./Buildings/OWTL_Traps/media/lua/server/?.lua",
  package.path,
}, ";")

require("pz_stubs")
