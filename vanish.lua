--Plugin Created By ReTric
PLUGIN.Title = "Vanish"
PLUGIN.Description = "Spawns Invisible Armor in slots"
PLUGIN.Version = "1.2"


function PLUGIN:Init()
 self:AddChatCommand( "vanish", self.cmdOn )
 self:AddChatCommand( "unvanish", self.cmdOff )
 self:AddChatCommand( "vanishdev", self.cmdAbout )

  	oxmin_Plugin = plugins.Find("oxmin")

    if not oxmin_Plugin or not oxmin then
        print("Vanish Flag Not Added! Requires Oxmin")
        self.oxminInstalled = false
        return;
    end;

    self.FLAG_VANISH = oxmin.AddFlag("vanish")
    self.oxminInstalled = true
	print("Flag Vanish successfully added!")
end

function PLUGIN:cmdOn( netuser, cmd, args )
if (netuser:CanAdmin()) or (oxmin_Plugin:HasFlag(netuser, self.FLAG_VANISH, false)) then
	local helmet = rust.GetDatablockByName( "Invisible Helmet" )
	local vest = rust.GetDatablockByName( "Invisible Vest" )
	local pants = rust.GetDatablockByName( "Invisible Pants" )
	local boots = rust.GetDatablockByName( "Invisible Boots" )
	local pref = rust.InventorySlotPreference( InventorySlotKind.Armor, false, InventorySlotKindFlags.Armor )
	local inv = netuser.playerClient.rootControllable.idMain:GetComponent( "Inventory" )
	inv:AddItemAmount( helmet, 1, pref )
	inv:AddItemAmount( vest, 1, pref )
	inv:AddItemAmount( pants, 1, pref )
	inv:AddItemAmount( boots, 1, pref )
	rust.Notice( netuser, "You have vanished!" )
else
	rust.Notice( netuser, "You must be an admin to use that command!" )
end
end

function PLUGIN:cmdOff( netuser, cmd, args )
if (netuser:CanAdmin()) or (oxmin_Plugin:HasFlag(netuser, self.FLAG_VANISH, false)) then
	local helmet = rust.GetDatablockByName( "Invisible Helmet" )
	local vest = rust.GetDatablockByName( "Invisible Vest" )
	local pants = rust.GetDatablockByName( "Invisible Pants" )
	local boots = rust.GetDatablockByName( "Invisible Boots" )
	local inv = netuser.playerClient.rootControllable.idMain:GetComponent( "Inventory" )
	local item1 = inv:FindItem(helmet)
	local item2 = inv:FindItem(vest)
	local item3 = inv:FindItem(pants)
	local item4 = inv:FindItem(boots)
	inv:RemoveItem( item1 )
	inv:RemoveItem( item2 )
	inv:RemoveItem( item3 )
	inv:RemoveItem( item4 )
	rust.Notice( netuser, "You have been made visible again!" )
else
	rust.Notice( netuser, "You must be an admin to use that command!" )
end
end
