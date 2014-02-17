PLUGIN.Title = "RaidLog"
PLUGIN.Description = "Logs when things are raided. (BaseAlarm Fork)"

print ( "Loading " .. PLUGIN.Title )
--Gets the function to call date time
local dateTime = util.GetStaticPropertyGetter( System.DateTime, 'Now' )
if not fileLog then fileLog = {} end
--Thanks to user973713
local function split(str, delimiter)
    result = {};
	if delimiter == nil then
                delimiter = "%s"
    end
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
--True for date false for date + time
local function getTimeOrDate(dtB)
	local dt = split(tostring(dateTime()))
	local date = dt[1]
	local time = dt[2]
	local ap = dt[3]
	print("Time: " .. ap)
	local dateSplit = split(date,"/")
	if (string.len(dateSplit[1]) == 1) then dateSplit[1] = "0"..dateSplit[1] end 
	date = table.concat( {dateSplit[1], dateSplit[2], dateSplit[3] }, "-" )
	
	local timeSplit = split(time,":")
	if ap == "PM:" then timeSplit[1] = tonumber( timeSplit[1] ) + 12 end
	time = table.concat( timeSplit, ":" )
	
	if dtB then return "(" .. date .. ")"end
	return "(" .. date .. " " .. time .. ")"
end


function PLUGIN: Init()
	print("Loading Base Alarm")
	
		fileLog.file = util.GetDatafile("RaidLog " .. getTimeOrDate(true))
		local logText = fileLog.file:GetText()
		if (logText ~= "") then
		
			fileLog.text = split(logText,"\r\n")
			
		else
			
			fileLog.text = {}
		
		end
	
		flags_plugin = plugins.Find("flags")
	if (not flags_plugin) then
	  error("You do not have the flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155/")
	  return
	end
	

end

function PLUGIN.CommunityIDToSteamIDFix( id )
  return "STEAM_0:" .. math.ceil((id/2) % 1)  .. ":" .. math.floor(id / 2)
end
-- OnKilled is used to check when a deployable object is destroyed.
-- Once it is destroyed it checks to see who the owner is and then send them a notice.

	local getStructureMasterOwnerId = util.GetFieldGetter(Rust.StructureMaster, "ownerID", true)
	local getDeployableOwnerId = util.GetFieldGetter(Rust.DeployableObject, "ownerID", true)
function PLUGIN:OnKilled( takedamage, damage)
	if (takedamage:GetComponent( "DeployableObject" )) then
		if(damage.attacker.client) then
			local deployable = takedamage:GetComponent( "DeployableObject" )
			local doid = getDeployableOwnerId(deployable)
			local steamid = self.CommunityIDToSteamIDFix( tonumber( doid ) )
			
			if(deployable.creatorID ~= damage.attacker.client.netUser.Userid) then
				oID = deployable.creatorID 
				--SoID = rust.CommunityIDToSteamID(oID)

				
				raidmsg = steamid .. "'s base (Deployable) has been attacked by.." .. damage.attacker.client.netUser.displayName
				self:NotifyRaid(raidmsg)
			end
			return
		end
    end
		
	if (takedamage:GetComponent ( "StructureComponent" )) then
		if(damage.attacker.client) then
			local entity = takedamage:GetComponent("StructureComponent")
			local master = entity._master
			local soid = getStructureMasterOwnerId(master)
			local steamid = self.CommunityIDToSteamIDFix( tonumber( soid ) )
			if(master.creatorID ~= damage.attacker.client.netUser.Userid) then
				oID = master.creatorID
				--SoID = rust.CommunityIDToSteamID(oID)
				raidmsg = steamid .. "'s base (Structure) has been attacked by.. " .. damage.attacker.client.netUser.displayName
				self:NotifyRaid(raidmsg)
			end
			return
		end
	end
	
end

function PLUGIN:NotifyRaid(message) 
	for _, netuser in pairs( rust.GetAllNetUsers() ) do 
		if (flags_plugin:HasFlag( netuser, "raid")) then 

			rust.SendChatToUser( netuser, message) 

		end
	end
		
	table.insert( fileLog.text, getTimeOrDate() .. " " .. message)
	fileLog.save()
end

function fileLog.save()
	fileLog.file:SetText( table.concat( fileLog.text, "\r\n" ) )
	fileLog.file:Save()
end