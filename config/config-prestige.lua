-- I WOULD NOT REALLY CHANGE ANY OF THIS AS I HAVE BALANCED THIS VERY WELL
Config.Leveling = {

    --------------------------------------------------------------------
    --  GENERAL SETTINGS
    --  MaxLevel:     The highest level inside each prestige (1–50)
    --  MaxPrestige:  How many prestiges exist (0–10)
    --------------------------------------------------------------------
    MaxLevel    = 50,
    MaxPrestige = 10,


    --------------------------------------------------------------------
    --  XP FORMULA (Progression Curve)
    --
    --  These 3 numbers control how much XP each LEVEL requires.
    --  The formula grows gradually every level:
    --
    --      XP_needed = Base + (Linear * level) + (Quadratic * level^2)
    --
    --  Lower numbers = faster leveling.
    --  Higher numbers = slower leveling.
    --
    --  With the values below, reaching Prestige 10 Level 50
    --  requires roughly ~500,000 total XP.
    --------------------------------------------------------------------
    XPFormula = {
        Base      = 45,   -- XP required for level 1
        Linear    = 11,   -- Adds XP per level
        Quadratic = 1,    -- Adds XP per level squared (smooth difficulty curve)
    },


    --------------------------------------------------------------------
    --  XP REWARDS FOR IN-GAME ACTIONS
    --
    --  Adjust these to control how fast players level up.
    --  These values are added directly to a player's total XP,
    --  and also to their "match points" for scoreboard ranking.
    --------------------------------------------------------------------
    XPRewards = {
        Kill          = 25,  -- XP per kill
        HeadshotBonus = 10,   -- Extra XP for a headshot kill

        Win           = 750,  -- XP for winning a match
        Loss          = 250,  -- XP for losing (reduced reward)

        FlagCapture   = 300,  -- XP when capturing a flag
        FlagReturn    = 200,  -- XP when returning a flag

        MatchComplete = 200,  -- XP simply for finishing a match

        Confirm       = 50, -- XP per confirmed tag
    },


    --------------------------------------------------------------------
    --  PRESTIGE DEFINITIONS
    --
    --  Each prestige has:
    --      - A display name
    --      - An icon file name
    --
    --  Icons are loaded from:
    --      html_dui/prestige_icons/<icon>.png
    --------------------------------------------------------------------
    Prestiges = {
        [0]  = { name = "No Prestige", icon = "prestige_0"  },
        [1]  = { name = "Prestige 1",  icon = "prestige_1"  },
        [2]  = { name = "Prestige 2",  icon = "prestige_2"  },
        [3]  = { name = "Prestige 3",  icon = "prestige_3"  },
        [4]  = { name = "Prestige 4",  icon = "prestige_4"  },
        [5]  = { name = "Prestige 5",  icon = "prestige_5"  },
        [6]  = { name = "Prestige 6",  icon = "prestige_6"  },
        [7]  = { name = "Prestige 7",  icon = "prestige_7"  },
        [8]  = { name = "Prestige 8",  icon = "prestige_8"  },
        [9]  = { name = "Prestige 9",  icon = "prestige_9"  },
        [10] = { name = "Prestige 10", icon = "prestige_10" },
    }
}


