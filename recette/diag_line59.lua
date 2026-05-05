ctld.debug = true
ctld.utils.log("INFO", "[diag] === LINE-BY-LINE check ===")

ctld.utils.log("INFO", "[diag] L56: TEST_TMPL_NAME = " .. tostring(TEST_TMPL_NAME))
ctld.utils.log("INFO", "[diag] L57: cleanupAll start")

-- Simulate cleanupAll line by line
ctld.utils.log("INFO", "[diag] L58: calling CTLDTroopManager.getInstance()")
local tm = CTLDTroopManager.getInstance()
ctld.utils.log("INFO", "[diag] L59: getInstance returned tm=" .. tostring(tm))

ctld.utils.log("INFO", "[diag] L60: calling CTLDJTACManager.get()")
local jm = CTLDJTACManager.get()
ctld.utils.log("INFO", "[diag] L61: get() returned jm=" .. tostring(jm))

if tm then
    ctld.utils.log("INFO", "[diag] tm._inTransit=" .. tostring(type(tm._inTransit)))
    ctld.utils.log("INFO", "[diag] tm._droppedGroups=" .. tostring(type(tm._droppedGroups)))
    ctld.utils.log("INFO", "[diag] tm._templates count=" .. tostring(#(tm._templates or {})))
end

ctld.utils.log("INFO", "[diag] === DIAG COMPLETE ===")
trigger.action.outText("[diag] Lines 56-61 OK — see CTLD.log", 30)