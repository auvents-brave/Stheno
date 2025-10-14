# Liste des tâches identifiées lors de la revue

> Ce document recense les suivis à traiter pour finaliser la revue précédente. Chaque action peut être suivie indépendamment dans l'outil de ticketing du projet.

## 1. Corriger une coquille typographique dans la documentation
- **Chemin** : `README.md`
- **Constat** : le texte alternatif du badge de plateformes affiche "latforms" au lieu de "Platforms".
- **Impact** : la section badges du README perd en crédibilité et la faute peut se propager dans les sites qui réutilisent ce badge.
- **Action proposée** : mettre à jour le texte alternatif du badge pour afficher "Platforms".

## 2. Corriger le comportement initial de `Throttled`
- **Chemin** : `Sources/RabFoundation/Throttled.swift`
- **Constat** : l'initialiseur fixe `lastSet` à `Date()`, ce qui bloque la première réaffectation immédiate alors qu'elle devrait être acceptée.
- **Impact** : les appels qui attendent un déclenchement instantané après la création du throttler sont ignorés.
- **Action proposée** : initialiser `lastSet` à `.distantPast` (ou lever la contrainte lors de la première écriture) afin que la première mise à jour soit publiée.

## 3. Corriger un commentaire inexact sur le format ISO 8601
- **Chemin** : `Sources/RabFoundation/Date+UTC.swift`
- **Constat** : un commentaire mentionne "onbly" et "usefull" au lieu de "only" et "useful".
- **Impact** : la documentation interne perd en clarté et donne une impression de manque de rigueur.
- **Action proposée** : corriger l'orthographe du commentaire pour refléter le texte attendu.

## 4. Renforcer le test de throttling asynchrone
- **Chemin** : `Tests/RabFoundationTests/Throttled.Tests.swift`
- **Constat** : aucun test ne vérifie que la valeur est effectivement publiée après expiration de l'intervalle de throttling.
- **Impact** : un bug qui empêcherait la remise à jour après l'attente ne serait pas détecté.
- **Action proposée** : ajouter un test asynchrone qui attend la durée du throttling (via `Task.sleep`) et confirme que la nouvelle valeur est émise après l'intervalle.
