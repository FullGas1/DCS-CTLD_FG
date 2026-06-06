-- Activate late-activation group heliai_vehicle
local grp = Group.getByName("heliai_vehicle")
if grp then
    trigger.action.activateGroup(grp)
    return "heliai_vehicle ACTIVATED"
else
    return "heliai_vehicle NOT FOUND in mission"
end
