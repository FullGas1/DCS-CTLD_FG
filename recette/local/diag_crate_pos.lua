local mgr = CTLDCrateManager.getInstance()
local t = Unit.getByName("Batumi_UH-1H_0-1")
if not (t and t:isExist()) then
    ctld.utils.log("INFO", "diag_crate_pos: Batumi_UH-1H_0-1 not found")
    return
end
local tPos = t:getPoint()
ctld.utils.log("INFO", string.format("transport=%s pos={%.1f,%.1f,%.1f}", t:getName(), tPos.x, tPos.y, tPos.z))
local near = mgr:getCratesInRange(tPos, 200)
ctld.utils.log("INFO", string.format("crates in 200m: %d", #near))
for _, c in ipairs(near) do
    local pos = c.dcsStatic and c.dcsStatic:isExist() and c.dcsStatic:getPoint() or c.position
    local d = ctld.utils.getDistance("diag", tPos, pos)
    ctld.utils.log("INFO", string.format("CRATE %s desc=%s pos={%.1f,%.1f,%.1f} dcsStatic:isExist=%s d=%.1fm",
        c.crateName, c.descriptor and c.descriptor.desc or "nil", pos.x, pos.y, pos.z,
        tostring(c.dcsStatic and c.dcsStatic:isExist()), d))
end
ctld.utils.log("INFO", "diag_crate_pos: done")