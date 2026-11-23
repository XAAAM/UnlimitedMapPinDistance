local UMPDO
_UMPD = _UMPD

-- Templates for creating UI Elements
local function roundVal(v)
    return floor(v*1000)/1000
end
local createCheckbox = function(parent,option,label,desc)
    local cb = CreateFrame("CheckButton", "CB" .. label, parent, "UICheckButtonTemplate")
    cb:SetChecked(option)
    cb.text:SetText(desc)
    return cb
end
local createSlider = function(parent,name,option,minVal,maxVal,step,desc)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", name.."box", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(minVal,maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(option)
    _G[name.."Text"]:SetText(desc)
    _G[name.."Low"]:SetText(minVal)
    _G[name.."High"]:SetText(maxVal)

    editbox:ClearAllPoints()
    editbox:SetSize(50,14)
    editbox:SetPoint('TOP', slider, 'BOTTOM')
    editbox:SetFontObject(GameFontHighlightSmall)
    editbox:SetJustifyH('CENTER')
    editbox:SetAutoFocus(false)
    editbox:SetNumeric(true)
    editbox:SetText(slider:GetValue())
    editbox:SetCursorPosition(0)

    slider:SetScript("OnValueChanged", function(self,value)
        self.editbox:SetText(roundVal(value))
    end)
    editbox:SetScript("OnTextChanged", function(self,userInput)
        if not userInput then return end
        local v = self:GetText()
        if tonumber(v) then
            self:GetParent():SetValue(v)
        end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
        local v = self:GetText()
        if tonumber(v) then
            self:GetParent():SetValue(v)
            self:ClearFocus()
        end
    end)
    slider.editbox = editbox
    return slider
end
-- Draw Line
local createHeader = function(f,y,h)
    local t = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    t:SetText("|cffffd100"..h.."|r")
    t:SetPoint("TOP",0,y)
    local l = f:CreateLine()
    l:SetColorTexture(.2,.2,.2,.9)
    l:SetStartPoint("TOPLEFT", 8,(y-6))
    l:SetEndPoint("TOPRIGHT", -8,(y-6))
    l:SetThickness(2)
end

-- Init
function UMPD_Init()
    if not UMPD then UMPD = {} end
    UMPD.minDistance = UMPD.minDistance or 70
    UMPD.fadeDistance = UMPD.fadeDistance or 113
    UMPD.maxDistance = UMPD.maxDistance or 0
    UMPD.pinAlphaLong = UMPD.pinAlphaLong or 60
    UMPD.pinAlphaShort = UMPD.pinAlphaShort or 100
    UMPD.pinAlphaClamped = UMPD.pinAlphaClamped or 100

    if UMPD.autoTrackPins == nil then
        UMPD.autoTrackPins = true
    end

    if UMPD.timeDistance == nil then
        UMPD.timeDistance = true
    end

    if UMPD.useMeters == nil then
        UMPD.useMeters = false
    end

    if UMPD.shortNumbers == nil then
        UMPD.shortNumbers = false
    end

    if UMPD.fadeMouseOver == nil then
        UMPD.fadeMouseOver = true
    end

    if UMPD.blizzEnabled == nil then
        UMPD.blizzEnabled = true
        C_CVar.SetCVar("showInGameNavigation", 1)
    end

    -- Frame
    UMPDO = CreateFrame("Frame", nil, nil, UMPD.name)
    UMPDO.name = _UMPD.name

    function UMPDO.OnCommit() end
    function UMPDO.OnDefault() end
    function UMPDO.OnRefresh() end

    local category = Settings.RegisterCanvasLayoutCategory(UMPDO, _UMPD.addonName);
    Settings.RegisterAddOnCategory(category)
    UMPDO.category = category
    
    -- Title
    local title = UMPDO:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(_UMPD.addonName)

    -- Version
    local version = UMPDO:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    version:SetPoint("TOPRIGHT", -16, -16)
    version:SetText("v".._UMPD.version)

    -- Headers
    createHeader(UMPDO, -59, "Pin Distances")
    createHeader(UMPDO, -155, "Pin Alphas")
    createHeader(UMPDO, -241, "Miscellaneous Options")
    -- createHeader(UMPDO, -453, "Additional Notes")
    createHeader(UMPDO, -532, "Credits")

    -- Sliders
    local slMinDist = createSlider(UMPDO,"minDist",UMPD.minDistance,0,10000,1,"Min Pin Distance") 
    slMinDist:SetPoint("TOPLEFT", 16, -96)
    slMinDist:HookScript("OnValueChanged", function(self,value)
        UMPD.minDistance = value
    end)
    local slFadeDist = createSlider(UMPDO,"fadeDist",UMPD.fadeDistance,0,10000,1,"Fade Pin Distance") 
    slFadeDist:SetPoint("TOP", 0, -96)
    slFadeDist:HookScript("OnValueChanged", function(self,value)
        UMPD.fadeDistance = value
    end)
    local slMaxDist = createSlider(UMPDO,"maxDist",UMPD.maxDistance,0,10000,1,"Max Pin Distance") -- If 0, Unlimited distance
    slMaxDist:SetPoint("TOPRIGHT", -16, -96)
    slMaxDist:HookScript("OnValueChanged", function(self,value)
        UMPD.maxDistance = value
    end)
    local slAlphaShort = createSlider(UMPDO,"shortAlpha",UMPD.pinAlphaShort,0,100,1,"Alpha below fade distance")
    slAlphaShort:SetPoint("TOPLEFT", 16, -192)
    slAlphaShort:HookScript("OnValueChanged", function(self,value)
        UMPD.pinAlphaShort = value
    end)
    local slAlphaLong = createSlider(UMPDO,"longAlpha",UMPD.pinAlphaLong,0,100,1,"Alpha above fade distance")
    slAlphaLong:SetPoint("TOP", 0, -192)
    slAlphaLong:HookScript("OnValueChanged", function(self,value)
        UMPD.pinAlphaLong = value
    end)
    local slAlphaClamped = createSlider(UMPDO,"clampedAlpha",UMPD.pinAlphaClamped,0,100,1,"Alpha when clamped to edge")
    slAlphaClamped:SetPoint("TOPRIGHT", -16, -192)
    slAlphaClamped:HookScript("OnValueChanged", function(self,value)
        UMPD.pinAlphaClamped = value
    end)

    -- Checkboxes
    local cbEnableNavigation = createCheckbox(UMPDO, UMPD.blizzEnabled, "enableNavigation", "Show in-game navigation")
    cbEnableNavigation:SetPoint("TOPLEFT", 8, -32)
    cbEnableNavigation:HookScript("OnClick", function(self)
        UMPD.blizzEnabled = self:GetChecked()
        C_CVar.SetCVar("showInGameNavigation", self:GetChecked() and "1" or "0")
    end)
    local cbTrackPins = createCheckbox(UMPDO, UMPD.autoTrackPins, "trackPins", "Automatically track new pins")
    cbTrackPins:SetPoint("TOPLEFT", 8, -252)
    cbTrackPins:HookScript("OnClick", function(self)
        UMPD.autoTrackPins = self:GetChecked()
    end)
    local cbShowTime = createCheckbox(UMPDO, UMPD.timeDistance, "showTime", "Show estimated time to arrive")
    cbShowTime:SetPoint("TOPLEFT", 8, -282)
    cbShowTime:HookScript("OnClick", function(self)
        UMPD.timeDistance = self:GetChecked()
    end)
    local cbUseMeters = createCheckbox(UMPDO, UMPD.useMeters, "useMeters", "Use meters instead of yards")
    cbUseMeters:SetPoint("TOPLEFT", 8, -312)
    cbUseMeters:HookScript("OnClick", function(self)
        UMPD.useMeters = self:GetChecked()
    end)
    local cbShortNumbers = createCheckbox(UMPDO, UMPD.shortNumbers, "shortNumbers", "Shorten numbers above 1000")
    cbShortNumbers:SetPoint("TOPLEFT", 8, -342)
    cbShortNumbers:HookScript("OnClick", function(self)
        UMPD.shortNumbers = self:GetChecked()
    end)
    local cbFadeMouseOver = createCheckbox(UMPDO, UMPD.fadeMouseOver, "fadeMouseOver", "Fade pin when mousing over it")
    cbFadeMouseOver:SetPoint("TOPLEFT", 8, -372)
    cbFadeMouseOver:HookScript("OnClick", function(self)
        UMPD.fadeMouseOver = self:GetChecked()
    end)

    -- Notes
    local notes = UMPDO:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    notes:SetText("|cffccccccSetting your 'Max Pin Distance' to 0 (zero) will result in unlimited draw distance for pins as your max distance.|r")
    notes:SetPoint("TOP",0,-138)

    -- About
    local aboutRetail = UMPDO:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    aboutRetail:SetText("|cffccccccCreated by |cff00ff96Xamchi|cffcccccc on Tarren Mill (EU)|r")
    aboutRetail:SetPoint("BOTTOM",0,11)
    local aboutForever = UMPDO:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    aboutForever:SetText("|cfff48cbaXam Pew|cffcccccc on PVE (EU)|r")
    aboutForever:SetPoint("BOTTOM",0,0)

    -- Init Done
    _UMPD.init = true
    UMPD_Init = nil
    _UMPD:USER_WAYPOINT_UPDATED()
end

-- Open Settings
function OpenSettings()
    if not InCombatLockdown() then
        Settings.OpenToCategory(UMPDO.category:GetID())
    else
        DEFAULT_CHAT_FRAME:AddMessage(format("%s | Can't modify interface options in combat", _UMPD.name))
    end
end

-- Slash command to open options
SLASH_UMPDO1 = "/umpd"
SlashCmdList.UMPDO = OpenSettings