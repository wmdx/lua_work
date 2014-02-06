
PLUGIN.Title = "motd"
PLUGIN.Description = "MOTD message when someone joins the server."

print(PLUGIN.Title .. " plugin loaded")
print("-----------------------")

local FLAG_motd;

function PLUGIN:Init()
	self.motdDataFile = util.GetDatafile( "motd" )
	local txt = self.motdDataFile:GetText()
	if (txt ~= "") then
		self.motd = json.decode( txt )
	else
		self.motd =
		{
			["PrivateChat"] = 
			{
				"Welcome |USERNAME|!",
				"Hope you like it here!"
			},
			["Notice"] =
			{
				"Welcome |USERNAME|!"
			},
			["AllChat"] =
			{
				"|USERNAME| (|STEAMID| / |STEAMID64|) connected."
			}
		};
		-- We run the save to create the save files.
		self:Save();
	end
	
	self:DoPermission();
end

function PLUGIN:DoPermission()
	oxmin_Plugin = plugins.Find( "oxmin" )
	if not oxmin_Plugin or not oxmin
	then
		print("To use the /motd command to reload the addon you need to have oxmin installed also.")
		return;
	end;
	
	FLAG_motd = oxmin.AddFlag( "motd" )
	oxmin_Plugin:AddOxminChatCommand( "motd", { FLAG_motd }, function() cs.reloadplugin("motd") end )
end;

function PLUGIN:Save()
	self.motdDataFile:SetText( json.encode( self.motd ) )
	self.motdDataFile:Save()
end

function PLUGIN:OnUserConnect( netUser )
	for msgType,arr in pairs(self.motd)
	do
		for k,v in pairs(arr)
		do
			local msg = v;
			
			
			local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netUser ) ) )
			msg = msg:gsub("|STEAMID|", self:FixSteamID(sid))
			
			msg = msg:gsub("|STEAMID64|", self:ToSteam64(sid))
			
			
			
			
			-- Username done last so they can't have tags in their names.
			msg = msg:gsub("|USERNAME|", util.QuoteSafe(netUser.displayName));
			
			-- RunClientCommand doesn't do anything here, might be to early to call it in OnUserConnect.
			--rust.RunClientCommand(netUser, "chat.add \"" .. util.QuoteSafe( v ) .. "\"")
			
			msg = util.QuoteSafe( msg );
			
			--print("MSG: " .. msg)
			
			if msgType == "PrivateChat"
			then
				rust.SendChatToUser(netUser, msg)
			elseif msgType == "Notice"
			then
				rust.Notice( netUser, msg)
			elseif msgType == "AllChat"
			then
				rust.BroadcastChat(msg)
			end;
		end
	end;
end;

function PLUGIN:ToSteam64(steamID)
	-- Steam_X:A:B
	local A,B
	local id = self:split(steamID, ":")
	
	if tonumber(id[2]) > tonumber(id[3])
	then
		A = id[3]
		B = id[2]
	else
		A = id[2]
		B = id[3]
	end;
	
	
	id = (((B * 2) + A) + 1197960265728)
	id = "7656" .. id
	return id
end;

function PLUGIN:FixSteamID(steamID)
	if steamID == nil
	then
		return "";
	end;
	-- Steam_X:A:B
	local A,B
	local id = self:split(steamID, ":")
	
	if tonumber(id[2]) > tonumber(id[3])
	then
		A = id[3]
		B = id[2]
	else
		A = id[2]
		B = id[3]
	end;
	
	return "STEAM_0:" .. A .. ":" .. B
end;

function PLUGIN:split(str, inSplitPattern, outResults )
   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( str, theStart ) )
   return outResults
end