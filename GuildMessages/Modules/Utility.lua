-- Grab copy of global addon variable.
local N = ...
local GMSG = LibStub("AceAddon-3.0"):GetAddon(N)


-- -- -- -- -- -- -- -- -- --
-- TAG SYSTEM
-- -- -- -- -- -- -- -- -- --
-- Function: Debug(text)
-- Purpose:  Prints a debug message to chat for dev purposes. Only active if
--           self.db.profiles.options.debug == true
-- Param:    text - text to be shown in the debug message.
function GMSG:Debug(text)
  if self.db.profile.options.debug then
    GMSG:Print(" |cffC6AC54[DEBUG]|r " .. text)
  end
end

-- Function: CreateMsg()
-- Purpose:  Saves a new message to self.db.messages
-- Param:    table - table of message data.
function GMSG:CreateMsg(table)
  local title = table.messageTitle
  local body = table.messageBody
  local mtype = table.messageType

  -- Check if a message with that title already exists.
  local isUnique = GMSG:IsUnique(title)

  -- Message is unique, write to memory.
  if isUnique == true then
    self.db.profile.messages[title] = {
      messageTitle = title,
      messageBody = body,
      messageType = mtype
    }

    GMSG:Print("Message created: " .. title)
  -- Duplicate message found. Do not write to memory and break.
  elseif isUnique == false then
    GMSG:Print("ERROR: Duplicate message found! Either edit that message, or delete it.")
    return
  end
end

-- Function: GetMessageTitles()
-- Purpose:  Returns a list of message titles.
-- Return:   message_titles - table of message titles.
function GMSG:GetMessageTitles()
  local message_titles = { }
  for k, _ in pairs(self.db.profile.messages) do
    -- tinsert(message_titles, k)
    message_titles[k] = k
  end

  return message_titles
end

-- Function: GetMessage()
-- Desc:     Returns a message object.
-- Param:    title - The title (index) of the message in self.db.profile.messages
-- Return:   self.db.profile.activemessage - A table representation of a message object.
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

-- Function: CheckDupes()
-- Desc:     Checks if a duplicate message exists on creation.
-- Param:    title - given message title to find
-- Return:   true  - message is unique
--           false - message is a duplicate
function GMSG:IsUnique(title)
  local isUnique = true

  GMSG:Debug("(IsUnique) Called...")

  -- TODO: Explicit true is janky logic. Rework at some point?
  for k, _ in pairs(self.db.profile.messages) do
    if k == title then
      GMSG:Debug("(IsUnique) Title: " .. title)
      GMSG:Debug("(IsUnique) K: " .. k)
      isUnique = false
      break
    end
  end

  GMSG:Debug("(IsUnique) Status: " .. tostring(isUnique))
  return isUnique
end

-- Function: ProcessMessage()
-- Param:    channel - intended output of the message
function GMSG:ProcessMessage(channel)
  if not channel then return end

  local message = self.db.profile.activemessage
  local body = message.messageBody -- Message body.
  local tagged = GMSG:ParseTags(body)
  local processed = GMSG:SplitString(tagged) -- Table of message lines.
  local output, channelID = GMSG:ProcessChannel(channel)

  return processed, output, channelID, message.messageType
end

-- Function: ProcessChannel()
-- Desc:     Finds desired output channel, returns associated data.
-- Param:    channel   - string representation of an in-game chat channel.
-- Return:   output    - string representation of channel type
--           channelID - string representation of full channel name (ID)
function GMSG:ProcessChannel(channel)
  local output, channelID
  if channel == "TEST" then
    output = "TEST"
    channelID = nil
  elseif channel == "GENERAL" then
    output = "channel"
    channelID = GetChannelName("General - " .. GetZoneText())
  elseif channel == "TRADE" then
    output = "channel"
    channelID = GetChannelName("Trade - City")
    if not channelID then
      GMSG:Print("ERROR: You are not in an area with Trade!")
      return
    end
  elseif channel == "LFG" then
    output = "channel"
    channelId = GetChannelName("LookingForGroup")
    if not channelID then
      GMSG:Print("ERROR: You are not in an area with Trade!")
      return
    end
  elseif channel == "GUILD" then
    output = "GUILD"
    channelID = nil
  elseif channel == "OFFICER" then
    output = "OFFICER"
    channelID = nil
  end

  return output, channelID
end


-- Function: ThrottleMessage()
-- Desc:     Sends a line of the message every 0.5s.
-- Param:    table     - table of lines of message to be sent
--           output    - intended output of the message
--           channelID - ID of the output channel (for public channels)
function GMSG:ThrottleMessage(table, output, channelID)
  local index = 1

  C_Timer.NewTicker(0.5, function()
    if output == "TEST" then
      GMSG:Print(table[index])
    else
      SendChatMessage(table[index], output, nil, channelID)
    end

    index = index + 1
  end, #table)
end

-- Function: SplitString()
-- Desc:     Splits messages into a table of lines on \n.
-- Param:    table - message to be split
-- Return:   lines - table of individual message lines
function GMSG:SplitString(table)
  local input = table
  local lines = { strsplit("\n", input) }
  return lines
end

-- Function: ParseTags()
-- Desc:     Parses string pre-split for any tags.
-- Param:    str - string to be parsed
-- Return:   input - parsed string with included tag replacements
function GMSG:ParseTags(str)
  if not str then return end
  local input = str
  for k, v in pairs(GMSG_Tags) do
    if input:find(k) then
      input = string.gsub(input, k, v)
    end
  end
  return input
end

-- Function: OpenOptions()
-- Desc:     Opens the options panel.
function GMSG:OpenOptions()
  InterfaceOptionsFrame_OpenToCategory("GuildMessages")
end

-- Function: Encode()
-- Desc:     Serializes messages for export.
-- Return:   dataEncoded - string of encoded input data.
function GMSG:Encode(content)
  local SER = LibStub("AceSerializer-3.0")
  local DEF = LibStub("LibDeflate")

  if (SER and DEF) then
    local dataSerialized = SER:Serialize(content)
    if (dataSerialized) then
      local dataCompressed = DEF:CompressDeflate(dataSerialized, {level = 9})
      if (dataCompressed) then
        local dataEncoded = DEF:EncodeForPrint(dataCompressed)
        return dataEncoded
      end
    end
  end
end

-- Function: Decode()
-- Desc:     Deserializes messages for import.
-- Param:    content - string of encoded data.
-- Return:   data    - table representation of decoded message object.
--           false   - an error occured somewhere in the decoding process.
function GMSG:Decode(content)
  local SER = LibStub("AceSerializer-3.0")
  local DEF = LibStub("LibDeflate")

  if (SER and DEF) then
    local dataCompressed
    dataCompressed = DEF:DecodeForPrint(content)
    if (not dataCompressed) then
      GMSG:Debug("Couldn't decode data!")
      return false
    end

    local dataSerialized = DEF:DecompressDeflate(dataCompressed)
    if (not dataSerialized) then
      GMSG:Debug("Couldn't decompress data!")
      return false
    end

    local okay, data = SER:Deserialize(dataSerialized)
    if (not okay) then
      GMSG:Debug("Couldn't deserialize data!")
      return false
    end

    return data
  end
end

-- Function: Import()
-- Desc:     Imports a message given a code.
-- Param:    data - decoded data table for a message object
function GMSG:Import(data)
  if not data then return end
  GMSG:CreateMsg(data)
end

-- Function: Delete()
-- Desc:     Deletes selected message.
-- Param:    msg - Title of the message to be deleted (index).
function GMSG:Delete(msg)
  for k, _ in pairs(self.db.profile.messages) do
    if k == msg then
      self.db.profile.messages[k] = nil
      GMSG:Debug("Message deleted!")
    end
  end
end

-- Function: InitGuildInfo()
-- Desc:     Grabs guild recruitment information for use with tags.
function GMSG:InitGuildInfo()
  local club_id = C_Club.GetGuildClubId()
  local club = ClubFinderGetCurrentClubListingInfo(club_id)
  if not club then
    club = ClubFinderGetCurrentClubListingInfo(club_id)
  else
    self.db.profile.guildinfo = club
  end
end

-- Function: GetGuildLink()
-- Desc:     Grabs the guild recruitment link from info stored in self.db.profile.guildinfo.
-- Return:   link - text-based link object representing guild recruitment link
function GMSG:GetGuildLink()
  if not self.db.profile.guildinfo then GMSG:InitGuildInfo() end
  local guild = self.db.profile.guildinfo
  local link = GetClubFinderLink(guild.clubFinderGUID, guild.name)

  return link
end

-- Function: Edit()
-- Desc:     Edits a message.
-- Param:    previousTitle - title (index) of the message pre-edit.
--           data          - message data
function GMSG:Edit(previousTitle, data)
  local message = data
  local title = data.messageTitle
  local body = data.messageBody
  local mtype = data.messageType

  GMSG:Delete(previousTitle)
  GMSG:CreateMsg(message)
end
