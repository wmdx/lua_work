PLUGIN.Title = "Basics"
PLUGIN.Description = "Provides basic and essential admin funcitonality."
PLUGIN.Author = "eDeloa"
PLUGIN.Version = "1.1.6"

print(PLUGIN.Title .. " (" .. PLUGIN.Version .. ") plugin loaded")

--[[

Command           Required Flag
----------------------------
/kick             kick
/ban              ban
/unban            unban
/tp               teleport
/give             give
/god              godmode
/lua              lua
/airdrop          airdrop
/notice           notice
/save             save

/help             <no flag required>
/loc              <no flag required>

Reserved Slot     reserved
Godmode Enabled   hasgodmode

]]--

-- *******************************************
-- PLUGIN:Init()
-- Initialises the plugin
-- *******************************************
function PLUGIN:Init()
  flags_plugin = plugins.Find("flags")
  if (not flags_plugin) then
    error("You do not have the Flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end

  -- Load the config file
  local b, res = config.Read("basics")
  self.Config = res or {}
  if (not b) then
    self:LoadDefaultConfig()
    if (res) then
      config.Save("basics")
    end
  end

  -- Load the ban file
  self.BanFile = util.GetDatafile("basics_bans")
  local txt = self.BanFile:GetText()
  if (txt ~= "") then
    self.BanData = json.decode(txt)
  else
    self.BanData = {}
    self.BanData.BannedUsers = {}
    self:SaveBans()
  end
  
  -- Add Flagged chat commands
  flags_plugin:AddFlagsChatCommand(self, "kick", {"kick"}, self.cmdKick)
  flags_plugin:AddFlagsChatCommand(self, "ban", {"ban"}, self.cmdBan)
  flags_plugin:AddFlagsChatCommand(self, "unban", {"unban"}, self.cmdUnban)
  flags_plugin:AddFlagsChatCommand(self, "lua", {"lua"}, self.cmdLua)
  flags_plugin:AddFlagsChatCommand(self, "god", {"godmode"}, self.cmdGod)
  flags_plugin:AddFlagsChatCommand(self, "airdrop", {"airdrop"}, self.cmdAirdrop)
  flags_plugin:AddFlagsChatCommand(self, "give", {"give"}, self.cmdGive)
  flags_plugin:AddFlagsChatCommand(self, "tp", {"teleport"}, self.cmdTeleport)
  flags_plugin:AddFlagsChatCommand(self, "notice", {"notice"}, self.cmdNotice)
  flags_plugin:AddFlagsChatCommand(self, "save", {"save"}, self.cmdSave)

  -- Flagless commands
  flags_plugin:AddFlagsChatCommand(self, "help", {}, self.cmdHelp)
  flags_plugin:AddFlagsChatCommand(self, "loc", {}, self.cmdLoc)
end

-- *******************************************
-- CHAT COMMANDS
-- *******************************************
function PLUGIN:cmdKick(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Syntax: /kick name")
    return
  end
  local b, targetuser = rust.FindNetUsersByName(args[1])
  if (not b) then
    if (targetuser == 0) then
      rust.Notice(netuser, "No players found with that name!")
    else
      rust.Notice(netuser, "Multiple players found with that name!")
    end
    return
  end
  local targetname = util.QuoteSafe(targetuser.displayName)
  rust.BroadcastChat(self.Config.chatname, "'" .. targetname .. "' was kicked by '" .. util.QuoteSafe(netuser.displayName) .. "'!")
  rust.Notice(netuser, "\"" .. targetname .. "\" kicked.")
  targetuser:Kick(NetError.Facepunch_Kick_RCON, true)
end

function PLUGIN:cmdBan(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Syntax: /ban name")
    return
  end
  local b, targetuser = rust.FindNetUsersByName(args[1])
  if (not b) then
    if (targetuser == 0) then
      rust.Notice(netuser, "No players found with that name!")
    else
      rust.Notice(netuser, "Multiple players found with that name!")
    end
    return
  end

  self:BanUser(targetuser)
  
  local targetname = util.QuoteSafe(targetuser.displayName)
  rust.BroadcastChat(self.Config.chatname, "'" .. targetname .. "' was banned by '" .. util.QuoteSafe(netuser.displayName) .. "'!")
  rust.Notice(netuser, "\"" .. targetname .. "\" banned.")

  targetuser:Kick(NetError.Facepunch_Kick_Ban, true)
end

function PLUGIN:cmdUnban(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Syntax: /unban name")
    return
  end

  local count = 0
  local steamid
  for id, data in pairs(self.BanData.BannedUsers) do
    if (data.Name:match(args[1])) then
      count = count + 1
      steamid = data.SteamID or data.steamID
    end
  end

  if (count == 0) then
    rust.Notice(netuser, "No banned users found with that name!")
    return
  elseif (count > 1) then
    rust.Notice(netuser, "Multiple banned users found with that name!")
    return
  end

  rust.Notice(netuser, self.BanData.BannedUsers[steamid].Name .. " unbanned.")
  self.BanData.BannedUsers[steamid] = nil
  self:SaveBans()
end

function PLUGIN:cmdTeleport(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Syntax: /tp target OR /tp player target")
    return
  end
  local b, targetuser = rust.FindNetUsersByName(args[1])
  if (not b) then
    if (targetuser == 0) then
      rust.Notice(netuser, "No players found with that name!")
    else
      rust.Notice(netuser, "Multiple players found with that name!")
    end
    return
  end
  if (not args[2]) then
    -- Teleport netuser to targetuser
    rust.ServerManagement():TeleportPlayerToPlayer(netuser.networkPlayer, targetuser.networkPlayer)
    rust.Notice(netuser, "You teleported to '" .. util.QuoteSafe(targetuser.displayName) .. "'!")
  else
    local b, targetuser2 = rust.FindNetUsersByName(args[2])
    if (not b) then
      if (targetuser2 == 0) then
        rust.Notice(netuser, "No players found with that name!")
      else
        rust.Notice(netuser, "Multiple players found with that name!")
      end
      return
    end
    
    -- Teleport targetuser to targetuser2
    rust.ServerManagement():TeleportPlayerToPlayer(targetuser.networkPlayer, targetuser2.networkPlayer)
    rust.Notice(targetuser, "You were teleported to '" .. util.QuoteSafe(targetuser2.displayName) .. "'!")
  end
end

function PLUGIN:cmdGod(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Syntax: /god target")
    return
  end
  
  local b, targetuser = rust.FindNetUsersByName(args[1])
  if (not b) then
    if (targetuser == 0) then
      rust.Notice(netuser, "No players found with that name!")
    else
      rust.Notice(netuser, "Multiple players found with that name!")
    end
    return
  end

  local targetname = util.QuoteSafe(targetuser.displayName)
  if (flags_plugin:AddFlag(targetuser, "hasgodmode")) then
    rust.Notice(netuser, "\"" .. targetname .. "\" now has godmode.")
    rust.Notice(targetuser, "You now have godmode.")
  elseif (flags_plugin:RemoveFlag(targetuser, "hasgodmode")) then
    rust.Notice(netuser, "\"" .. targetname .. "\" no longer has godmode.")
    rust.Notice(targetuser, "You no longer have godmode.")
  else
    rust.Notice(netuser, "\"" .. targetname .. "\" has godmode through a Flag group and it cannot be removed.")
  end
end

function PLUGIN:cmdLua(netuser, cmd, args)
  if (not args[1]) then
    rust.Notice(netuser, "Input may not be blank")
  end

  local code = table.concat(args, " ")
  local func, err = load(code)
  if (err) then
    rust.Notice(netuser, err)
    return
  end
  local b, res = pcall(func)
  if (not b) then
    rust.Notice(netuser, err)
    return
  end
  if (res) then
    rust.Notice(netuser, tostring(res))
  else
    rust.Notice(netuser, "No output from Lua call.")
  end
end

function PLUGIN:cmdAirdrop(netuser, cmd, args)
  local dropCount = tonumber(args[1])
  if (dropCount and dropCount > 1) then
    for i = 1, dropCount do
      rust.CallAirdrop()
    end
    rust.Notice(netuser, "Successfully called in " .. dropCount .. " airdrops.")
  else
    rust.CallAirdrop()
    rust.Notice(netuser, "Successfully called in an airdrop.")
  end
end

local preftype = cs.gettype( "Inventory+Slot+Preference, Assembly-CSharp" )
function PLUGIN:cmdGive( netuser, args )
	if (not args[1]) then
		rust.Notice( netuser, "Syntax: /give itemname {quantity}" )
		return
	end
	local datablock = rust.GetDatablockByName( args[1] )
	if (not datablock) then
		rust.Notice( netuser, "No such item!" )
		return
	end
	local amount = tonumber( args[2] ) or 1
	local pref = rust.InventorySlotPreference( InventorySlotKind.Default, false, InventorySlotKindFlags.Belt )
	local inv = rust.GetInventory( netuser )
	local arr = util.ArrayFromTable( System.Object, { datablock, amount, pref } )
	util.ArraySet( arr, 1, System.Int32, amount )
	if (type( inv.AddItemAmount ) == "string") then
		print( "AddItemAmount was a string! (inv = " .. tostring( inv ) .. " - " .. (inv and inv:GetType().Name or "") .. ")" )
	else
		inv:AddItemAmount( datablock, amount, pref )
	end
	rust.InventoryNotice( netuser, tostring( amount ) .. " x " .. datablock.name )
end


-- Borrowed from "Broadcast" plugin
function PLUGIN:cmdNotice(netuser, cmd, args)
  local message = table.concat(args, " ")
  local netusers = rust.GetAllNetUsers()
  for k,user in pairs(netusers) do
    rust.Notice(user, message)
  end
end

function PLUGIN:cmdSave(netuser, cmd, args)
  rust.RunServerCommand("save.all")
  plugins.Call("OnSave")
  rust.Notice(netuser, "Successfully saved the server.")
end

function PLUGIN:cmdLoc(netuser, cmd, args)
  local coords = self:GetUserCoordinates(netuser)
  if (coords ~= nil) then
    rust.SendChatToUser(netuser, self.Config.chatname, "Your coordinates are: " .. coords.x ..  "-x, " .. coords.y .. "-y, " .. coords.z .. "-z")
  end
end

-- *******************************************
-- HOOK FUNCTIONS
-- *******************************************

-- *******************************************
-- PLUGIN:CanClientLogin()
-- Saves the player data to file
-- *******************************************
local SteamIDField = util.GetFieldGetter(RustFirstPass.SteamLogin, "SteamID", true)
--local PlayerClientAll = util.GetStaticPropertyGetter(RustFirstPass.PlayerClient, "All")
--local serverMaxPlayers = util.GetStaticFieldGetter(RustFirstPass.server, "maxplayers")
function PLUGIN:CanClientLogin(login)
  if (not flags_plugin) then
    error("This plugin requires Flags to be installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end
  
  -- Find the player's steamID
  local userID = tostring(SteamIDField(login.SteamLogin))
  local steamID = self:SteamIDToSteam64(self:CommunityIDToSteamIDFix(userID))

  if (self:IsUserBanned(steamID)) then
    print("Banned player '" .. self.BanData.BannedUsers[steamID].Name .. "' tried to connect.")
    return NetError.ConnectionBanned
  end
  
  -- Get the maximum number of players
  local maxplayers = RustFirstPass.server.maxplayers
  local curplayers = RustFirstPass.PlayerClient.All.Count
  
  -- Are we biting into reserved slots?
  if (curplayers + self.Config.reservedslots >= maxplayers) then
    -- Check if they have reserved flag
    if (flags_plugin:HasFlag(steamID, "reserved")) then
      return
    end
    return NetError.Facepunch_Approval_TooManyConnectedPlayersNow
  end
end

-- *******************************************
-- PLUGIN:OnUserConnect()
-- Called when a user has connected
-- *******************************************
function PLUGIN:OnUserConnect(netuser)
  if (not flags_plugin) then
    error("This plugin requires Flags to be installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end

  local sid = self:CommunityIDToSteamIDFix(tonumber(rust.GetUserID(netuser)))
  print("User \"" .. util.QuoteSafe(netuser.displayName) .. "\" connected with SteamID '" .. sid .. "'")

  if (self.Config.showwelcomenotice) then
    rust.Notice(netuser, self.Config.welcomenotice:format(netuser.displayName))
  end

  if (self.Config.showconnectedmessage) then
   rust.BroadcastChat(self.Config.chatname, netuser.displayName .. " has joined the game.")
 end
end

-- *******************************************
-- PLUGIN:OnUserDisconnect()
-- Called when a user has disconnected
-- *******************************************
function PLUGIN:OnUserDisconnect(netuser)
  if (not flags_plugin) then
    error("This plugin requires Flags to be installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end
  
  if (self.Config.showdisconnectedmessage) then
    rust.BroadcastChat(self.Config.chatname, netuser.displayName .. " has left the game.")
  end
end

-- *******************************************
-- PLUGIN:OnTakeDamage()
-- Called when an entity take damage
-- *******************************************
function PLUGIN:ModifyDamage(takedamage, damage)
  if (not flags_plugin) then
    error("This plugin requires Flags to be installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end

  if (takedamage:GetComponent("HumanController")) then
    if (damage.victim and damage.victim.client) then
      local victim = damage.victim.client.netUser
      if (victim) then
        if (flags_plugin:HasActualFlag(victim, "hasgodmode")) then
          damage.amount = 0
          return damage
        end
      end
    end
  end
end

function PLUGIN:OnSave()
  if (not flags_plugin) then
    error("This plugin requires Flags to be installed! Check here: http://forum.rustoxide.com/resources/flags.155")
    return
  end

  self:SaveBans()
end

-- *******************************************
-- HELPER FUNCTIONS
-- *******************************************

-- *******************************************
-- PLUGIN:LoadDefaultConfig()
-- Loads the default configuration into the config table
-- *******************************************
function PLUGIN:LoadDefaultConfig()
  -- Set default configuration settings
  self.Config.chatname = "Basics"
  self.Config.reservedslots = 2
  self.Config.showwelcomenotice = true
  self.Config.welcomenotice = "Welcome to the server %s! Type /help for a list of commands."
  self.Config.showconnectedmessage = true
  self.Config.showdisconnectedmessage = true
  self.Config.helptext =
  {
    "Welcome to the server!",
    "Type /help for a list of commands.",
    "Type /loc to get your current location."
  }
end

function PLUGIN:BanUser(netuser)
  local userName = util.QuoteSafe(netuser.displayName)
  local userID = tonumber(rust.GetUserID(netuser))
  local steamID = self:SteamIDToSteam64(self:CommunityIDToSteamIDFix(userID))

  self.BanData.BannedUsers[steamID] = {}
  self.BanData.BannedUsers[steamID].Name = userName
  self.BanData.BannedUsers[steamID].SteamID = steamID
  self:SaveBans()
end

function PLUGIN:IsUserBanned(steamid)
  return self.BanData.BannedUsers[steamid] ~= nil
end

function PLUGIN:SaveBans()
  self.BanFile:SetText(json.encode(self.BanData))
  self.BanFile:Save()
end

-- Next three functions were copied over from the Flags plugin, which
-- borrowed the code from either libraries online or the manateesban plugin
function PLUGIN:CommunityIDToSteamIDFix(userID)
  return "STEAM_0:" .. math.ceil((userID/2) % 1) .. ":" .. math.floor(userID/2)
end

local function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

function PLUGIN:SteamIDToSteam64(steamid)
  local tokens = split(steamid, ":")
  local serverID, authID
  if (tonumber(tokens[3]) > tonumber(tokens[2])) then
    serverID = tokens[2]
    authID = tokens[3]
  else
    serverID = tokens[3]
    authID = tokens[2]
  end
  return "7656" .. (1197960265728 + (authID * 2) + serverID)
end

function PLUGIN:GetUserCoordinates(netuser)
  local coords = netuser.playerClient.lastKnownPosition
  if (coords ~= nil and coords.x ~= nil and coords.y ~= nil and coords.z ~= nil) then
    if(type(coords.x) == 'number' and type(coords.y) == 'number' and type(coords.z) == 'number') then
      coords.x = math.floor(coords.x)
      coords.y = math.floor(coords.y)
      coords.z = math.floor(coords.z)
      return coords
    end
  end

  return nil
end
