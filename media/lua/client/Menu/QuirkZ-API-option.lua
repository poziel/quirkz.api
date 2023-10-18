--[[
--
-- QuirkZ: API
--
-- Menu:Options plugin
--
-- This plugin let you manage your settings for your mods in one place
-- Allow you to create a new tab to setup all your settings (perfect for a suite of mods)
-- If you only have some simple mod, you can use the already configured 'MODS' tab
--
-- @author Pøziel
-- @link https://steamcommunity.com/id/poziel
--
--]]

QuirkZ.API.Option = {}

QuirkZ.API.Option.Tabs = {}

QuirkZ.API.Option.Tab = {}
QuirkZ.API.Option.Section = {}
QuirkZ.API.Option.Input = {}

_tab = {}

function _tab:add(name)

end

function _conf:buildTab(inGame)
    _conf.inGame = inGame
    if inGame then
        self.configs.base.options.runAllResets = {
            name = "UI_ModOptions_SpiffUI_runAllResets",
            tooltip = "UI_ModOptions_SpiffUI_tooltip_runResets",
            default = function() _conf:showResetDialog() end
        }
        self.configs.base.options.importModOptions = nil
    else
        self.configs.base.options.importModOptions = {
            name = "UI_ModOptions_SpiffUI_importModOptions",
            tooltip = "UI_ModOptions_SpiffUI_importModOptions_tt",
            default = function() _conf:showImportDialog() end
        }
        self.configs.base.options.runAllResets = nil
    end
    local opts = MainOptions.instance

    ------------------------------------------
    -- Stolen from MainOptions :D
    local HorizontalLine = ISPanel:derive("HorizontalLine")

    function HorizontalLine:render()
        self:drawRect(0, 0, self.width, 1, 1.0, 0.5, 0.5, 0.5)
    end

    function HorizontalLine:new(x, y, width)
        local o = ISPanel.new(self, x,  y, width, 2)
        return o
    end

    -- Game options also taken from MainOptions
    local GameOption = ISBaseObject:derive("GameOption")
    function GameOption:new(name, control, arg1, arg2)
        local o = {}
        setmetatable(o, self)
        self.__index = self
        o.name = name
        o.control = control
        o.arg1 = arg1
        o.arg2 = arg2
        if control.isCombobox then
            control.onChange = self.onChangeComboBox
            control.target = o
        end
        if control.isTickBox then
            control.changeOptionMethod = self.onChangeTickBox
            control.changeOptionTarget = o
        end
        if control.isSlider then
            control.targetFunc = self.onChangeVolumeControl
            control.target = o
        end
        return o
    end

    function GameOption:toUI()
        print('ERROR: option "'..self.name..'" missing toUI()')
    end
    
    function GameOption:apply()
        print('ERROR: option "'..self.name..'" missing apply()')
    end
    
    function GameOption:resetLua()
        opts.resetLua = true
    end

    function GameOption:onChangeComboBox(box)
        opts.gameOptions:onChange(opts)
        if self.onChange then
            self:onChange(box)
        end
    end
    
    function GameOption:onChangeTickBox(index, selected)
        opts.gameOptions:onChange(opts)
        if self.onChange then
            self:onChange(index, selected)
        end
    end

    function GameOption:onChangeVolumeControl(control, volume)
        opts.gameOptions:onChange(opts)
        if self.onChange then
            self:onChange(control, volume)
        end
    end
    ------------------------------------------

    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
    -- add our settings tab
    opts:addPage(getText("UI_Name_SpiffUI"))
    opts.addY = 0

    local function colW(cols)
        return (opts:getWidth() - 120) / (cols or 1)
    end

    local function colX(x, cols)
        return 60 + (colW(cols) * x)
    end

    local space = 12

    local y = 20

    local lHeight = FONT_HGT_SMALL + 2

    ------------------------------------------

    local function makeSeparator(txt)
        local sbarWidth = 13
        
        local hLine = HorizontalLine:new(colX(0), y, opts.width - 120)
        hLine.anchorRight = true
        opts.mainPanel:addChild(hLine)

        local label = ISLabel:new(100, y + 8, FONT_HGT_MEDIUM, txt, 1, 1, 1, 1, UIFont.Medium)
        label:setX(colX(0))
        label:initialise()
        label:setAnchorRight(true)
        opts.mainPanel:addChild(label)

        y = y + FONT_HGT_MEDIUM + space
    end

    local function makeButton(data, x, w)
        local txt = getText(data.name)
        local textWid = getTextManager():MeasureStringX(UIFont.Small, txt)
        local btnWid = textWid + 20
        if btnWid < 120 then
            btnWid = 120
        end

        local btn = ISButton:new(x, y, btnWid, lHeight, txt, SpiffUI, data.default)
        btn:initialise()
        btn:instantiate()
        opts.mainPanel:addChild(btn)
        if data.tooltip then
            btn.tooltip = getText(data.tooltip)
        end
        opts.addY = 0
    end

    local function makeCheckbox(data, x, w)
        local txt = getText(data.name)

        local tick = opts:addYesNo(x, y, w/2, lHeight, txt)
        if data.tooltip then
            tick.tooltip = getText(data.tooltip)
        end
        opts.addY = 0

        local option = GameOption:new(data.name, tick)
        --data.option = option
        function option:toUI()
            self.control:setSelected(1, data.value)
        end
        function option:apply()
            local set = self.control:isSelected(1)
            if set ~= data.value then
                data.value = set
            end
        end

        opts.gameOptions:add(option)
	end

    local function makeCombo(data, x, w)
        local txt = getText(data.name)

        -- get our available opts
        local cOpts = {}
		for _,v in ipairs(data) do
			table.insert(cOpts, getText(v))
		end

		local combo = opts:addCombo(x, y, w/2, lHeight, txt, cOpts, 1)
		if data.tooltip then
			local map = {}
			map["defaultTooltip"] = getText(data.tooltip)
			combo:setToolTipMap(map)
		end
        opts.addY = 0

        local option = GameOption:new(data.name, combo)
        --data.option = option
        function option:toUI()
            self.control.selected = tonumber(data.value) or 1
        end
        function option:apply()
            local set = self.control.selected
            if data[set] and set ~= data.value then
                data.value = set
            end
        end

        opts.gameOptions:add(option)
    end

    local function makeText(data, x, w)
        if not data.name then return end
        local txt = getText(data.name)
        local label = ISLabel:new(x, y, lHeight, txt, 1, 1, 1, 1, UIFont.Small)
        label:initialise()
        opts.mainPanel:addChild(label)
        opts.addY = 0
    end

    local function nextLine()
        y = y + lHeight + space
    end

    local function miniSeperator(txt, x, w)
        local label = ISLabel:new(x, y, FONT_HGT_MEDIUM, txt, 1, 1, 1, 1, UIFont.Medium)
        label:setX(x-(w/4))
        label:initialise()
        label:setAnchorRight(true)
        opts.mainPanel:addChild(label)
        
        local hLine = HorizontalLine:new(x-(w/4), y - FONT_HGT_MEDIUM/2, w*2.5)
        hLine.anchorRight = true
        opts.mainPanel:addChild(hLine)
    end
    ------------------------------------------

    -- Sort our sections alphabetically
    local orderd = {}
    for i,_ in pairs(self.configs) do 
        orderd[#orderd+1] = i
    end
    table.sort(orderd)

    ------------------------------------------
    for _,sec in ipairs(orderd) do
        local conf = self.configs[sec]
        local col = 1
        
        if not conf.columns then conf.columns = 2 end
        if getCore():getOptionFontSize() == 2 and conf.columns > 3 then
            conf.columns = conf.columns - 1
        elseif getCore():getOptionFontSize() > 2 then
            conf.columns = 2
        end
        local colw = colW(conf.columns)
        if conf.name and conf.options and not conf.disabled then
            makeSeparator(conf.name)
            
            for _,data in pairs(conf.options) do
                if type(data.default) == 'boolean' then
                    makeCheckbox(data, colX(col, conf.columns), colw)
                elseif type(data.default) == 'function' then
                    makeButton(data, colX(col, conf.columns), colw)
                elseif type(data.default) == 'number' then
                    makeCombo(data, colX(col, conf.columns), colw)
                elseif type(data.default) == 'string' then
                    if data.default == "Seperator" then
                        -- new line here
                        nextLine()
                        if col > 1 then
                            -- Another if needed
                            nextLine()
                            col = 1
                        end
                        miniSeperator(getText(data.name), colX(col, 6), colW(3))
                        col = 9999
                    end
                elseif not data.default then
                    -- Just print the name
                    makeText(data, colX(col, conf.columns), colw)
                end

                if data.endline then
                    -- force a new line
                    col = 9999                
                end

                col = col + 1
                if col >= conf.columns then
                    col = 1
                    nextLine()
                end
            end

            -- ensure new line on end
            nextLine()
            if col > 1 then
                nextLine()
            end
        end
    end
    opts.mainPanel:setScrollHeight(y)
    opts.addY = 0
end