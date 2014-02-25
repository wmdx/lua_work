PLUGIN.Title = "Death Handler"
PLUGIN.Description = "Broadcast death messages to chat."
PLUGIN.Version = "1.5"
print( "Loading " .. PLUGIN.Title .. " V: " .. PLUGIN.Version .. " ..." )


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
function PLUGIN:Init()

		fileLog.file = util.GetDatafile("Death Handler " .. getTimeOrDate(true))
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
function fileLog.save()
	fileLog.file:SetText( table.concat( fileLog.text, "\r\n" ) )
	fileLog.file:Save()
end



function PLUGIN:notifyDeath(message)

	for _, netuser in pairs( rust.GetAllNetUsers() ) do
		if (flags_plugin:HasFlag( netuser, "death")) then rust.SendChatToUser( netuser, message ) end
		
	end
	table.insert( fileLog.text, getTimeOrDate() .. " " .. message)
	fileLog.save()
		
	
end

function PLUGIN:DistanceFromPlayers(p1, p2)
    return math.sqrt(math.pow(p1.x - p2.x,2) + math.pow(p1.y - p2.y,2) + math.pow(p1.z - p2.z,2)) end

	
local _BodyParts = cs.gettype( "BodyParts, Facepunch.HitBox" )
local _GetNiceName = util.GetStaticMethod( _BodyParts, "GetNiceName" )
local _NetworkView = cs.gettype( "Facepunch.NetworkView, Facepunch.ID" )
print(_NetworkView:ToString())
local _Find = util.GetStaticMethod( _NetworkView, "Find" )
function PLUGIN:OnKilled(takedamage, damage)
	--TakeDamage , DamageEvent
	local weapon
	if(damage.extraData) then
		weapon = damage.extraData.dataBlock.name
	end
	local weaponMsg
	if( weapon ) then 
		if ((weapon == "M4") or (weapon == "MP5A4")) then
			weaponMsg = " using an " .. weapon 
		else
			weaponMsg = " using a " .. weapon 
		end
	else 
		weaponMsg = " "
	end
    if (takedamage:GetComponent( "HumanController" )) then   
        if(damage.victim.client and damage.attacker.client) then
			local isSamePlayer = (damage.victim.client == damage.attacker.client)
			if (damage.victim.client.netUser.displayName and not isSamePlayer) then
				local victimName = damage.victim.client.netUser.displayName
				local attackerName = damage.attacker.client.netUser.displayName
				aAv = damage.attacker.client.netUser:LoadAvatar()
				vAv = damage.victim.client.netUser:LoadAvatar()
				local dist = self:DistanceFromPlayers(vAv.pos,aAv.pos) 
				
						
					if _GetNiceName(damage.bodyPart) ~= nil then
						bodyMsg = attackerName .. " killed " .. damage.victim.client.netUser.displayName ..  weaponMsg .. " with a shot to their " .. _GetNiceName(damage.bodyPart) .. " from: " .. tostring(math.floor(dist)) .. "m"
					else
						bodyMsg = ""
					end
				
				if bodyMsg then
					self:notifyDeath(bodyMsg)
				else
					self:notifyDeath(attackerName .. " killed " .. victimName ..  weaponMsg .. " from" .. tostring(math.floor(dist)) .. "m")
				end
				return
			end
			if(isSamePlayer) then
				--Suicides
				local suicideMsg
				suicideMsg = " has commited suicide" 
				
				return
			end
		end
		
        return
    end

	

end



