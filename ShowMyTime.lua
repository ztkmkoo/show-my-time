local app = select(2, ...);
local timer = 0
local UPDATE_INTERVAL = 60
local CHECK_BUFF_MIN_MINUTES = 10
local buffMap = {}
local addonName = "ShowMyTime"
local onEvent = {}
local frame = CreateFrame("Frame", addonName, nil)
local customEvent = "UNIT_AURA"
local maxIndex = 40
local lastReport = 0

function onEvent.UNIT_AURA(event, ...)
    INIT_BUFF_MAP()
    PRINT_EXPIRABLE_BUFF()
end

function INIT_BUFF_MAP()
    -- initialize buff map
    for _, v in ipairs(app.SpellIdDB) do
        buffMap[v] = -1;

        local name = = GetSpellInfo(v)
        app.SpellNameDB[v] = name

        print(v .. ": " .. name)
    end
      
    for i=1, maxIndex do
        local name,_,_,_,duration,expirationTime,_,_,_,spellId = UnitAura("player", i)

        if name == nil then
            return
        end

        if duration > 0 then
            buffMap[spellId] = expirationTime
        end
    end
end

function PRINT_EXPIRABLE_BUFF()
    if next(buffMap) == nil then
        return
    end

    local currentTime = GetTime()

    if lastReport > 0 then
        local elapsedFromLast = currentTime - lastReport
        if elapsedFromLast < UPDATE_INTERVAL then
            return
        end
    end

    lastReport = currentTime

    for spellId, expires in pairs(buffMap) do
        name = app.SpellNameDB[spellId]

        if expires < 0 then
            print(name .. " is not registered.")
        else
            local remainingSeconds = expires - currentTime
            if remainingSeconds <= 0 then
                print(name .. " expired.")
                buffMap[name] = -1
                return
            end

            local remainingMinutes = remainingSeconds / 60

            if remainingMinutes < CHECK_BUFF_MIN_MINUTES then
                remainingMinutes = math.floor(remainingMinutes)
                remainingSeconds = remainingSeconds - remainingMinutes * 60
                print(name .. " remaining " .. remainingMinutes .. " min" remainingSeconds .. "s. Less than " .. CHECK_BUFF_MIN_MINUTES .. " minutes.")
            end
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