PLUGIN.Title = "Remover Tool"
PLUGIN.Description = "Remove Building"
PLUGIN.Author = "Guewen and Thx Rexas "

PLUGIN.AllowPlayer = true  -- edited me to enable or disable this command to players.  ->  PLUGIN.AllowPlayer = true or PLUGIN.AllowPlayer = false
PLUGIN.AllowPlayerGiveItems = false  -- edited me to enable or disable restores items.  ->  PLUGIN.AllowPlayerGiveItems = true or PLUGIN.AllowPlayerGiveItems = false


function PLUGIN:Init()

	oxmin_Plugin = plugins.Find("oxmin")
    if oxmin_Plugin or oxmin then
        self.FLAG_REMOVER = oxmin.AddFlag( "remover" )
		self.FLAG_VIP = oxmin.strtoflag[ "Vip" ]
    end
	
	self:AddChatCommand("removeactiveplayer", self.RemoveActivePlayer)
	self:AddChatCommand("removerestoresitems", self.RemoveRestoreItems)
	
	self:AddChatCommand("RemoveAll", self.ActiveRemoveAdminAll)
	self:AddChatCommand("removeall", self.ActiveRemoveAdminAll)
	
	 
    self:AddChatCommand("RemoveAdmin", self.ActiveRemoveAdmin)
    self:AddChatCommand("removeadmin", self.ActiveRemoveAdmin)

	
    self:AddChatCommand("Remove", self.ActiveRemove)
    self:AddChatCommand("remove", self.ActiveRemove)
	
end

function PLUGIN:GetAdmin(netuser)

	if oxmin_Plugin or oxmin then
	
		if  oxmin_Plugin:HasFlag( netuser, self.FLAG_REMOVER, false ) then
			return true
		end
    end

	if netuser:CanAdmin() then
		return true
	end	

	return false
end

TableActivedRemove = {}
function PLUGIN:ActiveRemove( netuser, cmd, args )

	if (oxmin_Plugin:HasFlag(netuser, self.FLAG_VIP, true)) then
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

		if TableActivedRemove[steamID] then
			TableActivedRemove[steamID] = false
			rust.Notice(netuser, "Remove De-Actived")
		else
			TableActivedRemove[steamID] = true
			rust.Notice(netuser, "Remove Actived")
		end
	else 
		rust.Notice(netuser, "You are not authorized to use this command.")
		return
	end
	
end

TableActivedRemoveAmin = {}
function PLUGIN:ActiveRemoveAdmin( netuser, cmd, args )
    if self:GetAdmin(netuser) then
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

		if TableActivedRemoveAmin[steamID] then
			TableActivedRemoveAmin[steamID] = false
			rust.Notice(netuser, "Remove De-Actived")
		else
			TableActivedRemoveAmin[steamID] = true
			rust.Notice(netuser, "Remove Actived")
		end
	end	
end

TableActivedRemoveAminAll = {}
function PLUGIN:ActiveRemoveAdminAll( netuser, cmd, args )
    if self:GetAdmin(netuser) then
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

		if TableActivedRemoveAminAll[steamID] then
			TableActivedRemoveAminAll[steamID] = false
			rust.Notice(netuser, "Remove All De-Actived")
		else
			TableActivedRemoveAminAll[steamID] = true
			rust.Notice(netuser, "Remove All Actived ! ! !")
		end
	end	
end

function PLUGIN:RemoveActivePlayer( netuser, cmd, args )
    if self:GetAdmin(netuser) then

		if not self.AllowPlayer then
			rust.Notice(netuser, "Remove Actived for player")
			self.AllowPlayer = true
		else
			rust.Notice(netuser, "Remove Disable for player")
			self.AllowPlayer = false
		end

	end	
end

function PLUGIN:RemoveRestoreItems( netuser, cmd, args )
    if self:GetAdmin(netuser) then

		if not self.AllowPlayerGiveItems then
			rust.Notice(netuser, "Remove restores items Actived")
			self.AllowPlayerGiveItems = true
		else
			rust.Notice(netuser, "Remove restores items Desable")
			self.AllowPlayerGiveItems = false
		end

	end	
end

local GetComponents, SetComponents = typesystem.GetField( Rust.StructureMaster, "_structureComponents", bf.private_instance )
local function GetConnectedComponents( master )
    local hashset = GetComponents( master )
    local tbl = {}
    local it = hashset:GetEnumerator()
    while (it:MoveNext()) do
        tbl[ #tbl + 1 ] = it.Current
    end
    return tbl
end

TakeDamage = {}
TakeDamage.GetFromIDBase = util.GetStaticMethod( RustFirstPass.TakeDamage._type, "GetFromIDBase")
TakeDamage.HurtSelfFloat = function( target, val )

	local tmpO = util.GetStaticMethod( RustFirstPass.TakeDamage._type, "HurtSelf" )
	local HurtSelfFloatMethod = tmpO[3]
	local arr = cs.createarrayfromtable( cs.gettype( "System.Object" ), { target, val }, 2 )

	cs.convertandsetonarray( arr, 1, val, System.Single._type )

	return HurtSelfFloatMethod:Invoke(nil, arr )
end

local ItemTable ={}

-- Base
ItemTable["Wood_Shelter(Clone)"] = "Wood Shelter"
ItemTable["Campfire(Clone)"] = "Camp Fire"
ItemTable["Furnace(Clone)"] = "Furnace"
ItemTable["Workbench(Clone)"] = "Workbench"
ItemTable["SleepingBagA(Clone)"] = "Sleeping Bag"
ItemTable["SingleBed(Clone)"] = "Bed"


-- Attack and protect
ItemTable["LargeWoodSpikeWall(Clone)"] = "Large Spike Wall"
ItemTable["WoodSpikeWall(Clone)"] = "Spike Wall"
ItemTable["Barricade_Fence_Deployable(Clone)"] = "Wood Barricade"
ItemTable["WoodGateway(Clone)"] = "Wood Gateway"
ItemTable["WoodGate(Clone)"] = "Wood Gate"

-- Storage
ItemTable["WoodBoxLarge(Clone)"] = "Large Wood Storage"
ItemTable["WoodBox(Clone)"] = "Wood Storage Box"
ItemTable["SmallStash(Clone)"] = "Small Stash"

-- Structure Wood
ItemTable["WoodFoundation(Clone)"] = "Wood Foundation"
ItemTable["WoodWindowFrame(Clone)"] = "Wood Window"
ItemTable["WoodDoorFrame(Clone)"] = "Wood Doorway"
ItemTable["WoodWall(Clone)"] = "Wood Wall"
ItemTable["WoodenDoor(Clone)"] = "Wooden Door"
ItemTable["WoodCeiling(Clone)"] = "Wood Ceiling"
ItemTable["WoodRamp(Clone)"] = "Wood Ramp"
ItemTable["WoodStairs(Clone)"] = "Wood Stairs"
ItemTable["WoodPillar(Clone)"] = "Wood Pillar"

-- Structure Metal
ItemTable["MetalFoundation(Clone)"] = "Metal Foundation"
ItemTable["MetalWall(Clone)"] = "Metal Wall"
ItemTable["MetalDoorFrame(Clone)"] = "Metal Doorway"
ItemTable["MetalDoor(Clone)"] = "Metal Door"
ItemTable["MetalCeiling(Clone)"] = "Metal Ceiling"
ItemTable["MetalStairs(Clone)"] = "Metal Stairs"
ItemTable["MetalRamp(Clone)"] = "Metal Ramp"
ItemTable["MetalBarsWindow(Clone)"] = "Metal Window Bars"
ItemTable["MetalWindowFrame(Clone)"] = "Metal Window"
ItemTable["MetalPillar(Clone)"] = "Metal Pillar"
-- ItemTable[""] = ""

function PLUGIN:OnHurt( takedamage, damage )

	if takedamage then
		if takedamage.gameObject then
			if takedamage.gameObject.Name then
				if ItemTable[takedamage.gameObject.Name] then
					local name = ItemTable[takedamage.gameObject.Name]
					plugins.Call( "OnEntityTakeDamage", takedamage, damage, name )
				end
			end
		end	
	end

end

local varplayer = {}
local GetStructureComponentownerID = util.GetFieldGetter( Rust.StructureMaster, "ownerID", true )
local GetDeployableObjectownerID = util.GetFieldGetter( Rust.DeployableObject, "ownerID", true )

function PLUGIN:OnEntityTakeDamage( takedamage, damage , name)

	if (takedamage:GetComponent("StructureComponent")) then
		entity = takedamage:GetComponent("StructureComponent")
		local master = entity._master
		
		if master == "_master" then return end
		if type(master) == "string" then return end
		
		if master then 
		
			local userID = GetStructureComponentownerID(master)
			SteamIdEntity = rust.CommunityIDToSteamID( userID )
		end	
	end
	
	if (takedamage:GetComponent("DeployableObject")) then
		entity = takedamage:GetComponent("DeployableObject")
	
		
		local name = takedamage.gameObject.Name == "MetalBarsWindow(Clone)"
		local debugerror = damage.attacker.idMain.client == "client"
		-- Fix bug decay
		if entity.attacker then
			if not name then
				if not debugerror then
					return damage
				end	
			end	
		end

		if entity.GetComponent == "GetComponent" then
			print("Error")
			return
		end
		if type(entity.GetComponent) == "string" then return end
		
		local userID = GetDeployableObjectownerID(entity)
		SteamIdEntity = rust.CommunityIDToSteamID( userID )
	end
	
	if damage then
	
		if damage.attacker then
	   
			if damage.attacker.client then
			   
				if damage.attacker.client.netUser then
				   
					netuser = damage.attacker.client.netUser
				  
					if self:GetAdmin(netuser) then
						allow = true
					end
				
					steamID = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(netuser )))
				   
				end
			end
		end
	end
	
	if TableActivedRemoveAminAll[steamID] then
		if allow then
			if damage.extraData ~= nil and (damage.extraData:ToString() == "BulletWeaponImpact") or (damage.extraData:ToString() == "WeaponImpact")
			then
				if takedamage:GetComponent("StructureComponent") then
					for k,v in pairs (GetConnectedComponents(entity._master) ) do
				
						tostring(TakeDamage.HurtSelfFloat( v, 99999 ))
					
					end
				end	
			end
		end  
	end  

	if TableActivedRemoveAmin[steamID] then
		if allow then
		
			if damage.extraData ~= nil and (damage.extraData:ToString() == "BulletWeaponImpact") or (damage.extraData:ToString() == "WeaponImpact")
			then
			
				takedamage:SetGodMode(false)
				tostring(TakeDamage.HurtSelfFloat( entity, 99999 ))
				return
			end
		end  
	end  
		
	if self.AllowPlayer then
		if TableActivedRemove[steamID] then
			if SteamIdEntity == steamID then
			
				if damage.extraData ~= nil and (damage.extraData:ToString() == "BulletWeaponImpact") or (damage.extraData:ToString() == "WeaponImpact") then
			
					if self.AllowPlayerGiveItems then
						if not varplayer[steamID] then varplayer[steamID] = {} end
						if not varplayer[steamID].OldRemove then varplayer[steamID].OldRemove = {} end
						
						-- Fix duplication shootgun
						local dup = false
						for a,b in pairs(varplayer[steamID].OldRemove) do
							if b == entity then
								dup = true
							end
						end
						-- local dup = varplayer[steamID].OldRemove == entity
						if not dup then
							-- MetalBarsWindow is Realy invincible, Lol Garry ? - I want a solution.
							local debugs = takedamage.gameObject.Name == "MetalBarsWindow(Clone)" 
							if not debugs then
							
							
								local nodrop = false
								
								if takedamage.gameObject.Name == "Campfire(Clone)" then
									local wood = rust.GetDatablockByName( "Wood" )


									inv = entity:GetComponent( "Inventory" )
									local item1 = inv:FindItem(wood)
									if item1 then
										
										
										if item1.uses >= 5 then
										
											if item1.uses > 5 then
												local num = item1.uses - 5
												rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netuser.displayName ) .. "\" \"" .. util.QuoteSafe( "Wood" ) .. "\" " .. num )
											end
										else
											nodrop = true
											rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netuser.displayName ) .. "\" \"" .. util.QuoteSafe( "Wood" ) .. "\" " .. item1.uses )
										end
									else
										nodrop = true
									end	
								end
							
							
								if not nodrop then
									rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netuser.displayName ) .. "\" \"" .. util.QuoteSafe( name ) .. "\" " .. 1 )
								end	
							end
						end	
					end
					
					if not varplayer[steamID] then varplayer[steamID] = {} end
					if not varplayer[steamID].OldRemove then varplayer[steamID].OldRemove = {} end
					
					table.insert(varplayer[steamID].OldRemove, entity)
					
					takedamage:SetGodMode(false)
					tostring(TakeDamage.HurtSelfFloat( entity, 99999 ))
				end
			end
		end
	end
end