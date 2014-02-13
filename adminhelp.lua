
PLUGIN.Title = "adminhelp"
PLUGIN.Description = "Send messages to admins only"
PLUGIN.Author = "Hunter"


function PLUGIN:Init()

	--self:AddChatCommand( "adminhelp", self.cmdAdminHelp )
	--self:AddChatCommand( "ar", self.cmdAdminResponse )
	--self:AddChatCommand( "@", self.cmdAdminChat )
	flags_plugin = plugins.Find("flags")
	if (not flags_plugin) then
	  error("You do not have the flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155/")
	  return
	end
	
	flags_plugin:AddFlagsChatCommand(self, "ahelp", {}, self.cmdAdminHelp)
	flags_plugin:AddFlagsChatCommand(self, "ar", {"admin"}, self.cmdAdminResponse)
	flags_plugin:AddFlagsChatCommand(self, "@", {"admin"}, self.cmdAdminChat)
	
end



function PLUGIN:cmdAdminHelp( netuser, cmd, args )
	
	if #args == 0 then return end
	
	local esc_string = util.QuoteSafe( table.concat( args, " " ) )
	
	for _, user in pairs( rust.GetAllNetUsers() ) do

		if self:canAdminHelp( user ) then
			rust.RunClientCommand( user, "chat.add \"@help " .. util.QuoteSafe( netuser.displayName ) .. "\" \"" .. esc_string .. "\"" )
		end
		
	end
	
	rust.RunClientCommand( netuser, "chat.add \"To Admins\" \"" .. esc_string .. "\"" )
	
end


function PLUGIN:cmdAdminChat( netuser, cmd, args )

	

	if #args == 0 then return end
	
	local esc_string = table.concat( args, " " )
	
	for _, user in pairs( rust.GetAllNetUsers() ) do
		
	
			rust.RunClientCommand( user, "chat.add \"@mins " .. util.QuoteSafe( netuser.displayName ) .. "\" \"" .. esc_string .. "\"" )
		
	end

end


function PLUGIN:cmdAdminResponse( netuser, cmd, args )
	
	
	if #args < 2 then return end
	
	local target = args[1]
	
	local bResult, user = rust.FindNetUsersByName( target )
	
	table.remove( args, 1 )
	local esc_string = util.QuoteSafe( table.concat( args, " " ) )
	
	if not bResult then 
		
		rust.Notice( netuser, "ERROR: Player lookup failed" )
		return
		
	end
	
	rust.RunClientCommand( user, "chat.add \"From Admin\" \"" .. esc_string .. "\"" )
	rust.RunClientCommand( netuser, "chat.add \"@mins to " .. util.QuoteSafe( user.displayName ) .. "\" \"" .. esc_string .. "\"" )

end

