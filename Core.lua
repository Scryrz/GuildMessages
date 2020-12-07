GuildMessages = LibStub("AceAddon-3.0"):NewAddon("GuildMessages", "AceConsole-3.0")
local GMSG = GuildMessages

local defaults = {
  profile = {
    messages = {
      ["Test Message"] = {
        ["messageType"] = "public",
        ["messageBody"] = "This is an example message!"
      }
    }
  }
}

local options = {
  name = "GuildMessages",
  handler = GMSG,
  type = 'group',
  args = {
  }
}

function GMSG:OnInitialize()
  -- Register Database
  self.db = LibStub("AceDB-3.0"):New("GuildMessagesDB", defaults, true)
  -- Register Options Table
  LibStub("AceConfig-3.0"):RegisterOptionsTable("GuildMessages", options)
  options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GuildMessages", "GuildMessages")

  -- Check if the user has admin priviliges
  local isAdmin = GMSG:IsAdmin()

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
