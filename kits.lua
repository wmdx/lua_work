--[[ *************** ]]--
--[[ kits - thomasfn ]]--
--[[ *************** ]]--


-- Define plugin variables
PLUGIN.Title = "Kits"
PLUGIN.Description = "Provides customisable starter kits"

-- *******************************************
-- PLUGIN:Init()
-- Called when the plugin is initialised
-- *******************************************
function PLUGIN:Init()
	-- Load player data
	self.PlayerData = util.GetDatafile( "kits_players" )
	if (self.PlayerData:GetText() == "") then
		self.PData = {}
	else
		self.PData = json.decode( self.PlayerData:GetText() )
		if (not self.PData) then
			error( "json decode error in kits_players.txt" )
			self.PData = {}
		end
	end
	
	-- Add commands
	self:AddChatCommand( "kit", self.cmdKit )
	self:AddCommand( "kits", "reload", self.ccmdReload )
end

-- *******************************************
-- PLUGIN:OnDatablocksLoaded()
-- Called when the datablocks are ready to be read
-- *******************************************
function PLUGIN:OnDatablocksLoaded()
	-- Load all kits
	self:LoadKits()
end

-- *******************************************
-- PLUGIN:OnDatablocksLoaded()
-- Loads all kits
-- *******************************************
function PLUGIN:LoadKits()
	-- Load the config file
	local b, res = config.Read( "kits" )
	self.Kits = res or {}
	if (not b and res) then config.Save( "kits" ) end
	
	-- Loop each kit
	local cnt = 0
	for name, kit in pairs( self.Kits ) do
		cnt = cnt + 1
		kit.datablocks = {}
		if (not kit.items) then
			kit.items = {}
			error( "WARNING: Kit " .. name .. " is missing items!" )
		else
			for _, v in pairs( kit.items ) do
				local itemname = v
				local quantity = 1
				if (type( v ) == "table") then
					itemname = v.name or ""
					quantity = v.amount or 1
				end
				--print( itemname )
				local datablock = rust.GetDatablockByName( itemname )
				if (not datablock) then
					error( "WARNING: Unknown item " .. itemname .. " in kit " .. name .. "!" )
				else
					kit.datablocks[ #kit.datablocks + 1 ] = { Datablock = datablock, Quantity = quantity }
				end
			end
		end
	end
	print( tostring( cnt ) .. " kits have been loaded." )
end

-- *******************************************
-- PLUGIN:ccmdReload()
-- Called when the command "kits.reload" was executed
-- *******************************************
function PLUGIN:ccmdReload( arg )
	local user = arg.argUser
	if (user and not user:CanAdmin()) then return end
	self:LoadKits()
	arg:ReplyWith( "Kits reloaded." )
	return true
end

-- *******************************************
-- PLUGIN:cmdKit()
-- Called when the chat command "/kit" was executed
-- *******************************************
function PLUGIN:cmdKit( netuser, cmd, args )
	local kitname = args[1]
	if (not kitname) then
		local tmp = {}
		for name, kit in pairs( self.Kits ) do
			tmp[ #tmp + 1 ] = name
		end
		rust.Notice( netuser, "Available kits: " .. table.concat( tmp, ", " ) )
		return
	end
	kitname = kitname:lower()
	if (not self.Kits[ kitname ]) then
		rust.Notice( netuser, "Unknown kit!" )
		return
	end
	local kit = self.Kits[ kitname ]
	local userid = rust.GetUserID( netuser )
	local data = self.PData[ userid ]
	if (kit.max) then
		if (data and data[ kitname ] and data[ kitname ] >= kit.max) then
			rust.Notice( netuser, "You have already redeemed this kit!" )
			return
		end
	end
	self:GiveKit( netuser, kit )
	if (not data) then
		data = {}
		self.PData[ userid ] = data
	end
	data[ kitname ] = (data[ kitname ] or 0) + 1
	self.PlayerData:SetText( json.encode( self.PData ) )
	self.PlayerData:Save()
	if (not kit.message) then
		rust.Notice( netuser, "You have redeemed the kit '" .. kitname .. "'!" )
	else
		rust.Notice( netuser, kit.message )
	end
	print( "'" .. netuser.displayName .. "' has redeemed the kit '" .. kitname .. "'" )
end

-- *******************************************
-- PLUGIN:GiveKit()
-- Gives the specified user the specified kit
-- *******************************************
function PLUGIN:GiveKit( netuser, kit )
	local pref = rust.InventorySlotPreference( InventorySlotKind.Default, false, InventorySlotKindFlags.Belt )
	local inv = netuser.playerClient.rootControllable.idMain:GetComponent( "Inventory" )
	for i=1, #kit.datablocks do
		local item = kit.datablocks[i]
		--print( item.Datablock )
		--print( item.Quantity )
		inv:AddItemAmount( item.Datablock, item.Quantity, pref )
	end
end

-- *******************************************
-- PLUGIN:SendHelpText()
-- Called when it's time to send help text to the user
-- *******************************************
function PLUGIN:SendHelpText( netuser )
	local cnt = 0
	for _, _ in pairs( self.Kits ) do cnt = cnt + 1 end
	if (cnt > 0) then
		rust.SendChatToUser( netuser, "There are " .. cnt .. " kits available via /kit." )
	end
end