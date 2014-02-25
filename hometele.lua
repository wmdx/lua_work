PLUGIN.Title = "Home Plugin"
PLUGIN.Description = "Set a Home"
-- By Az0r

function PLUGIN:Init()
    self.SavedCoordsFile = util.GetDatafile("home")
    local json_txt = json.decode(self.SavedCoordsFile:GetText())
    if not json_txt then
        json_txt = {}
    end
    self.SavedCoords = json_txt

    flags_plugin = plugins.Find("flags")
    if (not flags_plugin) then
        print("You do not have the Flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155")
        print("Loaded Simple Home without Flags support.")
    end

    if (flags_plugin) then
        flags_plugin:AddFlagsChatCommand(self, "sethome", {"home"}, self.Sethome)
        flags_plugin:AddFlagsChatCommand(self, "home", {"home"}, self.Home)
        flags_plugin:AddFlagsChatCommand(self, "hometime", {"hometime"}, self.Hometime)
    else
        self:AddChatCommand("sethome", self.Sethome)
        self:AddChatCommand("home", self.Home)
        self:AddChatCommand("hometime", self.Hometime)
    end

    hometimer = 5
end
function PLUGIN:SaveCoordsFile()
    self.SavedCoordsFile:SetText(json.encode(self.SavedCoords))
    self.SavedCoordsFile:Save()
end
function PLUGIN:hasAdmin(netuser)
    return flags_plugin or netuser:CanAdmin()
end
function PLUGIN:Sethome( netuser, cmd, args )
    local netuserID = rust.GetUserID( netuser )
    local coords = {}
    local current_coords = netuser.playerClient.lastKnownPosition
    coords.x = current_coords.x
    coords.y = current_coords.y
    coords.z = current_coords.z
    self.SavedCoords[netuserID] = coords
    self:SaveCoordsFile()
    rust.Notice(netuser,"Home set!")
end
    
function PLUGIN:Home( netuser, cmd, args )
    local netuserID = rust.GetUserID( netuser )
    if(self.SavedCoords[netuserID]) then

        local coords = netuser.playerClient.lastKnownPosition;
        coords.x = self.SavedCoords[netuserID].x
        coords.y = self.SavedCoords[netuserID].y + 3
        coords.z = self.SavedCoords[netuserID].z
        rust.Notice( netuser, "Teleporting to your home a few seconds - please wait.")
        timer.Once( hometimer, function()
            rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords);
			rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords);
            rust.Notice(netuser,"You have been teleported to your home!")
        	end)
    	else
        rust.Notice(netuser,"You have not set your home yet. Use /sethome to set it!")
	end
end
    function PLUGIN:Hometime( netuser, cmd, args )
    	if (not args[1]) then
		rust.Notice( netuser, "Syntax: /hometime" )
		return
	end
    if self:hasAdmin(netuser) then
    hometimer = tonumber(args[1])
    else
    	rust.Notice( netuser, "You have to be logged in as Amdin" )
    end
  
end
