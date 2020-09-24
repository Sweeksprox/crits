local playerGUID = UnitGUID("player")
local MSG_PLAYER_CRIT = "CRITICAL"
local soundPath = "Interface\\AddOns\\Crits\\moan%d.ogg"
local soundChannel = "Master"

local damageEvents = {
	SPELL_DAMAGE = true,
	SWING_DAMAGE = true
}

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
	self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)

function f:OnEvent(event, ...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellId, spellName, spellSchool
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

    if subevent == "SWING_DAMAGE" then
    	amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_DAMAGE" then
    	spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    end

    if critical and sourceGUID == playerGUID then
    	print(math.random(0,2))
    	script = PlaySoundFile(string.format(soundPath, math.random(0,2)), "Dialog")
    end
end