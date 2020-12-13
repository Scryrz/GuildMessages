-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Module:  UI
-- Purpose: Responsible for the creation and management of all UI elements
--          of the addon.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Grab copy of global addon variable.
local N = ...
local GMSG = LibStub("AceAddon-3.0"):GetAddon(N)
local UI = LibStub("AceGUI-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- VARIABLES & CONSTANTS
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local treeStruct = {
  {
    value = "A",
    text = "Messages",
  },
  {
    value = "B",
    text = "Manage Messages",
    children = {
      {
        value = "C",
        text = "Create",
      },
      {
        value = "D",
        text = "Edit",
      },
      {
        value = "E",
        text = "Export",
      }
    }
  },
}

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
  ["defaultFormData"] = {
    ["messageTitle"] = "",
    ["messageBody"] = "",
    ["enabledChannels"] = {
      ["TEST"] = false,
      ["SAY"] = false,
      ["EMOTE"] = false,
      ["YELL"] = false,
      ["PARTY"] = false,
      ["RAID"] = false,
      ["RAID_WARNING"] = false,
      ["INSTANCE_CHAT"] = false,
      ["GUILD"] = false,
      ["OFFICER"] = false,
      ["WHISPER"] = false,
      ["GENERAL"] = false,
      ["TRADE"] = false,
      ["LOCALDEFENSE"] = false,
      ["LFG"] = false,
    },
  }
}

local cbx_list = { } -- List of Checkboxes Created
local form_data = GMSG_Constants.defaultFormData
local data
local selectedchannel

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- UI DESIGN
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function TestPrintVals(c, e, v)
  for key, val in pairs(c.userdata) do
    GMSG:Debug(c:GetUserData("Output"))
    GMSG:Debug(tostring(c:GetValue()))
  end
end

local function UpdateOutput(v)
  local chan = v:GetUserData("Output")
  local value = v:GetValue()

  form_data.enabledChannels[chan] = value
end

local function PrintFormData()
  GMSG:Debug("Title: " .. form_data.messageTitle)
  GMSG:Debug("Body: " .. form_data.messageBody)
  GMSG:Debug("Channels:")
  for k, v in pairs(form_data.enabledChannels) do
    GMSG:Debug("Chan: " .. k .. " | E: " .. tostring(v))
  end
end


-- -- -- -- -- -- -- -- -- --
-- MODULES
-- -- -- -- -- -- -- -- -- --
-- Function: Frame_Messages()
-- Purpose:  Draw the 'Messages' frame.
local function Frame_Messages(container)
  -- Creates
  local head = UI:Create("Heading")
  local desc = UI:Create("Label")
  local ddbx_chan = UI:Create("Dropdown")
  local ddbx_msg = UI:Create("Dropdown")
  local ebx_msg = UI:Create("MultiLineEditBox")
  local btn_send = UI:Create("Button")

  -- Header
  head:SetText("Messages")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  desc:SetText("Select and send messages here!")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- Message Selection Dropdown
  ddbx_msg:SetLabel("Message")
  ddbx_msg:SetList(GMSG:GetMessageTitles())
  ddbx_msg:SetValue(1)
  ddbx_msg:SetWidth(150)
  ddbx_msg:SetCallback("OnValueChanged", function(c, e, v)
    data = GMSG:GetMessage(v)
    local chan = { }
    for k, v in pairs(data.enabledChannels) do
      if v == true then
        chan[k] = k
      end
    end
    ddbx_chan:SetList(chan)
    ddbx_chan:SetValue(1)
    ebx_msg:SetText(data.messageBody)
  end)
  container:AddChild(ddbx_msg)

  -- Channel Selection
  ddbx_chan:SetLabel("Channel")
  ddbx_chan:SetWidth(150)
  ddbx_chan:SetCallback("OnValueChanged", function(c, e, v) selectedchannel = v end)
  container:AddChild(ddbx_chan)

  -- Message Text
  ebx_msg:SetLabel("Message")
  ebx_msg:SetFullWidth(true)
  ebx_msg:SetNumLines(4)
  ebx_msg:SetDisabled(true)
  ebx_msg:SetMaxLetters(255)
  ebx_msg:DisableButton(true)
  container:AddChild(ebx_msg)

  -- Message Send Button
  btn_send:SetText("Send")
  btn_send:SetWidth(100)
  btn_send:SetPoint("RIGHT", 0, 0)
  btn_send:SetCallback("OnClick", function(c, e, v) GMSG:SendMessage(selectedchannel) end)
  container:AddChild(btn_send)

end

-- Function: Frame_ManageMessages_Create()
-- Purpose:  Draw the 'Create Message' frame.
local function Frame_ManageMessages_Create(container)
  -- Header
  local head = UI:Create("Heading")
  head:SetText("Create New Message")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  local desc = UI:Create("Label")
  desc:SetText("Create a new message by filling in the provided form and clicking save.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- EditBox: Message Title
  local ebx_msg_title = UI:Create("EditBox")
  ebx_msg_title:SetLabel("Message Title")
  ebx_msg_title:SetMaxLetters(0)
  ebx_msg_title:SetWidth(200)
  ebx_msg_title:SetCallback("OnEnterPressed", function(c, e, v) form_data.messageTitle = v end)
  container:AddChild(ebx_msg_title)

  -- EditBox: Message Body
  local ebx_msg_body = UI:Create("EditBox")
  ebx_msg_body:SetLabel("Message Body")
  ebx_msg_body:SetMaxLetters(255)
  ebx_msg_body:SetFullWidth(true)
  ebx_msg_body:SetHeight(50)
  ebx_msg_body:DisableButton(false)
  ebx_msg_body:SetCallback("OnEnterPressed", function(c, e, v) form_data.messageBody = v end)
  container:AddChild(ebx_msg_body)

  -- MultiSelect: Message Type
  for k, v in ipairs(GMSG_Constants.messageOutput) do
    local cbx = UI:Create("CheckBox")
    cbx:SetValue(false)
    cbx:SetType("checkbox")
    cbx:SetLabel(v)
    cbx:SetUserData("Output", v)
    cbx:SetCallback("OnValueChanged", UpdateOutput)
    container:AddChild(cbx)

    cbx_list[k] = {v, cbx}
  end

  -- Button: Save
  local btn_save = UI:Create("Button")
  btn_save:SetText("Save")
  btn_save:SetWidth(100)
  btn_save:SetCallback("OnClick", function(c, e, v) GMSG:CreateMsg(form_data) end)
  container:AddChild(btn_save)
end

-- -- -- -- -- -- -- -- -- --
-- UTILITY
-- -- -- -- -- -- -- -- -- --
-- Function: DrawFrame(frame)
-- Purpose:  Draws the frame that corresponds the value piped through
--           individual tree item callbacks.
local function DrawFrame(container, event, group)
  container:ReleaseChildren()
  -- Reset Local Data
  cbx_list = { }
  form_data = GMSG_Constants.defaultFormData

  GMSG:Debug("DrawFrame() fired: " .. group)
  if group == "A" then
    Frame_Messages(container)
  elseif group == "B" then
    Frame_ManageMessages(container)
  elseif group ~= "C" then
    Frame_ManageMessages_Create(container)
  elseif group ~= "D" then
    Frame_ManageMessages_Edit(container)
  elseif group ~= "E" then
    Frame_ManageMessages_Export(container)
  end
end

-- -- -- -- -- -- -- -- -- --
-- MAIN FRAME
-- -- -- -- -- -- -- -- -- --
-- Function: DrawMain()
-- Purpose:  Draws the main frame of the addon on request.
function GMSG:DrawMain()
  local frame = UI:Create("Frame")
  frame:SetTitle("Guild Messages")
  frame:SetStatusText("GuildMessages || v0.0.1 || For <Isometric> by Ayr")
  frame:SetCallback("OnClose", function(widget) UI:Release(widget) end)
  frame:SetLayout("Fill")

  -- TREE GROUP
  local tree = UI:Create("TreeGroup")
  tree:SetFullHeight(true)
  tree:SetLayout("Flow")
  tree:SetTree(treeStruct)
  tree:SetCallback("OnGroupSelected", DrawFrame)
  frame:AddChild(tree)
  tree:SelectByPath("A")
end
