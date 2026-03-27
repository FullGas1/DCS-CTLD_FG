# CTLD_FG — Instructions permanentes pour Claude Code

## Règles d'échange

- Les échanges se font en **français**.
- Tous les livrables (code, commentaires, specs, documentation) sont en **anglais**.
- Style direct et technique, sans assertions ni formules de politesse.

## Gestion de session

- **Début de session** : toujours récupérer et afficher le contexte mémorisé (mémoire projet, état des tâches, prochaine étape) avant toute autre action.
- **Fin de session** : lorsque l'utilisateur annonce l'arrêt des travaux, mettre à jour **obligatoirement** toutes les mémoires impactées (`project_state.md`, `architecture_decisions.md`, etc.) et confirmer la sauvegarde avant de clore.

## Règles de travail générales

- **Avant tout codage**, soumettre un résumé de compréhension des specs et des choix d'implémentation non triviaux, et attendre la validation explicite de l'utilisateur avant de produire le code.
- **Après chaque création ou modification d'un script**, évaluer si le comportement visible par le mission maker a changé (nouveaux paramètres de config, structure du menu F10, API publique, nouvelle fonctionnalité). Si oui, mettre à jour `documentation/missionmaker_guide.md` dans la même réponse. Les classes purement internes (logic, managers internes, utils) ne déclenchent pas de mise à jour du guide.
- **Ne jamais interpréter ou imaginer une information manquante.** Si une information est absente ou ambiguë, poser la question avant de continuer.
- **Toute utilisation d'une fonction ou d'un objet de l'API DCS officielle doit faire l'objet d'une vérification préalable et détaillée de la documentation Hoggit** : https://wiki.hoggitworld.com/view/Simulator_Scripting_Engine_Documentation — ne jamais supposer qu'un appel API existe ou se comporte d'une certaine façon sans l'avoir vérifié.

## Conventions de développement

- Les fichiers source existants dans `source/` ne doivent **jamais** être modifiés.
- Les nouvelles classes OOP vont exclusivement dans `source_futur/`.
- Seul `ctld.gs("param")` est autorisé pour accéder aux paramètres de config (jamais `config:getSetting()`).
- Utiliser uniquement l'API DCS officielle documentée sur https://wiki.hoggitworld.com/view/Simulator_Scripting_Engine_Documentation
- Le terme "pack" est banni : utiliser "pack" partout (méthodes, config, menus).

## Fin de chaque réponse

Conclure **chaque réponse** par un encadré d'avancement de la consommation de tokens :

```
---
🟢 **Tokens** : ~X k consommés / ~200 k total | ~X% utilisé   (< 80%)
🟠 **Tokens** : ~X k consommés / ~200 k total | ~X% utilisé   (80–90%)
🔴 **Tokens** : ~X k consommés / ~200 k total | ~X% utilisé   (> 90%)
```

Règle de la pastille :
- 🟢 vert  : consommation < 80%
- 🟠 orange : consommation entre 80% et 90%
- 🔴 rouge  : consommation > 90%

> Note : Claude Code n'a pas accès aux compteurs de tokens exacts de l'API.
> La valeur affichée est une estimation basée sur le volume de contexte visible.
> Pour un suivi précis, consulter l'interface de la session Claude.
