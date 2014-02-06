
PLUGIN.Title = "ChatHistory"
PLUGIN.Description = "Allows the player to see a chat history."

function PLUGIN:Init()
	self.HistoryFile = util.GetDatafile( "chathistory" )
	local txt = self.HistoryFile:GetText()
	if (txt ~= "") then
		self.History = json.decode( txt )
	else
		self.History = {}
	end
	self:AddChatCommand( "history", self.HistoryCmd )
	self:AddChatCommand( "historycleanup", self.HistoryCleanup )
end
function PLUGIN:HistoryCmd( netuser, cmd )
	local history = self.History
	local count = #history
	local tmpcount = 1
	rust.SendChatToUser(netuser, "Chat history:" )
	for key,value in pairs(self.History) do
		if (tmpcount > count - 20) then
			rust.SendChatToUser(netuser, self.History[key]["name"] .. ": " .. util.QuoteSafe(tostring(self.History[key]["msg"])))			
		end
		tmpcount = tmpcount + 1
	end
	return
end
function PLUGIN:HistoryInsert( netuser, msg )
	local history = self.History
	local newinsert = {}
	newinsert["name"] = netuser.displayName
	newinsert["msg"] = msg
	table.insert(self.History, newinsert)
	self:Save()
	return
end
function PLUGIN:HistoryCleanup( netuser, cmd )
	if ( not(netuser:CanAdmin()) ) then
        rust.Notice( netuser, "Only admins can do this" )
        return
    end
	self.History = {}
	self:Save()
	rust.Notice( netuser, "History deleted" )
	return
end
function PLUGIN:OnUserChat( netuser, name, msg )
	if (msg:sub( 1, 1 ) ~= "/") then
		self:HistoryInsert(netuser, msg)
	end
end
function PLUGIN:Save()
	self.HistoryFile:SetText( json.encode( self.History ) )
	self.HistoryFile:Save()
end