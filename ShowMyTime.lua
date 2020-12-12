function PRINT_BUFF_REMAINING_SECONDS()
    local maxIndex = 40
    for i=1, maxIndex do
        local name,_,_,_,_,expires = UnitAura("player", i)
        
        if name == nil then
            break 
        end

        local currentTime = GetTime()
        local remainingSeconds = expires - currentTime

        if remainingSeconds > 0 then
            print(name .. " remaining " .. remainingSeconds .. " seconds")
        end
    end
end

local addonName = "ShowMyTime"
local onEvent = {}
local frame = CreateFrame("Frame", addonName, nil)
local customEvent = "UNIT_AURA"

function onEvent.UNIT_AURA(event, ...)
    PRINT_BUFF_REMAINING_SECONDS()
end

frame:RegisterUnitEvent(customEvent, "player")
frame:SetScript("OnEvent", function(self, event, ...) onEvent[event](onEvent, ...) end)