--[[
--
-- QuirkZ: API
--
-- This file must be loaded before any other file in this mod. It is the brain, the master
-- the lord of knowledge (overall, it's important)
--
-- @author Pøziel
-- @link https://steamcommunity.com/id/poziel
--
--]]

-- Set the QuirkZ lib version and hardcode the name of the lib
QuirkZ_VERSION = 1
QuirkZ_NAME = 'API'

-- Validate that this lib is the most recent version
if QuirkZ then

    -- If this module of QuirkZ is already at the lastest version
    if QuirkZ.Version >= QuirkZ_VERSION then
        return

    -- If this module of QuirkZ does not have the most recent version of QuirkZ
    else
        print(string.format("This library (%s) does not have the most recent version, please tell this slacking modder Pøziel that his library need an upgrade! (%s version: %d, most recent version: %d)", QuirkZ_NAME, QuirkZ_VERSION, QuirkZ.Version))
        Events.OnGameBoot.Remove(QuirkZ.FirstBoot)
    end
end

-- Initiate all the QuirkZ table content
-- allowing it to speak with other QuirkZ mods
-- (it should not speak to other QuirkZ mods since it's the API, but wtv)
QuirkZ                  = QuirkZ or {}
QuirkZ.API              = {}
QuirkZ.Version          = QuirkZ_VERSION

-- Initiate the first boot as a QuirkZ library
QuirkZ.firstBoot = function()
    QuirkZ:OnGameBoot()
end

-- These fixes/tweaks are included in other mods, so this prevents from multiple runnings
Exterminator = Exterminator or {}

if not Exterminator.onEnterFromGame then
    -- Protects Against a Known Options Bug
    ---- Thanks Burryaga!
    Exterminator.onEnterFromGame = MainScreen.onEnterFromGame
    function MainScreen:onEnterFromGame()
        Exterminator.onEnterFromGame(self)

        -- Guarantee that when you ENTER the options menu, the game does not think you've already changed your options.
        MainOptions.instance.gameOptions.changed = false
    end
end

-- Adds an event when Game Options are changed
if not Exterminator.MainOptions_apply then
    LuaEventManager.AddEvent("OnSettingsApply")
    Exterminator.MainOptions_apply = MainOptions.apply
    function MainOptions:apply(closeAfter)
        Exterminator.MainOptions_apply(self, closeAfter)
        triggerEvent("OnSettingsApply")
    end
end

-- Adds an event for when a player joins via a controller, and the UI is rebuilt
---- Runs for each player
if not Exterminator.OnCreatePlayerDataObject then
    LuaEventManager.AddEvent("OnCreatePlayerDataObject")
    Exterminator.OnCreatePlayerDataObject = ISPlayerDataObject.createInventoryInterface
    function ISPlayerDataObject:createInventoryInterface()
        Exterminator.OnCreatePlayerDataObject(self)
        triggerEvent("OnCreatePlayerDataObject", self.id)
    end
end