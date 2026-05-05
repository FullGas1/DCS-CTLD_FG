-- recette/sandbox_msg.lua — display sandbox instructions on DCS screen
trigger.action.outText(
    "=== RECON SANDBOX ===\n"..
    "6 menaces actives (infantry, vehicule, AA, avion, helo, bateau)\n"..
    "Tous les layers actifs — RECON demarre\n\n"..
    "TEST : menu F10 > CTLD > RECON\n"..
    "  - Toggle chaque layer [activate/deactivate]\n"..
    "  - Verifier disparition/apparition des icones sur map\n"..
    "  - RECON [Stop] puis [Start] = cycle complet\n\n"..
    "Re-injecter scenario_recon_layers.lua pour RESET.", 60)
return "sandbox instructions displayed"
