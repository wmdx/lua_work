PLUGIN.Title = "Base Alarm"
PLUGIN.Description = "Logs base attacks."

-- ********************************
-- *        Base Alarm 1.1        *
-- * Created by Hatemail and Drex *
-- ********************************

-- This plugin will send a notice to the owner of a structure if it is destroyed.
-- Any item that can be physically placed in the world will trigger the alarm. This
-- included walls, doors, and even things like furnaces or sleeping bags.

-- One thing to keep in mind, the alarm will only alert the original owner of the foundation
-- regardless of who puts the walls up afterword. This means if you take over a base or
-- help a friend build the base, only the person that laid the foundation will be notified.
-- This is something that I don't think is possible to change. It is how Rust assigns ownership
-- of the objects.

function PLUGIN: Init()
	print("Loading Base Alarm")
end

-- OnKilled is used to check when a deployable object is destroyed.
-- Once it is destroyed it checks to see who the owner is and then send them a notice.
function PLUGIN:OnKilled( takedamage, damage)
	if (takedamage:GetComponent( "DeployableObject" )) then
		if(damage.attacker.client) then
			local deployable = takedamage:GetComponent( "DeployableObject" )
			if(deployable.creatorID ~= damage.attacker.client.netUser.Userid) then
				print( deployable.creatorID .. "'s base (Deployable) has been attacked by.." .. damage.attacker.client.netUser.displayName)
			end
			return
		end
    end
		
	if (takedamage:GetComponent ( "StructureComponent" )) then
		if(damage.attacker.client) then
			local entity = takedamage:GetComponent("StructureComponent")
			local master = entity._master
			if(master.creatorID ~= damage.attacker.client.netUser.Userid) then
				print( master.creatorID .. "'s base (Structure) has been attacked by.. " .. damage.attacker.client.netUser.displayName)
			end
			return
		end
	end
	
end