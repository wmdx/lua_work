PLUGIN.Title = "Players"
PLUGIN.Description = "Shows Total Connected Players"

function PLUGIN:Init()
	self:AddChatCommand("players", self.cmdPlayers)
	self:AddChatCommand("Players", self.cmdPlayers)
	local b, res = config.Read( "players" )
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save( "players" ) end
	end
end

function PLUGIN:LoadDefaultConfig()
	self.Config.OnePlayerMessage = "You're the only one on you silly sap."
	self.Config.playersPerLine = 5
end


function PLUGIN:cmdPlayers( netuser, cmd, args )
	local maxplayers = tonumber(RustFirstPass.server.maxplayers)
	
	local ppl = tonumber(self.Config.playersPerLine)
	if not ppl then ppl = 5 end
	local listOfPlayers = rust.GetAllNetUsers()
    local count = 0
	for key,value in pairs(listOfPlayers) do
        count = count + 1
    end 
	local players = 0
	local msg = ""
	if(count == 1) then
		rust.SendChatToUser(netuser, self.Config.OnePlayerMessage)
	else
		rust.SendChatToUser( netuser, util.QuoteSafe(count .. "/".. maxplayers .. " Players Online"))
		for i=1, count, 1 do
			if(players < ppl) then
				msg = msg .. util.QuoteSafe(listOfPlayers[i].displayName) .. ", "
				players=players+1
			else
				msg = string.sub(msg,1,string.len(msg)-1)
				rust.SendChatToUser( netuser, msg)
				msg = util.QuoteSafe(listOfPlayers[i].displayName)
				players=1
			end --end of if
		end
		msg = string.sub(msg,1,string.len(msg)-2)
		rust.SendChatToUser( netuser, msg)
	end
	
end


