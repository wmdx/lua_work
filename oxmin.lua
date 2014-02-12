--[[ **************** ]]--
--[[ oxmin - thomasfn ]]--
--[[ **************** ]]--


-- Define plugin variables
PLUGIN.Title = "Oxmin"
PLUGIN.Description = "Administration mod"

-- Load oxmin module
if (not oxmin) then
	oxmin = {}
	oxmin.flagtostr = {}
	oxmin.strtoflag = {}
	oxmin.nextflagid = 1
end
function oxmin.AddFlag( name )
	if (oxmin.strtoflag[ name ]) then return oxmin.strtoflag[ name ] end
	local id = oxmin.nextflagid
	oxmin.flagtostr[ id ] = name
	oxmin.strtoflag[ name ] = id
	oxmin.nextflagid = oxmin.nextflagid + 1
	return id
end

-- Add all default flags
local FLAG_ALL = oxmin.AddFlag( "all" )
local FLAG_BANNED = oxmin.AddFlag( "banned" )
local FLAG_CANKICK = oxmin.AddFlag( "cankick" )
local FLAG_CANBAN = oxmin.AddFlag( "canban" )
local FLAG_CANUNBAN = oxmin.AddFlag( "canunban" )
local FLAG_CANTELEPORT = oxmin.AddFlag( "canteleport" )
local FLAG_CANGIVE = oxmin.AddFlag( "cangive" )
local FLAG_CANGOD = oxmin.AddFlag( "cangod" )
local FLAG_GODMODE = oxmin.AddFlag( "godmode" )
local FLAG_CANLUA = oxmin.AddFlag( "canlua" )
local FLAG_CANCALLAIRDROP = oxmin.AddFlag( "cancallairdrop" )
local FLAG_RESERVED = oxmin.AddFlag( "reserved" )
local FLAG_CANDESTROY = oxmin.AddFlag( "candestroy" )

-- *******************************************
-- PLUGIN:Init()
-- Initialises the Oxmin plugin
-- *******************************************
function PLUGIN:Init()
	-- Notify console that oxmin is loading
	print( "Loading Oxmin..." )
	
	-- Load the user datafile
	self.DataFile = util.GetDatafile( "oxmin" )
	local txt = self.DataFile:GetText()
	if (txt ~= "") then
		self.Data = json.decode( txt )
	else
		self.Data = {}
		self.Data.Users = {}
	end
	
	-- Count and output the number of users
	local cnt = 0
	for _, _ in pairs( self.Data.Users ) do cnt = cnt + 1 end
	print( tostring( cnt ) .. " users are tracked by Oxmin!" )
	
	-- Load the config file
	local b, res = config.Read( "oxmin" )
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save( "oxmin" ) end
	end
	
	
	-- Add console commands
	self:AddCommand( "oxmin", "giveflag", self.ccmdGiveFlag )
	self:AddCommand( "oxmin", "takeflag", self.ccmdTakeFlag )
end

-- *******************************************
-- PLUGIN:LoadDefaultConfig()
-- Loads the default configuration into the config table
-- *******************************************
function PLUGIN:LoadDefaultConfig()
	-- Set default configuration settings
	self.Config.chatname = "Oxmin"
	self.Config.reservedslots = 5
	self.Config.showwelcomenotice = true
	self.Config.welcomenotice = "Welcome to the server %s! Type /help for a list of commands."
	self.Config.showconnectedmessage = true
	self.Config.showdisconnectedmessage = true
	self.Config.helptext =
	{
		"Welcome to the server!",
		"This server is powered by the Oxide Modding API for Rust.",
		"Use /who to see how many players are online."
	}
end

-- *******************************************
-- PLUGIN:AddOxminChatCommand()
-- Adds an internal chat command with flag requirements
-- *******************************************
function PLUGIN:AddOxminChatCommand( name, flagsrequired, callback )
	-- Add external chat command to ourself
	self:AddExternalOxminChatCommand( self, name, flagsrequired, callback )
end

-- *******************************************
-- PLUGIN:AddExternalOxminChatCommand()
-- Adds an external chat command with flag requirements
-- *******************************************
function PLUGIN:AddExternalOxminChatCommand( plugin, name, flagsrequired, callback )
	-- Get a reference to the oxmin plugin
	local oxminplugin = plugins.Find( "oxmin" )
	if (not oxminplugin) then
		error( "Oxmin plugin file was renamed (don't do this)!" )
		return
	end
	
	-- Define a "proxy" callback that checks for flags
	local function FixedCallback( self, netuser, cmd, args )
		for i=1, #flagsrequired do
			if (not oxminplugin:HasFlag( netuser, flagsrequired[i] )) then
				rust.Notice( netuser, "You don't have permission to use this command!" )
				return true
			end
		end
		print( "'" .. netuser.displayName .. "' (" .. rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) ) .. ") ran command '/" .. cmd .. " " .. table.concat( args, " " ) .. "'" )
		callback( self, netuser, args )
	end
	
	-- Add the chat command
	plugin:AddChatCommand( name, FixedCallback )
end

-- *******************************************
-- PLUGIN:ccmdGiveFlag()
-- Console command callback (oxmin.giveflag <user> <flag>)
-- *******************************************
function PLUGIN:ccmdGiveFlag( arg )
	-- Check the caller has admin or rcon
	local user = arg.argUser
	if (user and not user:CanAdmin()) then return end
	
	-- Locate the target user
	local b, targetuser = rust.FindNetUsersByName( arg:GetString( 0 ) )
	if (not b) then
		if (targetuser == 0) then
			arg:ReplyWith( "No players found with that name!" )
		else
			arg:ReplyWith( "Multiple players found with that name!" )
		end
		return
	end
	
	-- Locate the flag
	local flagid = oxmin.strtoflag[ arg:GetString( 1 ) ]
	if (not flagid) then
		arg:ReplyWith( "Unknown flag!" )
		return
	end
	
	-- Give the flag
	local targetname = util.QuoteSafe( targetuser.displayName )
	self:GiveFlag( targetuser, flagid )
	arg:ReplyWith( "Flag given to " .. targetname .. "." )
	
	-- Handled
	return true
end

-- *******************************************
-- PLUGIN:ccmdTakeFlag()
-- Console command callback (oxmin.takeflag <user> <flag>)
-- *******************************************
function PLUGIN:ccmdTakeFlag( arg )
	-- Check the caller has admin or rcon
	local user = arg.argUser
	if (user and not user:CanAdmin()) then return end
	
	-- Locate the target user
	local b, targetuser = rust.FindNetUsersByName( arg:GetString( 0 ) )
	if (not b) then
		if (targetuser == 0) then
			arg:ReplyWith( "No players found with that name!" )
		else
			arg:ReplyWith( "Multiple players found with that name!" )
		end
		return
	end
	
	-- Locate the flag
	local flagid = oxmin.strtoflag[ arg:GetString( 1 ) ]
	if (not flagid) then
		arg:ReplyWith( "Unknown flag!" )
		return
	end
	
	-- Take the flag
	local targetname = util.QuoteSafe( targetuser.displayName )
	self:TakeFlag( targetuser, flagid )
	arg:ReplyWith( "Flag taken from " .. targetname .. "." )
	
	-- Handled
	return true
end

-- *******************************************
-- PLUGIN:Save()
-- Saves the player data to file
-- *******************************************
function PLUGIN:Save()
	self.DataFile:SetText( json.encode( self.Data ) )
	self.DataFile:Save()
end

-- *******************************************
-- PLUGIN:BroadcastChat()
-- Broadcasts a chat message
-- *******************************************
function PLUGIN:BroadcastChat( msg )
	rust.BroadcastChat( self.Config.chatname, msg )
end

-- *******************************************
-- PLUGIN:CanClientLogin()
-- Saves the player data to file
-- *******************************************
local SteamIDField = util.GetFieldGetter( RustFirstPass.SteamLogin, "SteamID", true )
--local PlayerClientAll = util.GetStaticPropertyGetter( RustFirstPass.PlayerClient, "All" )
--local serverMaxPlayers = util.GetStaticFieldGetter( RustFirstPass.server, "maxplayers" )
function PLUGIN:CanClientLogin( login )
	-- Get the user ID and player data
	local steamlogin = login.SteamLogin
	local userID = tostring( SteamIDField( steamlogin ) )
	local data = self:GetUserDataFromID( userID, steamlogin.UserName )
	
	-- Check if they have the banned flag
	for i=1, #data.Flags do
		local f = data.Flags[i]
		if (f == FLAG_BANNED) then return NetError.ConnectionBanned end
	end
	
	-- Get the maximum number of players
	local maxplayers = RustFirstPass.server.maxplayers
	local curplayers = self:GetUserCount()
	
	-- Are we biting into reserved slots?
	if (curplayers + self.Config.reservedslots >= maxplayers) then
		-- Check if they have reserved flag
		for i=1, #data.Flags do
			local f = data.Flags[i]
			if (f == FLAG_RESERVED or f == FLAG_ALL) then return end
		end
		return NetError.Facepunch_Approval_TooManyConnectedPlayersNow
	end
end

-- *******************************************
-- PLUGIN:GetUserCount()
-- Gets the number of connected users
-- *******************************************
function PLUGIN:GetUserCount()
	return RustFirstPass.PlayerClient.All.Count
end

-- *******************************************
-- PLUGIN:OnUserConnect()
-- Called when a user has connected
-- *******************************************
function PLUGIN:OnUserConnect( netuser )
	local sid = rust.CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
	print( "User \"" .. util.QuoteSafe( netuser.displayName ) .. "\" connected with SteamID '" .. sid .. "'" )
	local data = self:GetUserData( netuser )
	data.Connects = data.Connects + 1
	self:Save()
	if (data.Connects == 1 and self.Config.showwelcomenotice) then
		rust.Notice( netuser, self.Config.welcomenotice:format( netuser.displayName ), 20.0 )
	end
end



-- *******************************************
-- PLUGIN:GetUserData()
-- Gets a persistent table associated with the given user
-- *******************************************
function PLUGIN:GetUserData( netuser )
	local userID = rust.GetUserID( netuser )
	return self:GetUserDataFromID( userID, netuser.displayName )
end

-- *******************************************
-- PLUGIN:GetUserDataFromID()
-- Gets a persistent table associated with the given user ID
-- *******************************************
function PLUGIN:GetUserDataFromID( userID, name )
	local userentry = self.Data.Users[ userID ]
	if (not userentry) then
		userentry = {}
		userentry.Flags = {}
		userentry.ID = userID
		userentry.Name = name
		userentry.Connects = 0
		self.Data.Users[ userID ] = userentry
		self:Save()
	end
	return userentry
end

-- *******************************************
-- PLUGIN:HasFlag()
-- Returns true if the specified user has the specified flag
-- *******************************************
function PLUGIN:HasFlag( netuser, flag, ignoreall )
	local userID = rust.GetUserID( netuser )
	local data = self:GetUserData( netuser )
	for i=1, #data.Flags do
		local f = data.Flags[i]
		if (f == FLAG_ALL and not ignoreall) then return true end
		if (f == flag) then return true end
	end
	return false
end

-- *******************************************
-- PLUGIN:GiveFlag()
-- Gives the specified flag to the specified user
-- *******************************************
function PLUGIN:GiveFlag( netuser, flag )
	local userID = rust.GetUserID( netuser )
	local data = self:GetUserData( netuser )
	for i=1, #data.Flags do
		if (data.Flags[i] == flag) then return false end
	end
	table.insert( data.Flags, flag )
	rust.Notice( netuser, "You now have the flag '" .. oxmin.flagtostr[ flag ] .. "'!" )
	self:Save()
	return true
end

-- *******************************************
-- PLUGIN:TakeFlag()
-- Takes the specified flag from the specified user
-- *******************************************
function PLUGIN:TakeFlag( netuser, flag )
	local userID = rust.GetUserID( netuser )
	local data = self:GetUserData( netuser )
	for i=1, #data.Flags do
		if (data.Flags[i] == flag) then
			table.remove( data.Flags, i )
			rust.Notice( netuser, "You no longer have the flag '" .. oxmin.flagtostr[ flag ] .. "'!" )
			self:Save()
			return true
		end
	end
	return false
end

-- *******************************************
-- PLUGIN:OnTakeDamage()
-- Called when an entity take damage
-- *******************************************
function PLUGIN:ModifyDamage( takedamage, damage )
	local obj = takedamage.gameObject
	local controllable = takedamage:GetComponent( "Controllable" )
	if (not controllable) then return end
	--print( controllable )
	local netuser = controllable.playerClient.netUser
	if (not netuser) then return error( "Failed to get net user (ModifyDamage)" ) end
	local char = rust.GetCharacter( netuser )
	if (not char) then return error( "Failed to get Character (ModifyDamage)" ) end
	--local char = obj:GetComponent( "Character" )
	if (char) then
		local ct = char:GetType()
		--[[if (ct.Name == "DamageBeing") then
			char = char.character
			print( "Hacky fix, " .. ct.Name .. " is now " .. char:GetType().Name )
			if (char:GetType().Name == "DamageBeing") then
				print( "The hacky fix didn't work, it's still a DamageBeing!" )
				return
			end
		end]]
		--print( ct )
		local netplayer = char.networkViewOwner
		if (netplayer) then
			local netuser = rust.NetUserFromNetPlayer( netplayer )
			if (netuser) then
				if (self:HasFlag( netuser, FLAG_GODMODE, true )) then
					--print( "Damage denied" )
					damage.amount = 0
					return damage
				end
			end
		end
	end
end