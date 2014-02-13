PLUGIN.Title = "Teleport User To Coordinates"
PLUGIN.Description = "Teleport user to a specific set of coordinates"
PLUGIN.Author = "Monstrado"

function PLUGIN:Init()
    self.SavedCoordsFile = util.GetDatafile("saved_coords")
	
	flags_plugin = plugins.Find("flags")
		if (not flags_plugin) then
			error("You do not have the Flags plugin installed! Check here: http://forum.rustoxide.com/resources/flags.155/")
			return
		end

		flags_plugin:AddFlagsChatCommand(self, "tpc", {"teleport"}, self.cmdTeleportCoords)
		flags_plugin:AddFlagsChatCommand(self, "tpcs", {"teleport"}, self.cmdSaveCoords)
		flags_plugin:AddFlagsChatCommand(self, "tpcr", {"teleport"}, self.cmdRemoveCoords)
		flags_plugin:AddFlagsChatCommand(self, "tpci", {"teleport"}, self.cmdInfoLocation)
		flags_plugin:AddFlagsChatCommand(self, "tpcl", {"teleport"}, self.cmdListLocation)
		flags_plugin:AddFlagsChatCommand(self, "coords", {}, self.cmdListLocation)


    local json_txt = json.decode(self.SavedCoordsFile:GetText())
    if not json_txt then
        json_txt = {}
    end
    self.SavedCoords = json_txt
end

-- Teleport NetUser to Specific Coordinates
function PLUGIN:TeleportNetuser(netuser, x, y, z)
    local coords = netuser.playerClient.lastKnownPosition
    coords.x = x
    coords.y = y
    coords.z = z
    rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords)
end


function PLUGIN:SaveCoordsFile()
  self.SavedCoordsFile:SetText(json.encode(self.SavedCoords))
  self.SavedCoordsFile:Save()
end

-- Save coordinates by name
-- /tpcs <x> <y> <z> <name>
function PLUGIN:cmdSaveCoords(netuser, args)
    syntax = "Syntax: /tpcs [name] [optional:description]"
    if (#args < 1) then
        rust.Notice(netuser, syntax)
        return
    end
    if not (args[4] or (#args < 3))  then
        rust.Notice(netuser, syntax)
        return
    end
    local coords = {}
    coords.x = tonumber(args[1])
    coords.y = tonumber(args[2])
    coords.z = tonumber(args[3])
    coords.description = args[5] -- optional
    coords.addedBy = netuser.displayName
    local nameOfLocation = args[4]
    if not coords.x or not coords.y or not coords.z then
        -- If they supplied a name only, save their current location.
        if (#args < 3) then
            if self.SavedCoords[args[1]] then
                rust.Notice(netuser, "There's already a coordinate saved with that name")
                return
            end
            local current_coords = netuser.playerClient.lastKnownPosition
            coords.x = current_coords.x
            coords.y = current_coords.y
            coords.z = current_coords.z
            coords.description = args[2] -- optional
            self.SavedCoords[args[1]] = coords
            self:SaveCoordsFile()
            rust.Notice(netuser, "Saved your current position as " .. args[1])
            return
        else
            rust.Notice(netuser, syntax)
        end
    end
    if self.SavedCoords[nameOfLocation] then
        rust.Notice(netuser, "There's already a coordinate saved with that name")
        return
    end
    self.SavedCoords[nameOfLocation] = coords
    self:SaveCoordsFile()
    rust.Notice(netuser, "Saved location " .. nameOfLocation)
end

-- Remove coordinates by name
function PLUGIN:cmdRemoveCoords(netuser, args)
    syntax = "Syntax: /tpcr [name]"
    local nameOfLocation = args[1]
    if not nameOfLocation then
        rust.Notice(netuser, syntax)
        return
    end
    if not self.SavedCoords[nameOfLocation] then
        rust.Notice(netuser, "Location name [" .. nameOfLocation .. "] not found!")
        return
    end
    -- Check if this was added by a user
    local addedBy = self.SavedCoords[nameOfLocation].addedBy
    if addedBy then
        if self.SavedCoords[nameOfLocation].addedBy ~= netuser.displayName then
            rust.Notice(netuser, "You do not have permission to remove this location [Owner: " .. addedBy .. "]")
            return
        end
    end
    self.SavedCoords[nameOfLocation] = nil
    self:SaveCoordsFile()
    rust.Notice(netuser, "Removed " .. nameOfLocation .. " from saved coords")
end 

-- Chat command to teleport user to a set of coordinates
-- /tpc <playername> <x coord> <y coord> <z coord>
function PLUGIN:cmdTeleportCoords(netuser, args) 
    local syntax = "Syntax: /tpc [location] or /tpc [player] [location]"
    if not args[1] then
        rust.Notice(netuser, syntax)
        return
    end
    -- If they only supplied 1 argument, teleport current user to place of name
    if (#args == 1) then
        local location = self.SavedCoords[args[1]]
        if not location then
            rust.Notice(netuser, "Location " .. args[1] .. " not found!")
            return
        end
        if not location.x or not location.y or not location.z then
            rust.Notice(netuser, "Uh oh, that location has bad coordinates associated to it")
            return
        end
        self:TeleportNetuser(netuser, location.x, location.y, location.z)
        rust.Notice(netuser, "Welcome to " .. args[1])
        return
    end 
    local b, targetuser = rust.FindNetUsersByName(args[1])
    if (not b) then
        if (targetuser == 0) then
            rust.Notice(netuser, "No players found with that name!")
        else
            rust.Notice(netuser, "Multiple players found with that name!")
        end
        return
    end
    -- Check if they only supplied two arguments (person and name of location)
    if (#args == 2) then
        local location = self.SavedCoords[args[2]]
        if not location then
            rust.Notice(netuser, "Location " .. args[2] .. " not found!")
            return
        end
        if not location.x or not location.y or not location.z then
            rust.Notice(netuser, "Uh oh, that location has bad coordinates associated to it")
            return
        end
        self:TeleportNetuser(targetuser, location.x, location.y, location.z)
        rust.Notice(targetuser, "Welcome to " .. args[1] .. ", courtesy of " .. netuser.displayName)
        return
    end
end

function PLUGIN:cmdInfoLocation(netuser, args) 
    local nameOfLocation = args[1]
    if not nameOfLocation then
        rust.Notice(netuser, "Syntax: /tpci [name of location]")
        return
    end

    local location = self.SavedCoords[nameOfLocation]
    if not location then
        rust.Notice(netuser, "Location " .. nameOfLocation .. " not found!")
        return
    end
    local description = location.description or "No description"
    local addedBy = location.addedBy or "Unknown"
    local message = nameOfLocation .. ": " .. description .. " (Owner: " .. addedBy .. ")"
    rust.Notice(netuser, message)
end

function PLUGIN:GetSavedCoordsSize() 
    -- There's gotta be an easier way to do this...
    local count = 0
    for _, _ in pairs(self.SavedCoords) do
        count = count + 1
    end
    return count
end

function PLUGIN:cmdListLocations(netuser, locations) 
    if (self:GetSavedCoordsSize() == 0) then
        rust.Notice(netuser, "No locations saved, use /tpcs to add your current location"   )
        return
    end
    rust.RunClientCommand(netuser, "echo ")
    rust.RunClientCommand(netuser, "echo Saved Coordinates:") 
    rust.RunClientCommand(netuser, "echo --------------------")
    for nameOfLocation, coords in pairs(self.SavedCoords) do
        local description = coords.description or "No description"
        local addedBy = coords.addedBy or "Unknown"
        rust.RunClientCommand(netuser, "echo Name: " .. nameOfLocation)
        rust.RunClientCommand(netuser, "echo Description: " .. description)
        rust.RunClientCommand(netuser, "echo Owner: " .. addedBy)
        rust.RunClientCommand(netuser, "echo Location: " .. string.format("{x: %d, y: %d, z: %d}", coords.x, coords.y, coords.z))
        rust.RunClientCommand(netuser, "echo --------------------")
    end
    rust.Notice(netuser, "List of locations sent to rust console (SHIFT+F1)")
end