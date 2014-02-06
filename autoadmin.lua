PLUGIN.Title = "Auto Admin"
PLUGIN.Description = "Auto Login Admins"

local godmode = true
local permaDay = true

function PLUGIN:Init()
	self.DataFile = util.GetDatafile( "admins" )
	local txt = self.DataFile:GetText()
	if (txt ~= "") then
		self.Data = json.decode( txt )
	else
		self.Data = {}
	end
    
	self:AddChatCommand("promote", self.cmdPromote)
    self:AddChatCommand("demote", self.cmdDemote) 
end

function PLUGIN:cmdDemote( netuser, cmd, args )
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
    
    local data = self:GetUserData( targetuser )
    self.Data[data.ID].isAdmin = false
    targetuser:SetAdmin(false)
    self:Save()
    rust.Notice( targetuser, "You have been demoted!" )
    rust.SendChatToUser( netuser, "You have demoted " .. util.QuoteSafe(targetuser.displayName) )
end

function PLUGIN:cmdPromote( netuser, cmd, args )
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
    
    local data = self:GetUserData( targetuser )
    self.Data[data.ID].isAdmin = true
    targetuser:SetAdmin(true)
    self:Save()
    rust.Notice( targetuser, "You have been promoted!" )
    rust.SendChatToUser( netuser, "You have promoted " .. util.QuoteSafe(targetuser.displayName) )
end

function PLUGIN:OnUserConnect( netuser )
    local data = self:GetUserData( netuser )
    if (data.isAdmin) then
        netuser:SetAdmin(true)
        rust.Notice( netuser, "You are admin!" )
        -- if (godmode) then
            -- rust.RunServerCommand("dmg.godmode true")
        -- end
        -- if (permaDay) then
            -- rust.RunServerCommand("env.timescale 0" )
            -- rust.RunServerCommand("env.time 12" )
        -- end
    end
end


function PLUGIN:Save()
	self.DataFile:SetText( json.encode( self.Data ) )
	self.DataFile:Save()
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
        userentry.isAdmin = false
		self.Data[ userID ] = userentry
        self:Save()
	end
	return userentry
end