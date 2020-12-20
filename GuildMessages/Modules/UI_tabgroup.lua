local GMSG = GuildMessages
local AceGUI = LibStub("AceGUI-3.0")

-- Admin Status
local isAdmin = GMSG:IsAdmin()

-- Tabs
local tabs = {
  {text = "Guild", value = "tab_guild"},
  {text = "Public", value = "tab_public"},
  {text = "Admin", value = "tab_admin", disabled = not isAdmin}
}

-- Message Types
local message_types = {GUILD = "Guild", PUBLIC = "Public"}

-------------------------------------
-- MISC: UTIL FUNCTIONS
-------------------------------------



-------------------------------------
-- TAB 1: GUILD MESSAGES
-------------------------------------

local function DrawTab_Guild(container)
  -- Header
  local head = AceGUI:Create("Heading")
  head:SetText("Guild Messages")
  container:AddChild(head)

  -- Label (Footer)
  local desc = AceGUI:Create("Label")
  desc:SetText("Messages handled in this tab will be sent to guild chat.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  local ddbx_guild = AceGUI:Create("Dropdown")
  GMSG:populateDropdown(ddbx_guild, "guild")
  ddbx_guild:SetValue(1)
  ddbx_guild:SetLabel("Select a message to send.")
  ddbx_guild:SetWidth(200)
  container:AddChild(ddbx_guild)

  -- Send Button
  local btn_send = AceGUI:Create("Button")
  btn_send:SetText("Send")
  btn_send:SetWidth(100)
  container:AddChild(btn_send)

  -- Edit Box (Show Messages)
  local ebx_guild = AceGUI:Create("MultiLineEditBox")
  -- ebx_guild:SetText("Testing the multiline editbox feature.")
  ebx_guild:SetLabel("Message to be sent:")
  ebx_guild:SetNumLines(4)
  ebx_guild:SetDisabled(true)
  ebx_guild:SetMaxLetters(255)
  ebx_guild:DisableButton(true)
  ebx_guild:SetFullWidth(true)
  container:AddChild(ebx_guild)

  ddbx_guild:SetCallback("OnValueChanged", function(info, name, key)
    ebx_guild:SetText(guild_macros[key].messageBody)
  end)
end

-------------------------------------
-- TAB 2: PUBLIC MESSAGES
-------------------------------------

local function DrawTab_Public(container)
  -- Header
  local head = AceGUI:Create("Heading")
  head:SetText("Public Messages")
  container:AddChild(head)

  -- Label (Footer)
  local desc = AceGUI:Create("Label")
  desc:SetText("Messages handled in this tab will be sent to the chosen public channel.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  local ddbx_public = AceGUI:Create("Dropdown")
  GMSG:populateDropdown(ddbx_public, "public")
  ddbx_public:SetValue(1)
  ddbx_public:SetLabel("Select a message to send.")
  ddbx_public:SetWidth(200)
  container:AddChild(ddbx_public)

  -- Send Button
  local btn_send = AceGUI:Create("Button")
  btn_send:SetText("Send")
  btn_send:SetWidth(100)
  container:AddChild(btn_send)

  -- Edit Box (Show Messages)
  local ebx_public = AceGUI:Create("MultiLineEditBox")
  -- ebx_guild:SetText("Testing the multiline editbox feature.")
  ebx_public:SetLabel("Message to be sent:")
  ebx_public:SetNumLines(4)
  ebx_public:SetDisabled(true)
  ebx_public:SetMaxLetters(255)
  ebx_public:DisableButton(true)
  ebx_public:SetFullWidth(true)
  container:AddChild(ebx_public)

  ddbx_public:SetCallback("OnValueChanged", function(info, name, key)
    ebx_public:SetText(guild_macros[key].messageBody)
  end)
end


-------------------------------------
-- TAB 3: ADMIN
-------------------------------------

local function DrawTab_Admin(container)
  local head = AceGUI:Create("Heading")
  head:SetText("Administrative Functions")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  local desc = AceGUI:Create("Label")
  desc:SetText("If you don't know what you're doing, you probably shouldn't be here! This is for creating, editing, and deleting messages.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- CREATE MESSAGES
  local headb = AceGUI:Create("Heading")
  headb:SetText("Create New Message")
  headb:SetRelativeWidth(1)
  container:AddChild(headb)

  local ddbx_type = AceGUI:Create("Dropdown")
  ddbx_type:SetList(message_types)
  ddbx_type:SetLabel("Message Type")
  ddbx_type:SetWidth(100)
  container:AddChild(ddbx_type)

  local ebx_name = AceGUI:Create("EditBox")
  ebx_name:SetLabel("Message Title")
  ebx_name:SetMaxLetters(0)
  ebx_name:SetWidth(200)
  container:AddChild(ebx_name)

  local ebx_msg = AceGUI:Create("MultiLineEditBox")
  ebx_msg:SetLabel("Message Body")
  ebx_msg:SetMaxLetters(255)
  ebx_msg:SetNumLines(4)
  ebx_msg:SetFullWidth(true)
  container:AddChild(ebx_msg)

  local btn_create = AceGUI:Create("Button")
  btn_create:SetText("Create")
  btn_create:SetWidth(200)
  btn_create:SetCallback("OnClick", function(widget) GMSG:CreateMsg(ebx_name:GetText(), message_types[ddbx_type:GetValue()], ebx_msg:GetText()) end)
  container:AddChild(btn_create)

  -- EDIT MESSAGES
  local headc = AceGUI:Create("Heading")
  headc:SetText("Edit Message")
  headc:SetRelativeWidth(1)
  container:AddChild(headc)

  local ddbx_msg = AceGUI:Create("Dropdown")
  ddbx_msg:SetLabel("Message")
  ddbx_msg:SetWidth(200)
  container:AddChild(ddbx_msg)

  local headd = AceGUI:Create("Heading")
  headd:SetText("Delete Message")
  headd:SetRelativeWidth(1)
  container:AddChild(headd)

  local ddbx_msgb = AceGUI:Create("Dropdown")
  ddbx_msgb:SetLabel("Message")
  ddbx_msgb:SetWidth(200)
  container:AddChild(ddbx_msgb)

end

-------------------------------------
-- MISC: UI UTIL
-------------------------------------

-- Callback Function: OnGroupSelected
local function SelectGroup(container, event, group)
  container:ReleaseChildren()
  if group == "tab_guild" then
    DrawTab_Guild(container)
  elseif group == "tab_public" then
    DrawTab_Public(container)
  elseif group == "tab_admin" then
    if isAdmin then
      DrawTab_Admin(container)
    end
  else
    GMU:Debug("Tab not found!")
  end
end

-- Create Parent Frame (Container)
local frame = AceGUI:Create("Frame")
frame:SetTitle("Guild Messages")
frame:SetStatusText("Guild Messages | v0.0.1 | Created for Isometric-Proudmoore by Ayr")
frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
frame:SetWidth(400)
frame:SetLayout("Fill")

-- Create TabGroup
local tab_group = AceGUI:Create("TabGroup")
tab_group:SetLayout("Flow")
tab_group:SetTabs(tabs)
tab_group:SetCallback("OnGroupSelected", SelectGroup)
tab_group:SelectTab("tab_guild")
frame:AddChild(tab_group)
