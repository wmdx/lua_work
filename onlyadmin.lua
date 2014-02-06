PLUGIN.Title = "onlyadmin"
PLUGIN.Description = "Protects Admin Names"

print(PLUGIN.Title .. " loaded")
print("-------")

function PLUGIN:Init()
	self.DataFile = util.GetDatafile( "onlyadmin" )
	local txt = self.DataFile:GetText()
	if (txt ~= "") then
		self.Data = json.decode( txt )
	else
		self.Data = {}
	end
    
	self:AddChatCommand("protect", self.cmdProtect)
end

function PLUGIN:cmdProtect( netuser, cmd, args )
    if (not(args[1])) then
        return
    end
    if (not(netuser:CanAdmin())) then
        rust.Notice( netuser, "You're not admin!" )
        return
    end
    
    local b, targetuser = rust.FindNetUsersByName( args[1] )
    if (not b) then
        if (targetuser == 0) then
            rust.Notice( netuser, "No players found with that name!" )
        else
            rust.Notice( netuser, "Multiple players found with that name!" )
        end
        return
    end
    local username = netuser.displayName
    local data = self:GetFileName( targetuser , username )
    self.Data[data.ID].isProtect = true
    self:Save()
    rust.Notice( targetuser, "Your name has been protected." )
    rust.SendChatToUser( netuser, "You have protected: " .. util.QuoteSafe(targetuser.displayName) )
end

function PLUGIN:OnUserConnect( netuser )
    local userinfo = self:GetUserData( netuser )
	local username = netuser.displayName
	local namefile = self:GetFileName( netuser, username)
	local userID = rust.GetUserID( netuser)
	
	--rust.SendChatToUser( netuser, "OA:DEBUG: Your ingame ID is:" .. userID )
	--rust.SendChatToUser( netuser, "OA:DEBUG: Your ingame name is:" .. username )
	--rust.SendChatToUser( netuser, "OA:DEBUG: Your FileIDis::" .. namefile.ID )

    if (namefile.isProtect) then
        rust.SendChatToUser( netuser, "Name is protected!" )
		if (not userID == namefile.ID) then 
			rust.SendChatToUser( netuser, "You're using a protected name. Please change your name.")
			netuser:Kick( NetError.Facepunch_Kick_RCON, true )
		end
	else 
		--rust.SendChatToUser( netuser, "OA:DEBUG: Name not protected.")
    end
end


function PLUGIN:Save()
	self.DataFile:SetText( json.encode( self.Data ) )
	self.DataFile:Save()
end

function PLUGIN:GetFileName( netuser, name)
	local filename = self.Data[ name ]
	local userID = rust.GetUserID( netuser )
	if (not filename) then 
		filename = {}
		filename.ID = userID
		filename.Name = name
        filename.isProtect = false
		self.Data[ userID ] = userentry
        self:Save()
	end
	return filename
end

function PLUGIN:GetUserData( netuser )
	local userID = rust.GetUserID( netuser )
	return self:GetUserDataFromID( userID, netuser.displayName )
end

function PLUGIN:GetUserDataFromID( userID, name )
	local userentry = self.Data[ userID ]
	if (not userentry) then
		userentry = {}
		userentry.ID = userID
		userentry.Name = name
        userentry.isProtect = false
		self.Data[ userID ] = userentry
        self:Save()
	end
	return userentry
end
