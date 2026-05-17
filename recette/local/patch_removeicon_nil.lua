-- recette/patch_removeicon_nil.lua
-- Fix CTLDReconRenderer.removeIcon crash on nil markId (doRefresh lost-target cleanup)
local _orig = CTLDReconRenderer.removeIcon
CTLDReconRenderer.removeIcon = function(markId)
    if not markId then return end
    _orig(markId)
end
ctld.logInfo("removeIcon nil-guard patched")
return "PATCH OK"
