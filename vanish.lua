--Plugin Created By ReTric
PLUGIN.Title = "Vanish"
PLUGIN.Description = "Spawns Invisible Armor in slots"
PLUGIN.Version = "1.2"


function PLUGIN:Init()

 flags_plugin = plugins.Find("flags")
  if (not flags_plugin) then
  error("You do not have the Flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155/")
  return
 end

flags_plugin:AddFlagsChatCommand(self, "vanish", {"vanish"}, self.cmdOn)
flags_plugin:AddFlagsChatCommand(self, "unvanish", {"vanish"}, self.cmdOff)

end

function PLUGIN:cmdOn( netuser, cmd, args )
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
end

function PLUGIN:cmdOff( netuser, cmd, args )
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
end
