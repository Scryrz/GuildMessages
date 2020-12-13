GuildMessages = LibStub("AceAddon-3.0"):NewAddon("GuildMessages", "AceConsole-3.0")
-- TODO: FIX ME
-- GuildMessages:RegisterChatCommand("gmsg", "GMSG:OpenOptions")
local GMSG = GuildMessages

-- REGISTER LDB
local GMSG_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GuildMessages", {
  type = "launcher",
  text = "Guild Messages",
  icon = "Interface\\Addons\\GuildMessages\\icon",
  OnClick = function(_, msg)
    if msg == "LeftButton" then
      GMSG:Print("Function not yet implemented!")
    elseif msg == "RightButton" then
      GMSG:InitMenu() --TODO: DO INITMENU()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine("Guild Messages")
    tooltip:AddLine("Right click to open the menu!")
  end,
})

-- REGISTER ICON
local GMSG_Icon = LibStub("LibDBIcon-1.0")

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

-- DEFAULTS
local defaults = {
  profile = {
    messages = { },
    options = {
      minimap = {
        hide = false,
        minimapPos = 230,
        radius = 80,
      },
      debug = false,
    },
  }
}

function GMSG:OnInitialize()
  -- Check if the user has admin priviliges
  local isAdmin = GMSG:IsAdmin()

  -- Register Database and Callbacks
  self.db = LibStub("AceDB-3.0"):New("GuildMessagesDB", defaults, true)
--  TODO: GMSG:RefreshConfig()
--  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
--  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
--  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  -- OPTIONS
  local options = {
    name = "GuildMessages",
    type = "group",
    childGroups = "tree",
    args = {
      manage = {
        name = "Manage Messages",
        type = "group",
        order = 0,
        args = {
          --- MANAGE MESSAGES
          header = {
            type = "header",
            order = 0,
            name = "Manage Messages"
          },
          desc = {
            type = "description",
            name = "If you don\'t know what you're doing, you\'re in the wrong place! This section is for creating, editing, and deleting messages.\n\n"
                   .."To create a new message, click on Create!\n"
                   .."To edit or delete a message, click on Edit!\n"
                   .."To export a message, click on Export!",
          },
          create = {
            name = "Create",
            type = "group",
            order = 0,
            args = {
              header = {
                type = "header",
                order = 0,
                name = "Create New Message"
              },
              desc = {
                type = "description",
                order = 1,
                name = "Create and save a message to later be sent to a channel of your choice."
              },
              msg_type = {
                type = "multiselect",
                order = 2,
                name = "Message Type",
                values = GMSG_Constants.chatTypesLocale,
                get = nil,
                set = nil
              },
              msg_title = {
                type = "input",
                order = 3,
                name = "Message Title",
                get = nil,
                set = nil
              },
              msg_body = {
                type = "input",
                order = 4,
                width = "full",
                name = "Message Body",
                multiline = 4,
                get = nil,
                set = nil
              }
            },
          },
          edit = {
            name = "Edit",
            type = "group",
            order = 1,
            args = {
              header = {
                type = "header",
                order = 0,
                name = "Edit Message"
              },
            },
          },
          export = {
            name = "Export",
            type = "group",
            order = 2,
            args = {
              header = {
                type = "header",
                order = 0,
                name = "Export Message"
              },
            },
          },
        },
      },
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
            set = function(info,val) if (self.db.profile.options.debug) then self.db.profile.options.debug = false else self.db.profile.options.debug = true end end,
            get = function(info) return self.db.profile.options.debug end,
          },
        },
      },
      --- PROFILES
      profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
    }
  }

  self.db.profile.activemessage = nil

  -- Register Options Table
  LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildMessages", options)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildMessages")

  -- TEMP: DRAW FRAME
  GMSG:DrawMain()

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
