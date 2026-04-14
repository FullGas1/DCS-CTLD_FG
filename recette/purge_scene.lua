---@diagnostic disable
-- ============================================================
-- recette/purge_scene.lua
-- Purge all CTLD scene objects spawned by F-90 / F-91 / F-92.
-- Run this before any new scene visual test to get a clean slate.
-- Safe to run multiple times.
-- ============================================================

local destroyed = 0

-- Static objects by namePrefix pattern (coalition.addStaticObject)
local staticPrefixes = {
    "SINGLE_HELIPAD",
    "FARP_Helipad",
    "FARP_Tent",
    "FARP_Ammo_Storage",
    "Windsock",
    "FOB_Outpost",
    "FOB_Watchtower",
    "barrels_cargo",
    "ammo_box_cargo",
    "ammo_box06",
    "carrier_shooter",
    "NF-2_LightOn",
    "TowerCrane",
}

-- Ground groups by namePrefix (coalition.addGroup)
local groupPrefixes = {
    "Fuel_Truck_Grp",
    "repare_Truck_Grp",
    "FARP_Guard_Grp",
    "CTLDBeacon",
}

-- Scan IDs 1..5000 for each prefix
local MAX_ID = 5000

for _, prefix in ipairs(staticPrefixes) do
    for i = 1, MAX_ID do
        local name = prefix .. "-" .. i
        local obj  = StaticObject.getByName(name)
        if obj and obj:isExist() then
            obj:destroy()
            destroyed = destroyed + 1
        end
    end
end

for _, prefix in ipairs(groupPrefixes) do
    for i = 1, MAX_ID do
        local name = prefix .. "-" .. i
        local grp  = Group.getByName(name)
        if grp then
            grp:destroy()
            destroyed = destroyed + 1
        end
    end
end

-- Also clear the saved-names global so next test starts clean
_CTLD_SCENE_LAST_SPAWNED = {}

local msg = string.format("PURGE SCENE: %d object(s) destroyed.", destroyed)
trigger.action.outText(msg, 10)
env.info("[CTLD_PURGE] " .. msg)
