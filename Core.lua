-- -- -- -- -- -- -- -- -- --
-- Addon Declaration
-- -- -- -- -- -- -- -- -- --
GuildMessages = LibStub("AceAddon-3.0"):NewAddon("GuildMessages", "AceConsole-3.0")
local GMSG = GuildMessages

-- -- -- -- -- -- -- -- -- --
-- DB Upvalue & Defaults
-- -- -- -- -- -- -- -- -- --
local db
local options
local defaults = {
  profile = {
    messages = { },
    options = {
      minimap = {
        hide       = false,
        minimapPos = 230,
        radius     = 80,
      },
      debug = false,
    },
  }
}

GMSG_Tags = {
  ["{GUILDLINK}"] = nil,
  ["{GUILD}"] = GetGuildInfo("player"),
  ["{ME}"] = UnitName("player"),
}

-------------------------------------
-- VARIABLES AND CONSTANTS
-------------------------------------
local GMSG_Constants = {
  ["messageOutput"] = {
    [1] = "TEST", -- Prints expected output.
    [2] = "SAY", -- /say
    [3] = "EMOTE", -- /emote
    [4] = "YELL", -- /yell
    [5] = "PARTY", -- /party
    [6] = "RAID", -- /raid
    [7] = "RAID_WARNING", -- /rw
    [8] = "INSTANCE_CHAT", -- /i
    [9] = "GUILD", -- /g
    [10] = "OFFICER", -- /o
    [11] = "WHISPER", -- /w <target>
    [12] = "GENERAL", -- /1
    [13] = "TRADE", -- /2
    [14] = "LOCALDEFENSE", -- /3
    [15] = "LFG", -- /4
  },
}

-- -- -- -- -- -- -- -- -- --
-- DEFAULTS & OPTIONS
-- -- -- -- -- -- -- -- -- --

-- Options Table
options = {
  name = "GuildMessages",
  type = "group",
  childGroups = "tree",
  args = {
    --- GENERAL SETTINGS
    settings = {
      name = "Settings",
      type = "group",
      order = 1,
      args = {
        header = {
          type = "header",
          order = 0,
          name = "General Settings"
        },
        debug = {
          name = "Debug Mode",
          desc = "Toggles debug mode. Verbose error reporting.",
          type = "toggle",
          set = function(info, v) db.options.debug = v end,
          get = function(info) return db.options.debug end,
        },
      },
    },
    --- PROFILES
  },
}


function GMSG:OnInitialize()
  -- Register Database and Callbacks
  self.db = LibStub("AceDB-3.0"):New("GuildMessagesDB", defaults, true)
  db = self.db.profile

  -- Register Options Table
  LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildMessages", options)
  -- self:RegisterChatCommand("gmsg", function() LibStub("AceConfigDialog-3.0"):Open("GuildMessages") end)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildMessages")

  -- Get Options Table for Profiles
  options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  self.db.profile.activemessage = nil

  -- Register Chat Commands
  self:RegisterChatCommand("guildmessages", "SlashCommands")
  self:RegisterChatCommand("gmsg", "SlashCommands")

  -- GMSG:InitGuildInfo()
  -- GMSG:InitGuildInfo()
end

function GMSG:OnEnable()
  -- Code
end

function GMSG:OnDisable()
  -- Code
end

-----
function GMSG:GetDB()
  return self.db
end

function GMSG:SetDebug(info, val)
  self.db.profile.options.debug = val
end

function GMSG:GetDebug(info)
  return self.db.profile.options.debug
end

function GMSG:SlashCommands(input)
  if not input or input:trim() == "" then
    ToggleGuildFrame()
    GMSG:InitGuildInfo()
    GMSG:DrawMain()
    if self.db.profile.guildinfo then
      GMSG_Tags["{GUILDLINK}"] = GMSG:GetGuildLink()
    end
    ToggleGuildFrame()
  end
end
