
PLUGIN.Title = "Groups"
PLUGIN.Description = "Allows players to join groups. Use Groupchat and other functions"

function PLUGIN:Init()
	self.GroupDataFile = util.GetDatafile( "groups" )
	self.GroupsInviteFile = util.GetDatafile( "groupsinvites" )
	local txt = self.GroupDataFile:GetText()
	if (txt ~= "") then
		self.GroupData = json.decode( txt )
	else
		self.GroupData = {}
	end
	local grptmp = self.GroupsInviteFile:GetText()
	if (grptmp ~= "") then
		self.GroupsInvite = json.decode( grptmp )
	else
		self.GroupsInvite = {}
	end
	self:AddChatCommand( "gcreate", self.groupCreate )
	self:AddChatCommand( "gdelete", self.groupDelete )
	self:AddChatCommand( "ginvite", self.groupInvite )
	self:AddChatCommand( "gcancel", self.groupCancel )
	self:AddChatCommand( "gaccept", self.groupAccept )
	self:AddChatCommand( "gleave", self.groupLeave )
	self:AddChatCommand( "g", self.groupChat )
	self:AddChatCommand( "gwho", self.groupWho )
	self:AddChatCommand( "ghelp", self.groupHelp )
	self:AddChatCommand( "ginfo", self.groupInfo )
	self:AddChatCommand( "glist", self.groupList )
end
function PLUGIN:groupHelp( netuser, cmd )
	rust.SendChatToUser( netuser, "Use /gcreate and /gdelete to create/delete groups." )
	rust.SendChatToUser( netuser, "Use /ginvite to invite a user to your group." )
	rust.SendChatToUser( netuser, "Use /gcancel and /gaccept to accept/cancel(Sender and Receiver can do it) the invitation." )
	rust.SendChatToUser( netuser, "Use /gleave to leave your group." )
	rust.SendChatToUser( netuser, "Use /g Message to send group messages." )
	rust.SendChatToUser( netuser, "Use /gwho to see which group members are online." )
	return
end
function PLUGIN:groupList( netuser, cmd )
	rust.SendChatToUser(netuser, "Groups: ")
	local groups = ""
	local counter = 0
	local grpdata = self.GroupData
	local grpcount = self:countGroups()
	for key,value in pairs(self.GroupData) do
		groups = groups .. self.GroupData[key]["name"] .. ", "
		counter = counter + 1
		if (grpcount > 10 and counter == 10) then
        	local grplen = string.len(groups) - 2
        	newgroups = string.sub(groups, 1, grplen)
			rust.SendChatToUser(netuser, newgroups)
			groups = ""
			counter = 0
		elseif (counter == grpcount and grpcount < 10) then
        	local grplen = string.len(groups) - 2
        	newgroups = string.sub(groups, 1, grplen)
			rust.SendChatToUser(netuser, newgroups)		
   	 	end		
	end
	return
end
function PLUGIN:groupInfo( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	local groupkey = self:checkPlayerGroup ( userID ) 
	if (groupkey == 0) then
		rust.Notice( netuser, "You are not in any groups!" )
		return
	else
		local tbl = self.GroupData[groupkey]["members"]
		local groupmembercount = #tbl + 1	
		local groupinfo = "Group: " .. self.GroupData[groupkey]["name"] .. ". Members: " .. groupmembercount .. "."
		rust.SendChatToUser(netuser, groupinfo)
		return
	end
end
function PLUGIN:groupLeave( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	local groupkey = self:checkPlayerGroup( userID )
	if (groupkey == 0) then
		rust.Notice( netuser, "You are not in any groups!" )
	else
		if (self.GroupData[ userID ] ~= nil) then
			rust.Notice( netuser, "You are the group leader! Use /gdelete to delete this group!" )
			return
		end
		local memberkey = self:giveMemberKey( userID )
		if (memberkey ~= 0) then
			self.GroupData[ groupkey ]["members"][memberkey] = nil
			self:Save()
			rust.Notice( netuser, "You have left the group." )
			return
		end
		
	end
	return
end
function PLUGIN:groupWho( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	local groupkey = self:checkPlayerGroup( userID ) 
	if (groupkey == 0) then
		rust.Notice( netuser, "You are not in any groups!" )
	else
		local onlinegroupmembers = "Online group members: "
		local onlineuser = self:getOnlineUsers()
		if (onlineuser[groupkey] ~= nil) then
			onlinegroupmembers = onlinegroupmembers .. onlineuser[groupkey].displayName .. ", "
		end
		for key,value in pairs(self.GroupData[groupkey]["members"]) do
        	if (onlineuser[value] ~= nil) then
        		onlinegroupmembers = onlinegroupmembers .. onlineuser[value].displayName .. ", "       				
    		end
    	end
    	local onlen = string.len(onlinegroupmembers) - 2
    	newonlinegroupmembers = string.sub(onlinegroupmembers, 1, onlen)
    	rust.SendChatToUser(netuser, newonlinegroupmembers)
    end
    return
end
function PLUGIN:groupChat( netuser, cmd, args  )
	if (not args[1]) then
		rust.Notice(netuser, "Syntax: /g Message")
		return
	end
	local userID = rust.GetUserID( netuser )
	local groupkey = self:checkPlayerGroup ( userID ) 
	if (groupkey == 0) then
		rust.Notice( netuser, "You are not in any groups!" )
	else
		local message = tostring(args[1])
		local msgcount = #args
		for i=2, msgcount do
			message = message .. " " .. tostring(args[i])
		end
		local onlineuser = self:getOnlineUsers()		
		if (onlineuser[groupkey] ~= nil) then
			rust.RunClientCommand(onlineuser[groupkey], "chat.add \"" .. util.QuoteSafe( netuser.displayName ) .. " (Group)\" \"" .. util.QuoteSafe( message ) .. "\"" ) 
		end
		for key,value in pairs(self.GroupData[groupkey]["members"]) do						
        	if (onlineuser[value] ~= nil) then
            	rust.RunClientCommand(onlineuser[value], "chat.add \"" .. util.QuoteSafe( netuser.displayName ) .. " (Group)\" \"" .. util.QuoteSafe( message ) .. "\"" ) 			
       	 	end			
		end
	end
	return
end
function PLUGIN:groupCreate( netuser, cmd, args )
	if (not args[1]) then
		rust.Notice(netuser, "Syntax: /gcreate Groupname")
		return
	end
	local userID = rust.GetUserID( netuser )
	if (self.GroupData[ userID ] ~= nil) then
		rust.Notice( netuser, "You have already created a group!" )
		return
	end
	local checkgroupname = self:checkGroupName(args[1])
	if (checkgroupname ~= 0) then
		rust.Notice( netuser, "This name is already in use!" )
		return
	end
	self.GroupData[ userID ] = {}
	self.GroupData[ userID ]["name"] = util.QuoteSafe(args[1])
	self.GroupData[ userID ]["members"] = {}
	self.GroupData[ userID ]["settings"] = {}
	self.GroupData[ userID ]["settings"]["invite"] = 0
	self.GroupData[ userID ]["settings"]["motd"] = 0
	self:Save()
	rust.Notice( netuser, "Group created" )
	return
end
function PLUGIN:groupDelete( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	if (self.GroupData[ userID ] == nil) then
		rust.Notice( netuser, "You dont own a group!" )
		return
	end
	self.GroupData[ userID ] = nil
	self:Save()
	rust.Notice( netuser, "Group deleted" )
	return
end
function PLUGIN:groupInvite( netuser, cmd, args )
	if (not args[1]) then
		rust.Notice( netuser, "Syntax: /ginvite Playername" )
		return
	end
	local userID = rust.GetUserID( netuser ) 
	if (self.GroupData[ userID ] == nil) then
		rust.Notice( netuser, "You dont own a group!" )
		return
	end
	local groupkey = self:checkPlayerGroup ( userID )
	if (self.GroupData[groupkey]["settings"] ~= nil) then
		local settings = self.GroupData[groupkey]["settings"]["invite"]
	else
		local settings = 0
	end
	if (settings ~= 1) then
		if (userID ~= groupkey) then
			rust.Notice( netuser, "You have not the permission to do that!" )
			return
		end
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
	local targetID = rust.GetUserID( targetuser )
	if ( self:checkPlayerGroups( targetID ) == 1 ) then
		rust.Notice( netuser, "This player is already in a group!" )
		return
	end
	if ( self:checkPlayerInvite( targetID ) ~= 0 ) then
		rust.Notice( netuser, "This player has already a invitation for another group!" )
		return
	end	
	rust.Notice( netuser, "Invitation sent to " .. targetuser.displayName )
	rust.Notice( targetuser, netuser.displayName .. " invited you to join the group: " .. self.GroupData[userID]["name"] .. ". Use /gaccept to accept his invitation or /gcancel to decline" )
	self.GroupsInvite[ userID ] = targetID	
	self:Save()
	return
end
function PLUGIN:groupCancel( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	local tmpkey = self:checkPlayerInvite( userID )
	if (self.GroupsInvite[ userID ] ~= nil) then
		self.GroupsInvite[ userID ] = nil
		rust.Notice( netuser, "Invitation cancelled!" )
		self:Save()
		return
	end
	if (tmpkey ~= 0) then
		self.GroupsInvite[ tmpkey ] = nil
		rust.Notice( netuser, "Invitation cancelled!" )
		self:Save()
		return	
	end
	rust.Notice( netuser, "No Invitation found!" ) 
	return
end
function PLUGIN:groupAccept( netuser, cmd )
	local userID = rust.GetUserID( netuser )
	local tmpkey = self:checkPlayerInvite( userID )
	if (tmpkey ~= 0) then
		self.GroupsInvite[tmpkey] = nil
		table.insert(self.GroupData[ tmpkey ]["members"], userID)
		rust.Notice( netuser, "Invitation accepted!" )
		self:Save()
		return	
	end
	rust.Notice( netuser, "No Invitation found!" ) 
	return
end
function PLUGIN:Save()
	self.GroupDataFile:SetText( json.encode( self.GroupData ) )
	self.GroupDataFile:Save()
	self.GroupsInviteFile:SetText( json.encode( self.GroupsInvite ) )
	self.GroupsInviteFile:Save()
end
function PLUGIN:checkPlayerGroups( playerid )
	local playercheck = 0
	for key,value in pairs(self.GroupData) do
	if (key == playerid) then
		playercheck = 1
	end
		if (self.GroupData[key]["members"] ~= nil) then
			for keyd,valued in pairs(self.GroupData[key]["members"]) do
				if (valued == playerid) then
					playercheck = 1
				end
			end
		end
	end
	return playercheck		
end
function PLUGIN:checkPlayerInvite( playerid )
	local playercheck = 0
	for key,value in pairs(self.GroupsInvite) do
		if (value == playerid) then
			playercheck = key
		end
	end
	return playercheck		
end
function PLUGIN:checkPlayerGroup( playerid )
	local playertmp = 0
	for key,value in pairs(self.GroupData) do
		if (key == playerid) then
			playertmp = key
		end
		for keyd,valued in pairs(self.GroupData[key]["members"]) do
			if (valued == playerid) then
				playertmp = key
			end
		end
	end
	return playertmp
end
function PLUGIN:giveMemberKey( playerid )
	local playertmp = 0
	for key,value in pairs(self.GroupData) do
		for keyd,valued in pairs(self.GroupData[key]["members"]) do
			if (valued == playerid) then
				playertmp = keyd
			end
		end
	end
	return playertmp
end
function PLUGIN:checkGroupName( name )
	local group = 0;
	for key,value in pairs(self.GroupData) do
		if (self.GroupData[key]["name"] == name) then
			group = key;
		end
	end
	return group
end
function PLUGIN:getOnlineUsers()
	local onlineusers = {}
	local allnetusers = rust.GetAllNetUsers()
	if (allnetusers) then
		for i=1, #allnetusers do
			local netusertmp = allnetusers[i]
        	local tmpuserid = rust.GetUserID( netusertmp )
        	onlineusers[tmpuserid] = netusertmp
		end
		return onlineusers
	end
	return
end
function PLUGIN:countGroups()
	local groups = self.GroupData
	local counter = 0
	for key,value in pairs(self.GroupData) do
		counter = counter + 1
	end
	return counter
end