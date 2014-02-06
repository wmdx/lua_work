-- Plugin Created By ReTric
PLUGIN.Title = "Rank Prefix"
PLUGIN.Description = "Put Rank Prefix before or after name."
PLUGIN.Author = "ReTric"

print("Prefixer Loaded Successfully!")

function PLUGIN:Init()
 self:AddChatCommand( "prefix", self.CmdAddPrefix )

	 local b, res = config.Read( "Prefixer" )
 self.Config = res or {}
 if (not b) then
  self:LoadDefaultConfig()
  if (res) then config.Save( "Prefixer" ) end
 end

	 	oxmin_Plugin = plugins.Find("oxmin")

    if not oxmin_Plugin or not oxmin then
        print("ERROR: Prefix Flags Not Added! Requires Oxmin")
        self.oxminInstalled = false
        return;
    end;

	self.FLAG_ADMIN = oxmin.AddFlag("Admin")
	self.FLAG_MOD = oxmin.AddFlag("Mod")
	self.FLAG_VIP = oxmin.AddFlag("Vip")
	self.FLAG_GIVEPREFIX = oxmin.AddFlag("giveprefix")
    self.oxminInstalled = true
	print("Prefix flags successfully added!")
end

function PLUGIN:LoadDefaultConfig()
 self.Config.behindName = true
 self.Config.adminTag = "[Admin]"
 self.Config.modTag = "[Mod]"
 self.Config.vipTag = "[Donator]"
end

--Checks to see what flag user has if any
function PLUGIN:OnUserChat(netuser, name, msg)
    if (msg:sub(1, 1) == "/") then
        return true
    end
	if (msg == "/prefix") then
	return false
	end
	if (oxmin_Plugin:HasFlag(netuser, self.FLAG_ADMIN, true)) then
		if (self.Config.behindName == true) then
		rust.BroadcastChat( self.Config.adminTag .. name, msg )
		else
		rust.BroadcastChat( name .. self.Config.adminTag, msg )
		end
		return false
	end
	if (oxmin_Plugin:HasFlag(netuser, self.FLAG_MOD, true)) then
		if (self.Config.behindName == true) then
		rust.BroadcastChat( self.Config.modTag .. name, msg )
		else
		rust.BroadcastChat( name .. self.Config.modTag, msg )
		end
		return false
	end
	if (oxmin_Plugin:HasFlag(netuser, self.FLAG_VIP, true)) then
		if (self.Config.behindName == true) then
		rust.BroadcastChat( self.Config.vipTag .. name, msg )
		else
		rust.BroadcastChat( name .. self.Config.vipTag, msg )
		end
		return false
	end
	return
end

function PLUGIN:CmdAddPrefix(netuser, cmd, args)
	if (netuser:CanAdmin()) or (oxmin_Plugin:HasFlag(netuser, self.FLAG_GIVEPREFIX, false)) then
	if (not args[1]) then
		rust.Notice(netuser, "Command Help: /prefix {playerName} {prefix}")
		return false
	elseif (not args[2]) then
		rust.Notice(netuser, "Command Help: /prefix {playerName} {prefix}")
		return false
	end
		local b, targetPlayer = rust.FindNetUsersByName(args[1])

		local flag = tostring(args[2])
		if not(b) then
		if (targetPlayer == 0) then
			rust.Notice(netuser, "No players were found with that name.")
			return
		else
			rust.Notice(netuser, "Multiple players were found with that name.")
			return
		end
		end
		local targetname = util.QuoteSafe( targetPlayer.displayName )
		if flag == "Owner" or flag == "Admin" or flag == "Mod" or flag == "Vip" or flag == "Dev" or flag == "Custom" then
		--Removes any previous flags and adds new one
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Owner\"" )
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Admin\"" )
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Mod\"" )
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Vip\"" )
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Dev\"" )
		rust.RunServerCommand( "oxmin.takeflag \"" .. targetname .. "\" \"Custom\"" )
		rust.RunServerCommand( "oxmin.giveflag \"" .. targetname .. "\" \"" .. flag .. "\"" )
		rust.SendChatToUser( netuser, "Prefixer", "The prefix {" .. flag ..  "} has been added to " .. targetname .. "!" )
		rust.SendChatToUser( targetPlayer, "Prefixer", "You have been given the prefix {" .. flag .. "}" )
		else
		rust.Notice(netuser, "Invalid Prefix Name!")
		end

	else
	rust.Notice(netuser, "You do not have permission to add prefix!")
	end
end


