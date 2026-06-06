-- Force heliai_mt10b to land at AIZ_depot_B_P_T_10 then AIZ_mt10d_B_D_G
local zm  = CTLDZoneManager.getInstance()
local zP  = zm._troopZones["AIZ_depot_B_P_T_10"]
local zD  = zm._troopZones["AIZ_mt10d_B_D_G"]
if not zP then return "AIZ_P not found" end
if not zD then return "AIZ_D not found" end

local grp = Group.getByName("heliai_mt10b")
if not grp then return "heliai_mt10b not found" end

local cP = zP:getCenter()
local cD = zD:getCenter()

local function makeWP(pt, action)
    local h = land.getHeight({ x = pt.x, y = pt.z })
    return {
        x           = pt.x,
        y           = h,
        alt         = h,
        alt_type    = "BARO",
        speed       = 50,
        action      = action or "Landing",
        type        = "Land",
        ETA         = 0,
        ETA_locked  = false,
        speed_locked = true,
    }
end

local wpPickup = makeWP(cP, "Landing")
local wpDrop   = makeWP(cD, "Landing")

local ctrl = grp:getController()
ctrl:setTask({
    id = "Mission",
    params = {
        route = {
            points = { wpPickup, wpDrop }
        }
    }
})
return "heliai_mt10b redirected: pickup->drop"
