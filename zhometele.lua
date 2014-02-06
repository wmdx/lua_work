PLUGIN.Title = "Home Plugin"
PLUGIN.Description = "Set a Home"
-- By Az0r
print(PLUGIN.Title .. " plugin loaded")
print("-----------------------")


function PLUGIN:Init()
    self.SavedCoordsFile = util.GetDatafile("home")
    local json_txt = json.decode(self.SavedCoordsFile:GetText())
    if not json_txt then
        json_txt = {}
    end
    self.SavedCoords = json_txt

    self:AddChatCommand("sethome", self.Sethome)
    self:AddChatCommand("home", self.Home)
    self:AddChatCommand("hometime", self.Hometime)
    hometimer = 60
	
	oxmin_Plugin = plugins.Find("oxmin")
    if not oxmin_Plugin or not oxmin then
        print("ERROR: Prefix Flags Not Added! Requires Oxmin")
        self.oxminInstalled = false
        return;
    end;
	
	self.FLAG_VIP = oxmin.strtoflag[ "Vip" ]
    self.oxminInstalled = true
	print("Flag canDonate successfully added to Oxmin")
end


function PLUGIN:SaveCoordsFile()
    self.SavedCoordsFile:SetText(json.encode(self.SavedCoords))
    self.SavedCoordsFile:Save()
end
function PLUGIN:Sethome( netuser, cmd, args )
	if (not oxmin_Plugin:HasFlag( netuser, self.FLAG_VIP, true)) then 
        rust.Notice(netuser, "Donator Feature")
        return
    end
    local netuserID = rust.GetUserID( netuser )
    local coords = {}
    local current_coords = netuser.playerClient.lastKnownPosition
	local check = self.SavedCoords[netuserID]
	if (not check) then
		coords.x = current_coords.x
		coords.y = current_coords.y
		coords.z = current_coords.z
		self.SavedCoords[netuserID] = coords
		self:SaveCoordsFile()
		rust.Notice(netuser,"Home set!")
	else
		rust.SendChatToUser( netuser, "You've already set your home coords. You can only do this once. Contact admin")
		return
	end

end
    
function PLUGIN:Home( netuser, cmd, args )
	if (not oxmin_Plugin:HasFlag( netuser, self.FLAG_VIP, true)) then  
        rust.Notice(netuser, "Donator Feature")
        return
    end
    local netuserID = rust.GetUserID( netuser )
    if(self.SavedCoords[netuserID]) then

        local coords = netuser.playerClient.lastKnownPosition;
        coords.x = self.SavedCoords[netuserID].x
        coords.y = self.SavedCoords[netuserID].y + 5
        coords.z = self.SavedCoords[netuserID].z
        rust.Notice( netuser, "Teleporting to your home in 60 seconds.")
        timer.Once( hometimer, function()
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
    if netuser:CanAdmin() then
    hometimer = tonumber(args[1])
    else
    	rust.Notice( netuser, "You have to be logged in as Amdin" )
    end
  
end
