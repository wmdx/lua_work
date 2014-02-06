PLUGIN.Title = "FixYourName"
PLUGIN.Description = "Disables Weird Characters in Usernames, preventing them from preventing bans."
PLUGIN.Author = "XoXFaby"
 
function PLUGIN:Init()
	self.Characters = "abcdefghijklmnopqrstuvwxyz1234567890 [](){}!@#$%^&*_-=+.|"
	self.ReportToChat = true
	self.AllowColorCodes = false
	self.AllowDuplicateNames = false
	self.AllowBannedCharacters = false -- Why would you enable this? IDK. But now you can.
	
	  
	oxminPlugin = cs.findplugin("oxmin")
	FLAG_CANTAKENAME = oxmin.AddFlag("cantakename")
end
 
function isNumCode( num )
	if tonumber(num) ~= nil or num:lower() == "a" or num:lower() == "b" or num:lower() == "c" or num:lower() == "d" or num:lower() == "e" or num:lower() == "f" or num:lower() == "-" then
		return true
	else
		return false
	end
end

function PLUGIN:OnUserConnect( netuser )
	
	local name = netuser.displayName
	local nameChar = false
	local nameColor = false
	local nameDuplicate = false
	local duplicateUser = ""
	
	
	if not self.AllowBannedCharacters then
		for i = 1, name:len() do
			local allowedChar = false
			for j = 1, self.Characters:len() do
				if name:sub(i,i):lower() == self.Characters:sub(j,j) then
					allowedChar = true
				end
			end
			if allowedChar == false then
				nameChar = true
				break
			end
		end
	end
		
	if not self.AllowColorCodes then
		for i = 1, name:len() - 8 do
			if name:sub(i,i) == "[" and name:sub(i+1, i+1) and name:sub(i+2, i+2) and name:sub(i+3, i+3) and name:sub(i+4, i+4) and name:sub(i+5, i+5) and name:sub(i+6, i+6) and name:sub(i+7,i+7) == "]" then
				nameColor = true
			end
		end
	end
		
	if not self.AllowDuplicateNames then
		for k,v in ipairs(rust.GetAllNetUsers()) do
			if netuser.displayName == v.displayName and netuser ~= v then nameDuplicate = true; duplicateUser = v end
		end
	end
	
	if nameColor then
		rust.Notice( netuser, "Kicked: Color code")
		if self.ReportToChat then rust.BroadcastChat( name .. " has been kicked ( Color code ) " ) end
		netuser:Kick( NetError.Facepunch_Kick_RCON, true )
	elseif nameDuplicate then
		if oxminPlugin:HasFlag( netuser, FLAG_CANTAKENAME ) or oxminPlugin:HasFlag( netuser, oxmin.strtoflag["cankick"] ) or oxminPlugin:HasFlag( netuser, oxmin.strtoflag["canban"] ) then
			rust.Notice( duplicateUser, "Kicked: Name has been claimed" )
			if self.ReportToChat then rust.BroadcastChat( duplicateUser.displayName .. " has been kicked ( Name has been claimed ) " ) end
			duplicateUser:Kick( NetError.Facepunch_Kick_RCON, true )
		else
			rust.Notice( netuser, "Kicked: Name already in use" )
			if self.ReportToChat then rust.BroadcastChat( name .. " has been kicked ( Name already in use ) " ) end
			netuser:Kick( NetError.Facepunch_Kick_RCON, true )
		end
	elseif nameChar then
		rust.Notice( netuser, "Kicked: Name contains illegal character" )
		if self.ReportToChat then rust.BroadcastChat( name .. " has been kicked ( Name contains illegal character ) " ) end
		netuser:Kick( NetError.Facepunch_Kick_RCON, true )
	end
end
