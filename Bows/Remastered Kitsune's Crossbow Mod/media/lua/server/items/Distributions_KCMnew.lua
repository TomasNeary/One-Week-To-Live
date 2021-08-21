Distributions = Distributions or {};

local distributionTable = {


    gunstore = {
	    isShop = true,
        counter ={
            rolls = 3,
            items = {			
				"KCMweapons.KCM_Compound", 1,
				"KCMweapons.KCM_Compound02", 1,
				"KCMweapons.CrossbowBoltLargeBox", 1,				
				"KCMweapons.DoomsdayPreppers2", 0.2,
				"KCMweapons.DoomsdayPreppers1", 0.2,
				"KCMweapons.WeaponHandlersReloaded", 0.1,
				"KCMweapons.TheUltimateHuntingGuide1", 0.2,
				"KCMweapons.TheUltimateHuntingGuide2", 0.2,
				"KCMweapons.TheSniperGuide", 0.1,
            },
            dontSpawnAmmo = true,
        },

        displaycase ={
            rolls = 3,
            items = {
				"KCMweapons.CrossbowBoltLargeBox", 1,				
				"KCMweapons.KCM_Compound", 1,
				"KCMweapons.KCM_Compound02", 1,
            },
            dontSpawnAmmo = true,
        },

        locker ={
            rolls = 3,
            items = {
				"KCMweapons.CrossbowBoltLargeBox", 0.5,				
				"KCMweapons.KCM_Compound", 0.5,
				"KCMweapons.KCM_Compound02", 0.5,
            },
            dontSpawnAmmo = true,
        },

        metal_shelves ={
            rolls = 3,
            items = {
				"KCMweapons.CrossbowBoltLargeBox", 0.5,				
				"KCMweapons.KCM_Compound", 0.5,
				"KCMweapons.KCM_Compound02", 0.5,
            },
            dontSpawnAmmo = true,
        },
    },

    gunstorestorage = {
        all={
            rolls = 3,
            items = {
				"KCMweapons.CrossbowBoltLargeBox", 1,				
				"KCMweapons.KCM_Compound", 1,
				"KCMweapons.KCM_Compound02", 1,
            },
    
            dontSpawnAmmo = true,
        },
    },

    
    hunting = {
        locker = {
            rolls = 2,
            items = {
				"KCMweapons.KCM_Compound", 1,
				"KCMweapons.KCM_Compound02", 1,
            }
        },
        
        metal_shelves ={
            rolls = 3,
            items = {
				"KCMweapons.CrossbowBoltLarge", 1,
				"KCMweapons.CrossbowBoltLargeBox", 1,
				"KCMweapons.DoomsdayPreppers2", 0.4,
				"KCMweapons.DoomsdayPreppers1", 0.4,
				"KCMweapons.WeaponHandlersReloaded", 0.1,
				"KCMweapons.TheUltimateHuntingGuide1", 0.5,
				"KCMweapons.TheUltimateHuntingGuide2", 0.5,
				"KCMweapons.TheSniperGuide", 0.4,

            },
        },
    },
    
	armystorage = {
        locker = {
            rolls = 2,
            items = {
				"KCMweapons.CrossbowBoltLargeBox", 0.1,
				"KCMweapons.KCM_Compound", 0.1,
				"KCMweapons.KCM_Compound02", 0.1,
				"KCMweapons.TheSniperGuide", 0.4,
            },
        },
        
        metal_shelves =
        {
            rolls = 2,
            items = {
				"KCMweapons.CrossbowBoltLarge", 0.1,
				"KCMweapons.CrossbowBoltLargeBox", 0.1,
				"KCMweapons.TheSniperGuide", 0.4,
            }
        },
    },
}

table.insert(Distributions, 1, distributionTable);

--for mod compat:
SuburbsDistributions = distributionTable;
