-- recette/reset_idx.lua
-- Reset scenario index to 1 after mission restart
_RECON_LAYER_IDX = 1
trigger.action.outText("[RECON] Index reset to 1. Inject scenario to start from layer 1.", 15)
env.info("[reset_idx] _RECON_LAYER_IDX reset to 1")
return "RESET OK — idx=1"
