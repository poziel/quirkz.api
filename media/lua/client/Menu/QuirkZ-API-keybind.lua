--[[
--
-- QuirkZ: API
--
-- Keybind plugin
--
-- This plugin allows you to quickly set a keybind for a specific action
-- It automaticaly set the keybind option in the settings
--
-- @author Pøziel
-- @link https://steamcommunity.com/id/poziel
--
--]]

QuirkZ                  = QuirkZ or {}
QuirkZ.API              = QuirkZ.API or {}
QuirkZ.API.Keybind      = QuirkZ.API.Keybind or {}

--- Method that allows quick add to a keypress event whilst
--- adding that same keypress event into the keybinding option in the settings
---
--- @param section string # The section for the keybind in the settings
--- @param key string # The key associated with the new keybind settings
--- @param keypress number # The default keybind for this action
--- @param callback function # The callback called when the right key is pressed
function QuirkZ.API.Keybind:OnKeyPress(section, key, keypress, callback)

    -- Add the keybind option in the settings
    Events.OnGameBoot.Add(function()
        table.insert(keyBinding, { value = section } );
        table.insert(keyBinding, { value = key, key = keypress } );
    end)

    -- Add the OnKeyPress event
    Events.OnKeyPressed.Add(function(_keyPressed)
        if _keyPressed == getCore():getKey(key) then
            callback()
        end
    end)
end

--- Method that allows quick add to a keypress event whilst
--- adding that same keypress event into the keybinding option in the settings
---
--- @param section string # The section for the keybind in the settings
--- @param key string # The key associated with the new keybind settings
--- @param keypress number # The default keybind for this action
--- @param callback function # The callback called when the right key is pressed
function QuirkZ.API.Keybind:Add(section, key, keypress)

    -- Add the keybind option in the settings
    Events.OnGameBoot.Add(function()
        table.insert(keyBinding, { value = section } );
        table.insert(keyBinding, { value = key, key = keypress } );
    end)
end