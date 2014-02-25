--[[ ******************** ]]--
--[[ doorshare - thomasfn ]]--
--[[ ******************** ]]--


-- Define plugin variables
PLUGIN.Title = "Door Share"
PLUGIN.Description = "Allows players to share their doors with other players"

-- *******************************************
-- PLUGIN:Init()
-- Initialises the plugin
-- *******************************************
function PLUGIN:Init()
	-- Read the datafile
	self.DoorShareDataFile = util.GetDatafile( "doorshare" )
	local txt = self.DoorShareDataFile:GetText()
	if (txt ~= "") then
		self.DoorShareData = json.decode( txt )
	else
		self.DoorShareData = {}
	end
	
	-- Add chat commands
	self:AddChatCommand( "share", self.cmdShare )
	self:AddChatCommand( "unshare", self.cmdUnshare )
end

-- *******************************************
-- PLUGIN:CanOpenDoor()
-- Called when a user tries to open or close a door
-- *******************************************
local DeployableObjectOwnerID = util.GetFieldGetter( Rust.DeployableObject, "ownerID", true )
function PLUGIN:CanOpenDoor( netuser, door )
	-- Get and validate the deployable
	local deployable = door:GetComponent( "DeployableObject" )
	if (not deployable) then return end
	
	-- Get the owner ID and the user ID
	local ownerID = tostring( DeployableObjectOwnerID( deployable ) )
	local userID = rust.GetUserID( netuser )
	
	-- Is it the owner? Then yes!
	if (ownerID == userID) then return true end
	
	-- Check if the door is NOT shared
	local sharedata = self.DoorShareData[ ownerID ]
	if (not sharedata) then return end
	if (not sharedata.Allowed) then return end
	if (not sharedata.Allowed[ userID ]) then return end
	
	-- It is!
	return true
end

-- *******************************************
-- PLUGIN:cmdShare()
-- Called when a user runs the /share chat command
-- *******************************************
function PLUGIN:cmdShare( netuser, cmd, args )
	-- Check name is valid
	if (not args[1]) then
		rust.Notice( netuser, "Syntax: /share name" )
		return
	end
	
	-- Get the target user
	local b, targetuser = rust.FindNetUsersByName( args[1] )
	if (not b) then
		if (targetuser == 0) then
			rust.Notice( netuser, "No players found with that name!" )
		else
			rust.Notice( netuser, "Multiple players found with that name!" )
		end
		return
	end
	
	-- Get the user IDs
	local userID = rust.GetUserID( netuser )
	local targetID = rust.GetUserID( targetuser )
	
	-- Add to allowed list
	local sharedata = self.DoorShareData[ userID ] or {}
	local allowed = sharedata.Allowed or {}
	if (allowed[ targetID ]) then
		rust.Notice( netuser, "You have already shared doors with that player!" )
		return
	end
	allowed[ targetID ] = targetuser.displayName
	sharedata.Allowed = allowed
	self.DoorShareData[ userID  ] = sharedata
	
	-- Save and notify
	self:Save()
	rust.Notice( netuser, "All doors shared with " .. util.QuoteSafe( targetuser.displayName ) )
end

-- *******************************************
-- PLUGIN:cmdUnshare()
-- Called when a user runs the /unshare chat command
-- *******************************************
function PLUGIN:cmdUnshare( netuser, cmd, args )
	-- Check name is valid
	if (not args[1]) then
		rust.Notice( netuser, "Syntax: /unshare name" )
		return
	end
	
	-- Get the share data
	local userID = rust.GetUserID( netuser )
	local sharedata = self.DoorShareData[ userID ] or {}
	local allowed = sharedata.Allowed or {}
	
	-- Search through all shared users for the name
	local found = false
	for id, name in pairs( allowed ) do
		if (name == args[1]) then
			allowed[ id ] = nil
			found = true
			rust.Notice( netuser, "All doors unshared with " .. util.QuoteSafe( name ) )
			break
		end
	end
	
	-- If not previously found, search connected players
	if (not found) then
		local b, targetuser = rust.FindNetUsersByName( args[1] )
		if (not b) then
			if (targetuser == 0) then
				rust.Notice( netuser, "No players found with that name!" )
			else
				rust.Notice( netuser, "Multiple players found with that name!" )
			end
			return
		end
		allowed[ rust.GetUserID( targetuser ) ] = nil
		rust.Notice( netuser, "All doors unshared with " .. util.QuoteSafe( targetuser.displayName ) )
	end
	sharedata.Allowed = allowed
	
	-- Save
	self.DoorShareData[ userID ] = sharedata
	self:Save()
end

-- *******************************************
-- PLUGIN:Save()
-- Saves plugin data to file
-- *******************************************
function PLUGIN:Save()
	self.DoorShareDataFile:SetText( json.encode( self.DoorShareData ) )
	self.DoorShareDataFile:Save()
end

-- *******************************************
-- PLUGIN:SendHelpText()
-- Called by Oxmin when it's time to send help text to the user
-- *******************************************
