local timer = 0
local UPDATE_INTERVAL = 60
local CHECK_BUFF_MIN_MINUTES = 10
local buffMap = {}
local addonName = "ShowMyTime"
local onEvent = {}
local frame = CreateFrame("Frame", addonName, nil)
local customEvent = "UNIT_AURA"
local maxIndex = 40

function onEvent.UNIT_AURA(event, ...)
    INIT_BUFF_MAP()
    PRINT_EXPIRABLE_BUFF()
end

function INIT_BUFF_MAP()
    for i=1, maxIndex do
        local name,_,_,_,_,expires = UnitAura("player", i)

        if buffMap[name] == nil then
            buffMap[name] = expires
            return
        end

        local oldExpires = buffMap[name]
        if expires > oldExpires then
            buffMap[name] = expires
        end
    end
end

function PRINT_EXPIRABLE_BUFF()
    if next(buffMap) == nil then
        return
    end

    local currentTime = GetTime()

    for name, expires in pairs(buffMap) do
        local remainingSeconds = expires - currentTime
        if remainingSeconds <= 0 then
            print(name .. " expired.")
            return
        end

        local remainingMinutes = remainingSeconds / 60

        if remainingMinutes < CHECK_BUFF_MIN_MINUTES then
            remainingMinutes = math.floor(remainingMinutes)
            print(name .. " remaining " .. remainingMinutes .. " minutes. Less than 60 minutes.")
        end
    end      
end

-- CALLED EVERY ELASPED SECONDS (REF YOUR FPS)
function ON_UPDATE(elapsed)
    timer = timer + elapsed
    if timer < UPDATE_INTERVAL then
        return
    end

    timer = 0

    if next(buffMap) == nil then
        return
    end

    PRINT_EXPIRABLE_BUFF()
end

frame:RegisterUnitEvent(customEvent, "player")
frame:SetScript("OnEvent", function(self, event, ...) onEvent[event](onEvent, ...) end)
frame:SetScript("OnUpdate", function(self, elapsed) ON_UPDATE(elapsed) end)