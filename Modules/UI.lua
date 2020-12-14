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
        text = "Delete",
      },
      {
        value = "F",
        text = "Import",
      },
      {
        value = "G",
        text = "Export",
      }
    }
  },
}

local GMSG_Constants = {
  ["messageOutput"] = {
    ["Public"] = {
      ["TEST"] = "TEST",
      ["GENERAL"] = "GENERAL", -- /1
      ["TRADE"] = "TRADE", -- /2
      ["LFG"] = "LFG", -- /4
    },
    ["Guild"] = {
      ["TEST"] = "TEST", -- Prints expected output.
      ["GUILD"] = "GUILD", -- /g
      ["OFFICER"] = "OFFICER", -- /o
    },
  },
  ["messageOutputOrder"] = {
    ["Public"] = {
      "TEST",
      "GENERAL",
      "TRADE",
      "LFG",
    },
    ["Guild"] = {
      "TEST",
      "GUILD",
      "OFFICER",
    },
  },
  ["defaultFormData"] = {
    ["messageTitle"] = "",
    ["messageBody"] = "",
    ["messageType"] = "",
  }
}

local form_data = GMSG_Constants.defaultFormData
local data
local exportData
local selectedchannel
local previousTitle

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- UI DESIGN
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

    if data.messageType == "Public" then
      chan = GMSG_Constants.messageOutput.Public
      ddbx_chan:SetList(chan, GMSG_Constants.messageOutputOrder.Public)
    else
      chan = GMSG_Constants.messageOutput.Guild
      ddbx_chan:SetList(chan, GMSG_Constants.messageOutputOrder.Guild)
    end

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
  btn_send:SetCallback("OnClick", function(c, e, v)
    local processed, output, channelID, mtype = GMSG:ProcessMessage(selectedchannel)

    if output == "TEST" then
      GMSG:ThrottleMessage(processed, output, channelID)
    elseif mtype == "Guild" then
      GMSG:ThrottleMessage(processed, output, channelID)
    elseif mtype == "Public" then
      SendChatMessage(processed[1], output, nil, channelID)
    end

    -- if mtype == "Guild" then
    --   GMSG:ThrottleMessage(processed, output, channelID)
    -- else
    --   SendChatMessage(processed[1], output, nil, channelID)
    -- end
  end)
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

  -- DDBX: Message Type
  local ddbx_type = UI:Create("Dropdown")
  ddbx_type:SetList({["Guild"] = "Guild", ["Public"] = "Public"})
  ddbx_type:SetLabel("Output")
  ddbx_type:SetCallback("OnValueChanged", function(c, e, v) form_data.messageType = v end)
  container:AddChild(ddbx_type)

  -- EditBox: Message Body
  local ebx_msg_body = UI:Create("MultiLineEditBox")
  ebx_msg_body:SetLabel("Message Body")
  ebx_msg_body:SetMaxLetters(255)
  ebx_msg_body:SetFullWidth(true)
  ebx_msg_body:SetHeight(50)
  ebx_msg_body:DisableButton(false)
  ebx_msg_body:SetCallback("OnEnterPressed", function(c, e, v) form_data.messageBody = v end)
  container:AddChild(ebx_msg_body)

  -- Button: Save
  local btn_save = UI:Create("Button")
  btn_save:SetText("Save")
  btn_save:SetWidth(100)
  btn_save:SetCallback("OnClick", function(c, e, v) GMSG:CreateMsg(form_data) end)
  container:AddChild(btn_save)
end

-- Function: Frame_ManageMessages_Edit()
-- Purpose:  Draw the 'Edit Message' frame.
local function Frame_ManageMessages_Edit(container)
  local head = UI:Create("Heading")
  local desc = UI:Create("Label")
  local head2 = UI:Create("Heading")
  local desc2 = UI:Create("Label")
  local head3 = UI:Create("Heading")
  local ddbx_msg = UI:Create("Dropdown")
  local ebx_msg_title = UI:Create("EditBox")
  local ddbx_type = UI:Create("Dropdown")
  local ebx_msg_body = UI:Create("MultiLineEditBox")
  local btn_edit = UI:Create("Button")

  -- Header
  head:SetText("Edit Message")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  desc:SetText("Edit a new message by filling in the provided form and clicking save.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- Header 2: Select Message
  head2:SetText("Select Message")
  head2:SetRelativeWidth(1)
  container:AddChild(head2)

  -- Description 2: Select Message
  desc2:SetText("Select a message to edit.")
  desc2:SetFullWidth(true)
  container:AddChild(desc2)

  -- DDBX: Message
  ddbx_msg:SetLabel("Message")
  ddbx_msg:SetList(GMSG:GetMessageTitles())
  ddbx_msg:SetValue(1)
  ddbx_msg:SetWidth(150)
  ddbx_msg:SetCallback("OnValueChanged", function(c, e, v)
    data = GMSG:GetMessage(v)
    ebx_msg_title:SetText(data.messageTitle)
    ebx_msg_body:SetText(data.messageBody)
    ddbx_type:SetValue(data.messageType)

    previousTitle = data.messageTitle

    form_data.messageTitle = data.messageTitle
    form_data.messageBody = data.messageBody
    form_data.messageType = data.messageType

  end)
  container:AddChild(ddbx_msg)

  -- Header 3: Edit Content
  head3:SetText("Edit Content")
  head3:SetRelativeWidth(1)
  container:AddChild(head3)

  -- EditBox: Message Title

  ebx_msg_title:SetLabel("Message Title")
  ebx_msg_title:SetMaxLetters(0)
  ebx_msg_title:SetWidth(200)
  ebx_msg_title:SetCallback("OnEnterPressed", function(c, e, v) form_data.messageTitle = v end)
  container:AddChild(ebx_msg_title)

  -- DDBX: Message Type

  ddbx_type:SetList({["Guild"] = "Guild", ["Public"] = "Public"})
  ddbx_type:SetLabel("Output")
  ddbx_type:SetCallback("OnValueChanged", function(c, e, v) form_data.messageType = v end)
  container:AddChild(ddbx_type)

  -- EditBox: Message Body

  ebx_msg_body:SetLabel("Message Body")
  ebx_msg_body:SetMaxLetters(255)
  ebx_msg_body:SetFullWidth(true)
  ebx_msg_body:SetHeight(50)
  ebx_msg_body:DisableButton(false)
  ebx_msg_body:SetCallback("OnEnterPressed", function(c, e, v) form_data.messageBody = v end)
  container:AddChild(ebx_msg_body)

  -- Button: Edit
  btn_edit:SetText("Edit")
  btn_edit:SetWidth(100)
  btn_edit:SetCallback("OnClick", function(c, e, v)
    GMSG:Edit(previousTitle, form_data)
    ddbx_msg:SetList(GMSG:GetMessageTitles())
    ddbx_msg:SetValue(1)
    ebx_msg_title:SetText("")
    ebx_msg_body:SetText("")
    ddbx_type:SetValue(nil)
  end)
  container:AddChild(btn_edit)
end

-- Function: Frame_ManageMessages_Delete()
-- Purpose: Draw the 'Delete Message' frame.
local function Frame_ManageMessages_Delete(container)
  local head = UI:Create("Heading")
  local desc = UI:Create("Label")
  local ddbx_msg = UI:Create("Dropdown")
  local ebx_msg = UI:Create("MultiLineEditBox")
  local btn_del = UI:Create("Button")

  -- Header
  head:SetText("Delete Message")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  desc:SetText("Delete a message by selecting it and clicking delete.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- DDBX: Messages
  ddbx_msg:SetLabel("Message")
  ddbx_msg:SetList(GMSG:GetMessageTitles())
  ddbx_msg:SetValue(1)
  ddbx_msg:SetWidth(150)
  ddbx_msg:SetCallback("OnValueChanged", function(c, e, v)
    data = nil
    data = GMSG:GetMessage(v)
    ebx_msg:SetText(data.messageBody)
  end)
  container:AddChild(ddbx_msg)

  -- EBX: Message
  ebx_msg:SetLabel("Message")
  ebx_msg:SetFullWidth(true)
  ebx_msg:SetNumLines(4)
  ebx_msg:SetDisabled(true)
  ebx_msg:SetMaxLetters(255)
  ebx_msg:DisableButton(true)
  container:AddChild(ebx_msg)

  -- BTN: Delete
  btn_del:SetText("Delete")
  btn_del:SetWidth(100)
  btn_del:SetPoint("RIGHT", 0, 0)
  btn_del:SetCallback("OnClick", function(c, e, v)
    GMSG:Delete(data.messageTitle)
    ddbx_msg:SetList(GMSG:GetMessageTitles())
    ddbx_msg:SetValue(1)
    ddbx_msg:SetText("")
  end)
  container:AddChild(btn_del)
end

local function Frame_ManageMessages_Import(container)

  local head = UI:Create("Heading")
  local desc = UI:Create("Label")
  local ebx_msg = UI:Create("MultiLineEditBox")
  local btn_imp = UI:Create("Button")

  -- Header
  head:SetText("Import Message")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  desc:SetText("Import a given message by pasting the code and clicking the button.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- EBX: Message Text
  ebx_msg:SetLabel("Message Code")
  ebx_msg:SetFullWidth(true)
  container:AddChild(ebx_msg)

  -- BTN: Import
  btn_imp:SetText("Import")
  btn_imp:SetWidth(150)
  btn_imp:SetCallback("OnClick", function(c, e, v)
    local code = ebx_msg:GetText()
    local data = GMSG:Decode(code)
    GMSG:Import(data)
  end)
  container:AddChild(btn_imp)

end


local function Frame_ManageMessages_Export(container)

  local head = UI:Create("Heading")
  local desc = UI:Create("Label")
  local ddbx_msg = UI:Create("Dropdown")
  local ebx_msg = UI:Create("MultiLineEditBox")

  -- Header
  head:SetText("Export Message")
  head:SetRelativeWidth(1)
  container:AddChild(head)

  -- Description
  desc:SetText("Export a given message by selecting it and clicking the button.")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  -- DDBX: Message
  ddbx_msg:SetLabel("Message")
  ddbx_msg:SetList(GMSG:GetMessageTitles())
  ddbx_msg:SetValue(1)
  ddbx_msg:SetWidth(150)
  ddbx_msg:SetCallback("OnValueChanged", function(c, e, v)
    exportData = GMSG:GetMessage(v)
    ebx_msg:SetText(" ")
    local msg_serial = GMSG:Encode(exportData)
    ebx_msg:SetText(msg_serial)
  end)
  container:AddChild(ddbx_msg)

  -- EBX: Message Text
  ebx_msg:SetLabel("Exported Message")
  ebx_msg:SetFullWidth(true)
  ebx_msg:DisableButton(true)
  container:AddChild(ebx_msg)

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
  data = nil
  exportData = nil
  selectedchannel = nil
  previousTitle = nil

  GMSG:Debug("DrawFrame() fired: " .. group)
  if group == "A" then
    Frame_Messages(container)
  elseif group == "B" then
    Frame_ManageMessages(container)
  elseif string.find(group, "C") then
    Frame_ManageMessages_Create(container)
  elseif string.find(group, "D") then
    Frame_ManageMessages_Edit(container)
  elseif string.find(group, "E") then
    Frame_ManageMessages_Delete(container)
  elseif string.find(group, "F") then
    Frame_ManageMessages_Import(container)
  elseif string.find(group, "G") then
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
