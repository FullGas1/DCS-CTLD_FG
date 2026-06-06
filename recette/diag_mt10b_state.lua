local tm = CTLDTroopManager.getInstance()
local u = Unit.getByName("heliai_mt10b")
local hasTr = tm:hasTroops("heliai_mt10b")
local inAir = u and u:isExist() and u:inAir() or false
return "heliai_mt10b: hasTroops=" .. tostring(hasTr) .. " inAir=" .. tostring(inAir)
