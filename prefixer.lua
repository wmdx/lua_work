-- Plugin Created By ReTric
PLUGIN.Title = "Rank Prefix"
PLUGIN.Description = "Put Rank Prefix before or after name."
PLUGIN.Author = "ReTric"

print("Prefixer Loaded Successfully!")

function PLUGIN:Init()

flags_plugin = plugins.Find("flags")
if (not flags_plugin) then
  error("You do not have the flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155/")
  return
end


end


--Checks to see what flag user has if any
function PLUGIN:OnUserChat(netuser, name, msg)
    if (msg:sub(1, 1) == "/") then
        return true
    end
	if (msg == "/prefix") then
	return false
	end
	if (flags_plugin:(netuser, "admin", true)) then
		rust.BroadcastChat( "[Admin] " .. name, msg )
		return false
	end
	if (flags_plugin:(netuser, "mod", true)) then
		rust.BroadcastChat( "[Mod] " .. name, msg )
		return false
	end
	if (flags_plugin:(netuser, "vip", true)) then
		rust.BroadcastChat( "[Donator ] " .. name, msg )
		return false
	end
end



