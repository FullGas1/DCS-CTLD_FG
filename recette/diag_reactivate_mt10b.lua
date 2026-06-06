local grp = Group.getByName("heliai_mt10b")
if not grp then return "heliai_mt10b not found" end
grp:activate()
return "heliai_mt10b reactivated"
