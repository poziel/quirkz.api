--[[
--
-- QuirkZ: API
--
-- Player plugin
--
-- This plugin allows you to performs certain actions on a player or all player in
-- the world
--
-- @author Pøziel
-- @link https://steamcommunity.com/id/poziel
--
--]]

QuirkZ                  = QuirkZ or {}
QuirkZ.API              = QuirkZ.API or {}
QuirkZ.API.Player       = QuirkZ.API.Player or {}

--- This method allows to quickly execute a callback on every memeber of a server
---
--- @param callback function The callback done to all player (take in parameter a player)
function QuirkZ.API.Player:execute(callback)
    for index = 0, getNumActivePlayers() - 1 do
        callback(getSpecificPlayer(index))
    end
end