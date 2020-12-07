local GMSG = GuildMessages

function GMSG:Debug(text)
  GMSG:Print(" |cffff0000[ERROR]|r " .. text)
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
function GMSG:CreateMsg(title, type, body)
  local title = title
  local type = type
  local body = body

   self.db.profile.messages[title] = {
     messageType = type,
     messageBody = body
   }

  GMSG:Print("Message created!")
  GMSG:Print("Title: " .. title)
  GMSG:Print("Body: " .. body)
  GMSG:Print("Type: " .. type)
end

-- function GMSG:populateDropdown(ddbx, type)
--   GMSG:Print(self.db.profile.messages)
--   local count = 0
--   for title, _ in pairs(self.db.profile.messages) do
--     if _["messageType"] == type then
--       ddbx:AddItem(title, title)
--       -- ddbx:SetItemValue(title, _["messageBody"])
--     end
--     count = count + 1
--   end
-- end
