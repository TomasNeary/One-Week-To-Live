require "Farming/ScavengeDefinition";

local KCMSCRAP = {};
KCMSCRAP.type = "Base.ScrapMetal";
KCMSCRAP.minCount = 1;
KCMSCRAP.maxCount = 2;
KCMSCRAP.skill = 8;

table.insert(scavenges.forestGoods, KCMSCRAP);

