-- Grab copy of global addon variable.
local N = ...
local GMSG = LibStub("AceAddon-3.0"):GetAddon(N)

function GMSG:Debug(text)
  if self.db.profile.options.debug then
    GMSG:Print(" |cffC6AC54[DEBUG]|r " .. text)
  end
end

-- Function: IsAdmin()
-- Purpose:  Returns true if the current character meets the minimum guild rank
--           required, otherwise returns false. Used to enable/disable the
--           'Admin' tab.
function GMSG:IsAdmin()
  -- TODO: Refactor this to allow users to specify "admin" ranks via options.
  --       Search list of admins, if user has rank in list, true; else, false.
  --       Possibly just do "Minimum rank required" and then add <= logic?
  --       Less memory intensive than iterating over a table of ranks.
  local _, grank, grankindex = GetGuildInfo("player")
  if grankindex <= 3 then
    return true
  else
    return false
  end
end

-- Function: CreateMsg()
-- Purpose:  Saves a new message to self.db.messages
function GMSG:CreateMsg(table)
  local title = table.messageTitle
  local body = table.messageBody
  local channels = table.enabledChannels

  self.db.profile.messages[title] = {
    messageBody = body,
    enabledChannels = channels
  }

  GMSG:Debug("Message created!")
  GMSG:Debug("Title: " .. title)
  GMSG:Debug("Body: " .. body)
  GMSG:Debug("Channels: ")
  for key, val in pairs(channels) do
    if v == true then
      GMSG:Debug("C: " .. key .. " | V: " .. tostring(val))
    end
  end
end

function GMSG:GetMessageTitles()
  local message_titles = { }
  for k, _ in pairs(self.db.profile.messages) do
    -- tinsert(message_titles, k)
    message_titles[k] = k
  end

  return message_titles
end

function GMSG:GetMessage(title)
  for k, _ in pairs(self.db.profile.messages) do
    if k == title then
      self.db.profile.activemessage = self.db.profile.messages[k]
      self.db.profile.activemessage.messageTitle = k
    end
  end

  GMSG:Debug("(GetMessages) Active Msg Title: " .. self.db.profile.activemessage.messageTitle)
  GMSG:Debug("(GetMessages) Active Msg Body: " .. self.db.profile.activemessage.messageBody)
  return self.db.profile.activemessage
end

function GMSG:SendMessage(channel)
  if not channel then return end

  local message = self.db.profile.activemessage
  local channel = channel
  local channelID

  if channel == "TEST" then
    GMSG:Print(message.messageBody)
    return
  elseif channel == "TRADE" then
    channel = "channel"
    channelID = GetChannelName("Trade - City")
    if not channelID then
      GMSG:Print("ERROR: You are not in a city with trade!")
      return
    end
  elseif channel == "GENERAL" then
    channel = "channel"
    channelID = GetChannelName("General - " .. GetZoneText())
    if not channelID then
      GMSG:Print("ERROR: You are not in a city with trade!")
      return
    end
  end
  SendChatMessage(message.messageBody, channel, nil, channelID)
  GMSG:Debug("Message (" .. message.messageTitle .. ") sent to " .. channel .. "!")
end

function GMSG:OpenOptions()
  InterfaceOptionsFrame_OpenToCategory("GuildMessages")
end
