PLUGIN.Title = "Remover Tool"
PLUGIN.Description = "Remove Building"
PLUGIN.Author = "Guewen and Thx Rexas "

PLUGIN.AllowPlayerGiveItems = false  -- edited me to enable or disable restores items.  ->  PLUGIN.AllowPlayerGiveItems = true or PLUGIN.AllowPlayerGiveItems = false

local totable = string.ToTable
local string_sub = string.sub
local string_gsub = string.gsub
local string_gmatch = string.gmatch
function string.Explode(separator, str, withpattern)
	if (separator == "") then return totable( str ) end
	 
	local ret = {}
	local index,lastPosition = 1,1
	 
	-- Escape all magic characters in separator
	if not withpattern then separator = string_gsub( separator, "[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1" ) end
	 
	-- Find the parts
	for startPosition,endPosition in string_gmatch( str, "()" .. separator.."()" ) do
		ret[index] = string_sub( str, lastPosition, startPosition-1)
		index = index + 1
		 
		-- Keep track of the position
		lastPosition = endPosition
	end
	 
	-- Add last part by using the position we stored
	ret[index] = string_sub( str, lastPosition)
	return ret
end

function PLUGIN:LoadConfig()

	Removerfile = util.GetDatafile( "remover" )
	local Removerfile = Removerfile:GetText()
	
	Removerconfigdecode = string.Explode("\n", Removerfile) 
		
	for k,v in pairs(Removerconfigdecode) do
	
		local line = string.Explode(" ", v) 
		
		if line[1] == "AllowPlayer" then
			if line[3] == "true" then self.AllowPlayer = true else self.AllowPlayer = false end
		end
		
		if line[1] == "AllowPlayerGiveItems" then
			if line[3] == "true" then self.AllowPlayerGiveItems = true else self.AllowPlayerGiveItems = false end
		end
		
	end

end

function PLUGIN:Init()

	print("Remover Load")
	
	Removerfile = util.GetDatafile( "remover" )
	
	local Removerfile = Removerfile:GetText()
	if (Removerfile ~= "") then
		self:LoadConfig()
	else
		Removerconfig = "AllowPlayer = true \nAllowPlayerGiveItems = true"
		self:Save()
		self:LoadConfig()
	end
	
	oxmin_Plugin = plugins.Find("oxmin")
    if oxmin_Plugin or oxmin then
        self.FLAG_REMOVER = oxmin.AddFlag( "remover" )
    end
	
	-- self:AddChatCommand("load", self.loadfiles)
	
	--self:AddChatCommand("removeactiveplayer", self.RemoveActivePlayer)
	self:AddChatCommand("removerestoresitems", self.RemoveRestoreItems)
	
	self:AddChatCommand("RemoveAll", self.ActiveRemoveAdminAll)
	self:AddChatCommand("removeall", self.ActiveRemoveAdminAll)
	
	 
    self:AddChatCommand("RemoveAdmin", self.ActiveRemoveAdmin)
    self:AddChatCommand("removeadmin", self.ActiveRemoveAdmin)

	flags_plugin = plugins.Find("flags")
    if (not flags_plugin) then
        print("You do not have the Flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155")
        print("Loaded Simple Home without Flags support.")
    end

    flags_plugin:AddFlagsChatCommand(self, "remove", {"remove"}, self.RemoveActivePLayer)
	
end

function PLUGIN:Save()
	Removerfile:SetText( Removerconfig )
	Removerfile:Save()
end

function PLUGIN:loadfiles( netuser, cmd, args )

   cs.reloadplugin( "0-remover" ) 
	
end


function PLUGIN:GetAdmin(netuser)

	if netuser:CanAdmin() then
		return true
	end	

	return false
end

TableActivedRemove = {}
function PLUGIN:ActiveRemove( netuser, cmd, args )

	local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

	if TableActivedRemove[steamID] then
		TableActivedRemove[steamID] = false
		rust.Notice(netuser, "Remove De-Actived")
	else
		TableActivedRemove[steamID] = true
		rust.Notice(netuser, "Remove Actived")
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
			if not varplayer[steamID] then varplayer[steamID] = {} end
			varplayer[steamID].RemoveAllactived = false
			varplayer[steamID].netuser = netuser
		else
			TableActivedRemoveAminAll[steamID] = true
			rust.Notice(netuser, "Remove All Actived ! ! !")
			if not varplayer[steamID] then varplayer[steamID] = {} end
			varplayer[steamID].RemoveAllactived = true
			varplayer[steamID].netuser = netuser
		end
	end	
end

-- for reload
if RemoveTimer then
RemoveTimer:Destroy()
end
RemoveTimer = timer.Repeat( 15, 0, function()

	for k,v in pairs(varplayer) do
		
		if v.RemoveAllactived then
			rust.Notice(v.netuser, "Remove All Is Actived ! ! !")	
		end
		
	end
	
end)


function PLUGIN:RemoveActivePlayer( netuser, cmd, args )

		if not self.AllowPlayer then
			rust.Notice(netuser, "Remove Actived for player")
			self.AllowPlayer = true
			
			Removerconfig = "AllowPlayer = ".. tostring(self.AllowPlayer) .. " \nAllowPlayerGiveItems = ".. tostring(self.AllowPlayerGiveItems) .. ""
			self:Save()
			self:LoadConfig()
		end

end

function PLUGIN:RemoveRestoreItems( netuser, cmd, args )
    if self:GetAdmin(netuser) then

		if not self.AllowPlayerGiveItems then
			rust.Notice(netuser, "Remove restores items Actived")
			self.AllowPlayerGiveItems = true
			Removerconfig = "AllowPlayer = ".. tostring(self.AllowPlayer) .. " \nAllowPlayerGiveItems = ".. tostring(self.AllowPlayerGiveItems) .. ""
			self:Save()
			self:LoadConfig()
		else
			rust.Notice(netuser, "Remove restores items Desable")
			self.AllowPlayerGiveItems = false
			Removerconfig = "AllowPlayer = ".. tostring(self.AllowPlayer) .. " \nAllowPlayerGiveItems = ".. tostring(self.AllowPlayerGiveItems) .. ""
			self:Save()
			self:LoadConfig()
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

-- TakeDamage = {}
-- TakeDamage.GetFromIDBase = util.GetStaticMethod( RustFirstPass.TakeDamage._type, "GetFromIDBase")
-- TakeDamage.HurtSelfFloat = function( target, val )

	-- local tmpO = util.GetStaticMethod( RustFirstPass.TakeDamage._type, "HurtSelf" )
	-- local HurtSelfFloatMethod = tmpO[3]
	-- local arr = cs.createarrayfromtable( cs.gettype( "System.Object" ), { target, val }, 2 )

	-- cs.convertandsetonarray( arr, 1, val, System.Single._type )

	-- return HurtSelfFloatMethod:Invoke(nil, arr )
-- end

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
ItemTable["WoodDoorFrame(Clone)"] = "Wood Doorway"    -- ?
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

function PLUGIN:OnProcessDamageEvent( takedamage, damage )

	MyHostIsNoMultiplay = true
	
	if takedamage then

		if takedamage.gameObject then

			if takedamage.GetComponent == "GetComponent" then

				plugins.Call( "OnEntityTakeDamage", takedamage.idMain, damage, takedamage.idMain.name)
				return
			end 

			if takedamage.gameObject == "gameObject" then return end
			
			if takedamage.gameObject.Name then

				if ItemTable[takedamage.gameObject.Name] then

					local name = ItemTable[takedamage.gameObject.Name]

					plugins.Call( "OnEntityTakeDamage", takedamage, damage, name )
				end
			end
		end	
	end
end

function PLUGIN:OnHurt( takedamage, damage )

	if MyHostIsNoMultiplay then return end

	if takedamage then

		if takedamage.gameObject then

			if takedamage.GetComponent == "GetComponent" then

				plugins.Call( "OnEntityTakeDamage", takedamage.idMain, damage, takedamage.idMain.name)
				return
			end 

			if takedamage.gameObject == "gameObject" then return end
			
			if takedamage.gameObject.Name then

				if ItemTable[takedamage.gameObject.Name] then

					local name = ItemTable[takedamage.gameObject.Name]

					plugins.Call( "OnEntityTakeDamage", takedamage, damage, name )
				end
			end
		end	
	end
end
varplayer = {}
local GetStructureComponentownerID = util.GetFieldGetter( Rust.StructureMaster, "ownerID", true )
local GetDeployableObjectownerID = util.GetFieldGetter( Rust.DeployableObject, "ownerID", true )
NetCullRemove = util.FindOverloadedMethod( RustFirstPass.NetCull._type, "Destroy", bf.public_static, { UnityEngine.GameObject} )
NetCullRPC = util.GetStaticMethod( RustFirstPass.NetCull._type, "RPC" )
NetEntityID = util.GetStaticMethod( RustFirstPass.NetEntityID._type, "Get" )

function NetEntity(object)

	local NetEntityIDMethod = NetEntityID[0]
	local arr = cs.createarrayfromtable( cs.gettype( "System.Object" ), { object}, 1 )
	cs.convertandsetonarray( arr, 0, object, UnityEngine.GameObject._type )
	return NetEntityIDMethod:Invoke(nil, arr )

end

function RPC(objectid)

	ULINK = nil 
	local _ulinkRPCMode_t = cs.gettype( "uLink.RPCMode, uLink" )
	typesystem.LoadNamespace( "ULINK", "uLink", true )

	RPCmod = ULINK.uLink.RPCMode.OthersBuffered
	
	local RPCMethod = NetCullRPC[21]
	local arr = cs.createarrayfromtable( cs.gettype( "System.Object" ), { objectid, "Client_OnKilled", RPCmod }, 3 )

	cs.convertandsetonarray( arr, 0, objectid, RustFirstPass.NetEntityID._type )
	cs.convertandsetonarray( arr, 1, "Client_OnKilled", System.String._type )
	cs.convertandsetonarray( arr, 2, RPCmod, ULINK.uLink.RPCMode._type )

	return RPCMethod:Invoke(nil, arr )
	
end

IsRemoved= {}

function Remove(object)

	if IsRemoved[object] then return end
	IsRemoved[object] = true
	if object.name == "name" then return end
	if object == "GameObject" then return end
	-- local id = NetEntity(object)
	-- RPC(id)
	
	
	arr = util.ArrayFromTable( cs.gettype( "System.Object" ), { object } )  ;
	cs.convertandsetonarray( arr, 0, object , UnityEngine.GameObject._type )
	NetCullRemove:Invoke( nil, arr )
	
end



function PLUGIN:OnEntityTakeDamage( takedamage, damage , name)

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
	
	if not damage.extraData then return end
	if damage.extraData == "extraData" then return end
	
	if TableActivedRemoveAminAll[steamID] then
		if allow then
			if damage.extraData ~= nil and (damage.extraData:ToString() == "BulletWeaponImpact") or (damage.extraData:ToString() == "WeaponImpact")
			then
				if takedamage.GameObject:GetComponent("StructureComponent") then
					local entity = takedamage.GameObject:GetComponent("StructureComponent")
					if not entity then return end
					for k,v in pairs (GetConnectedComponents(entity._master) ) do
				
						timer.Once(0.5, function()  Remove(v.GameObject) end)
					
					end
				end	
			end
		end  
	end 

	if TableActivedRemoveAmin[steamID] then
		if allow then
	
			if damage.extraData ~= nil and (damage.extraData:ToString() == "BulletWeaponImpact") or (damage.extraData:ToString() == "WeaponImpact")
			then
		
				timer.Once(0.5, function()  Remove(takedamage.GameObject) end)
				return
			end
		end  
	end  
	
	if (takedamage.GameObject:GetComponent("StructureComponent")) then
		entity = takedamage.GameObject:GetComponent("StructureComponent")
		local master = entity._master
		
		if master == "_master" then return end
		if type(master) == "string" then return end
		
		if master then 
		
			local userID = GetStructureComponentownerID(master)
			SteamIdEntity = rust.CommunityIDToSteamID( userID )
		end	
	end
	
	if (takedamage.GameObject:GetComponent("DeployableObject")) then
		entity = takedamage.GameObject:GetComponent("DeployableObject")
	
		
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
			return
		end
		
		if type(entity.GetComponent) == "string" then return end
		
		local userID = GetDeployableObjectownerID(entity)
		SteamIdEntity = rust.CommunityIDToSteamID( userID )
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
					
					timer.Once(0.5, function()  Remove(takedamage.GameObject) end)
				end
			end
		end
	end
end