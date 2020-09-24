Crits = LibStub("AceAddon-3.0"):NewAddon("Crits", "AceConsole-3.0", "AceEvent-3.0")

local playerGUID = UnitGUID("player")
local soundChannel = "Dialog"
local soundPaths = {
    Owen = {
        path = "Interface\\AddOns\\Crits\\Sound\\owen%d.ogg",
        variants = 1
    },
    Damage = {
        path = "Interface\\AddOns\\Crits\\Sound\\thatsalotofdamage%d.ogg",
        variants = 1
    },
    Anime = {
        path = "Interface\\AddOns\\Crits\\Sound\\moan%d.ogg",
        variants = 3
    }
}

local options = {
    name = "Crits",
    handler = Crits,
    type = "group",
    args = {
        spelldamage = {
            type = "toggle",
            name = "Spell Damage",
            desc = "Toggles spell damage critical trigger events",
            get = "GetSpellDamageOn",
            set = "SetSpellDamageOn",
        },
        spellheal = {
            type = "toggle",
            name = "Spell Heal",
            desc = "Toggles spell heal critical trigger events",
            get = "GetSpellHealOn",
            set = "SetSpellHealOn",
        },
        swingdamage = {
            type = "toggle",
            name = "Swing Damage",
            desc = "Toggles swing damage critical trigger events",
            get = "GetSwingDamageOn",
            set = "SetSwingDamageOn",
        },
        sound = {
            type = "input",
            name = "Sound Clip",
            desc = "The sound clip to play on a critical.",
            usage = "0: Owen, 1: That's a lot of damage, 2: Anime Moans",
            get = "GetSoundClip",
            set = "SetSoundClip",
        }
    }
}

local defaults = {
    profile = {
        spellDamageTriggerOn = true,
        spellHealTriggerOn = true,
        swingDamageTriggerOn = true,
        soundClip = "Owen"
    },
}

function Crits:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("CritsDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Crits", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Crits", "Crits")
    self:RegisterChatCommand("crits", "ChatCommand")
end

function Crits:OnEnable()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Crits:COMBAT_LOG_EVENT_UNFILTERED(event)
    self:OnEvent(event, CombatLogGetCurrentEventInfo())
end

function Crits:OnEvent(event, ...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellId, spellName, spellSchool
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

    if subevent == "SWING_DAMAGE" and self.db.profile.swingDamageTriggerOn then
    	amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_DAMAGE" and self.db.profile.spellDamageTriggerOn then
    	spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_HEAL" and self.db.profile.spellHealTriggerOn then
    	spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
    end

    if critical and sourceGUID == playerGUID then
    	script = PlaySoundFile(string.format(soundPaths[self.db.profile.soundClip].path, math.random(0,soundPaths[self.db.profile.soundClip].variants - 1)), soundChannel)
    end
end

function Crits:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("crits", "Crits", input)
    end
end

function Crits:GetSpellDamageOn(info)
    return self.db.profile.spellDamageTriggerOn
end

function Crits:SetSpellDamageOn(info, value)
    self.db.profile.spellDamageTriggerOn = value
    print("Spell damage critical event sound", value)
end

function Crits:GetSpellHealOn(info)
    return self.db.profile.spellHealTriggerOn
end

function Crits:SetSpellHealOn(info, value)
    self.db.profile.spellHealTriggerOn = value
    print("Spell heal critical event sound", value)
end

function Crits:GetSwingDamageOn(info)
    return self.db.profile.swingDamageTriggerOn
end

function Crits:SetSwingDamageOn(info, value)
    self.db.profile.swingDamageTriggerOn = value
    print("Swing damage critical event sound", value)
end

function Crits:GetSoundClip(info)
    return self.db.profile.soundClip
end

function Crits:SetSoundClip(info, value)
    if value == "0" then
        value = "Owen"
    elseif value == "1" then
        value = "Damage"
    elseif value == "2" then
        value = "Anime"
    else
        print("Invalid, 0: Owen Wilson, 1: Damage, 2: Anime")
        value = "0"
    end

    self.db.profile.soundClip = value
    print("Set sound clip to", value)
end