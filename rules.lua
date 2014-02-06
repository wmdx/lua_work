-----------------------
-----------------------
----Created by Snow----
-----------------------
-----------------------

PLUGIN.Author = "Snow and Smooth"
PLUGIN.Title = "Rules"
PLUGIN.Description = "Lists Rules of the server"
PLUGIN.Version = "1.2"


local alternate = true

function PLUGIN:Init()

	--Finds the rules file.
	self.RulesDataFile = util.GetDatafile("rules")
	local txt = self.RulesDataFile:GetText()
	if (txt ~= "") then
		self.RulesData = json.decode(txt)
	else
		self.RulesData = {}
	end
	
	--Read the rules file
	local b, res = config.Read("rules")
	self.Config = res or {}
	if (not b) then
		--If the config file does not exist, then run this.
		self:LoadDefaultConfig{}
		if (res) then config.Save("rules") end
	end
	
	-- Chat command to trigger the rules.
	self:AddChatCommand("rules", self.cmdRules)
end

function PLUGIN:LoadDefaultConfig()
	
	--If no config is present, then this is shown and created for the config.
	self.Config.chatname = "SwiftyUS Rules"
	self.Config.ruletext =
	{
		"No Griefing Players",
		"No Spawn-camping",
		"No Spam over global Chat",
		"No Harassing Players / Camping Bags",
		"Racism is not allowed",
		"Racism is not allowed",
		"Remember, we are a noob friendly server. But PvP and raiding is allowed",
		"Visit the forums for more in depth rules. swiftyus.com"
	}

end

function PLUGIN:cmdRules(netuser, name, args)
	--Sends Rules to the client.
	for i=1, #self.Config.ruletext do
		rust.SendChatToUser(netuser, self.Config.chatname, self.Config.ruletext[i])
	end

end


 
