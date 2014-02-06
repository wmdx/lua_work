PLUGIN.Title = "Staff"
PLUGIN.Description = "Allows users to read the staff names"

local alternate = true

function PLUGIN:Init()

	--Finds the staff list file.
	self.StaffDataFile = util.GetDatafile( "staff" )
	local txt = self.StaffDataFile:GetText()
	if (txt ~= "") then
		self.StaffData = json.decode( txt )
	else
		self.StaffData = {}
	end
	
	--Read the staff file
	local b, res = config.Read( "staff" )
	self.Config = res or {}
	if (not b) then
		--If the config file does not exist, then run this.
		self:LoadDefaultConfig{}
		if (res) then config.Save( "staff" ) end
	end
	
	-- Chat command to trigger the staff list.
	self:AddChatCommand("staff", self.cmdStaff)
end

function PLUGIN:LoadDefaultConfig()
	
	--If no config is present, then this is shown and created for the config.
	self.Config.chatname = "SwiftyUS Bot"
	self.Config.stafftext =
	{
		"STAFF NAME - RANK",
                "Wmdx - Admin / Owner",
                "stu - Admin / Owner",
                "Tyrone - Admin / Owner"
	}

end

function PLUGIN:cmdStaff(netuser, args)
	--Sends staff list to the client.
	for i=1, #self.Config.stafftext do
		rust.SendChatToUser (netuser, self.Config.stafftext[i])
	end
end 


