# Fiche technique — Adaptation visuelle CinéBook × Majestic Cinéma Bénin

**Type :** spécification de retheming Flutter non fonctionnel  
**Version :** 1.0 — 16 novembre 2026  
**Projet :** [`MohamedF2001/ticket_cine`](https://github.com/MohamedF2001/ticket_cine/tree/feature/modern-ui-overhaul-13985521289131252306)  
**Branche ciblée :** `feature/modern-ui-overhaul-13985521289131252306`  
**Référence publique :** https://www.majesticcinema.bj/  
**Référence graphique principale :** logo Majestic transmis par le propriétaire du projet (`majestic2.png`).

> **Statut : concept visuel non officiel.** Ce document propose une adaptation graphique inspirée de Majestic Cinéma Bénin. Il n'implique ni partenariat, ni autorisation de marque, ni conformité à une charte graphique officielle. Ne pas publier l'app sous l'identité Majestic sans autorisation. Les valeurs chromatiques extraites du logo fourni sont des approximations de travail, pas des tokens officiels.

## 1. Objectif strict

Ajuster **uniquement l'identité visuelle** de CinéBook pour préparer une démonstration ciblée Majestic. Conserver la structure, la navigation, les écrans, les noms des modèles, les services, l'état applicatif, les appels réseau, l'authentification, le processus de réservation, la sélection des sièges, les fichiers PDF, le scan et les dépendances actuelles. **Aucune nouvelle fonctionnalité, refonte, migration ou modification du backend.**

**Résultat attendu :** une application toujours identifiable comme CinéBook, avec un thème « Majestic-inspired » réversible : noir cinéma, rouge profond, blanc contrasté et gris graphite, sans surcharge d'effets.

## 2. Observations contrôlées et recommandations

- **Logo transmis :** fond noir, monogramme blanc et graphite, mot `MAJESTIC` rouge sombre et `CINÉMA` blanc. Relevé approximatif sur l'image : rouge `#B72126` (183,33,38), graphite `#4C4D4F` (76,77,79), blanc `#FFFFFF`, noir `#000000`.
- **Site public :** présente l'enseigne, les sites Marina et Wologuèdè et une entrée « Billetterie ». Cette observation n'est pas une extraction de charte graphique CSS officielle.
- **Branche GitHub examinée :** `lib/theme/app_theme.dart` emploie déjà un thème sombre (`#121212`, `#1E1E1E`), un rouge vif (`#E50914`), Poppins et des composants Material 3. Il s'agit donc d'un ajustement ciblé, pas d'une reconstruction.
- **Décision de design :** utiliser le rouge plus profond du logo pour les actions et l'accentuation, réserver le noir au fond, garder le blanc pour les informations importantes et le graphite pour les éléments secondaires.

## 3. Palette proposée

| Token sémantique | Hex | Usage | Origine |
|---|---|---|---|
| `backgroundColor` | `#09090B` | Fond principal, ambiance salle obscure | proposition |
| `surfaceColor` | `#171719` | AppBar, champs, panneaux | proposition |
| `cardColor` | `#202023` | Cartes films, tarifs et billets à l'écran | proposition |
| `primaryColor` | `#B72126` | CTA principal, état sélectionné, actions | approximation du logo |
| `accentColor` | `#D3373E` | Accent plus lisible sur fonds très sombres, focus | proposition dérivée |
| `primaryPressed` | `#921B20` | État pressé du CTA | proposition |
| `textPrimary` | `#FFFFFF` | Titres, tarifs, CTA | logo |
| `textSecondary` | `#C4C4C7` | Informations secondaires | proposition accessible |
| `outlineColor` | `#4C4D4F` | Séparateurs, bordures, surfaces inactives | approximation du logo |
| `disabledColor` | `#66666A` | Éléments indisponibles | proposition |
| `errorColor` | `#F07178` | Erreurs (séparé du rouge de marque) | proposition |
| `successColor` | `#39B77C` | Confirmation métier, succès uniquement | proposition |
| `seatAvailable` | `#343438` | Siège disponible | proposition |
| `seatSelected` | `#B72126` | Siège choisi | approximation du logo |
| `seatReserved` | `#737379` | Siège déjà réservé | proposition |

**Règles :** ne pas utiliser le rouge de marque pour signifier automatiquement une erreur ; ne pas afficher du texte rouge `#B72126` de petite taille sur fond noir sans vérification de contraste. Pour les textes secondaires, utiliser `#C4C4C7` plutôt que le graphite de logo. Contrôler le contraste WCAG AA : ≥ 4,5:1 pour le texte courant et ≥ 3:1 pour les éléments graphiques indispensables.

## 4. Typographie et volumes

Garder **Poppins**, déjà présent dans `app_theme.dart` : aucune nouvelle police requise. Préserver la hiérarchie et les tailles existantes. Autoriser seulement des retouches mineures de graisse, contraste, espacement et fond d'écran. Conserver les rayons actuels (cartes 16 px, CTA 12 px), la logique glassmorphism existante et les animations existantes, en réduisant éventuellement l'intensité des halos rouges si nécessaire.

**Ne pas** introduire de gradient rouge agressif sur chaque carte, d'ombres néon, d'animation supplémentaire, de navigation différente ou d'éléments publicitaires Majestic non demandés.

## 5. Cibles Flutter vérifiées dans la branche

### Niveau P0 — centralisation

**`lib/theme/app_theme.dart`** : point d'entrée principal. Modifier seulement les constantes de couleur, dégradés associés et les propriétés couleurs des thèmes `ThemeData`, `ColorScheme`, `AppBarTheme`, `ElevatedButtonThemeData`, `InputDecorationTheme`, `BottomNavigationBarThemeData`, `CardThemeData`. Conserver les noms publics de constantes et la forme de `darkTheme` afin de ne pas casser les importations existantes. Ajouter les tokens sémantiques manquants uniquement si utilisés par des écrans ; pas de refactor architectural.

### Niveau P1 — écrans prioritaires

| Fichier existant | Ajustement visuel seulement |
|---|---|
| `lib/views/main/home_navigation_screen.dart` | Remplacer les couleurs locales `Colors.black`, `Colors.red`, `Colors.white70` pour la barre du bas par les tokens AppTheme ; conserver 4 onglets, `IndexedStack`, interactions et icônes |
| `lib/views/main/movie_screen.dart` et `lib/views/main/movie_details_screen.dart` | Fonds, badges et CTA cohérents ; préserver affiches et métadonnées |
| `lib/views/main/sessions_screen.dart` | Cartes séances, heures et disponibilité lisibles ; aucun changement de filtrage |
| `lib/views/main/seat_selection_screen.dart` | Couleurs des sièges et de la légende ; préserver `_selectedSeat`, `_reservedSeats`, grille et réservation |
| `lib/views/main/reservation_screen.dart` | Cartes de réservations et états visuels, sans changement de requêtes |
| `lib/views/le_ticket.dart` | Harmonisation de l'aperçu du billet numérique ; préserver données, identifiants et logique de scan/export |
| `lib/views/auth/login_screen.dart`, `register_screen.dart` | Champs, focus, CTA, liens et arrière-plans ; ne pas toucher aux validations/authentification |
| `lib/views/splash_screen_new.dart` et `onboarding_screen.dart` | Fond, accent rouge, éventuelle mention « concept de démonstration » hors parcours principal ; ne pas modifier la temporisation/navigation |

**Autres écrans/widgets** : rechercher toutes les occurrences de `Colors.red`, `Colors.blue`, `Colors.black`, `Color(0xFF...)` et dégradés codés en dur, puis remplacer **seulement les couleurs de décoration** qui relèvent de la marque. Ne pas remplacer les couleurs sémantiques succès/erreur, couleurs d'affiches ou éléments obligatoires de formats (ex. code-barres).

### Niveau P2 — éléments hors parcours visuel actif

`lib/the_app.dart` contient aussi des éléments de navigation avec bleu/gris mais semble être un parcours alternatif avec `Placeholder`. Ne l'ajuster que si cette classe est réellement utilisée ; ne pas modifier sa navigation.

## 6. Logo et identité

- Garder **CinéBook** comme nom de produit et titre applicatif lors de cette démonstration.
- Pour une **maquette de partenariat autorisée**, le logo Majestic peut être affiché comme **référence du partenaire** dans un espace défini ; ne jamais le remplacer automatiquement partout ni supprimer le logo CinéBook sans validation.
- Ajouter l'asset Majestic seulement si le fichier source fourni est disponible dans le projet et si sa réutilisation est autorisée. Prévoir un nom tel que `assets/images/majestic_partner_logo.png`, déclaré dans `pubspec.yaml` seulement si nécessaire.
- Respecter les proportions du monogramme, son fond noir, l'espace de respiration et les couleurs d'origine. Pas de filtre rouge sur le logo ni de fond blanc imposé.
- Éviter toute formulation laissant croire à une **application officielle Majestic** ; utiliser « Concept CinéBook — proposition d'adaptation visuelle » dans les supports de présentation.

## 7. Billet PDF et code-barres : traitement prudent

Dans `lib/views/le_ticket.dart`, la génération PDF s'appuie notamment sur `pw.Document`, `pw.BarcodeWidget`, les données de réservation et les champs film/date/heure/salle/siège. Le PDF existant est majoritairement clair pour la lisibilité. **Ne pas transformer le document en billet noir intégral** : conserver un fond clair ou blanc pour la zone imprimable et un code-barres noir sur blanc, nécessaire au contraste de scan. Une fine bande rouge, un titre et des séparateurs graphite peuvent éventuellement suffire, à condition de ne pas modifier géométrie, identifiant, données, format ou scanner. Toute modification de génération PDF doit rester facultative dans cette phase ; priorité à l'écran.

## 8. Proposition de tokens Dart (indicative, pas un remplacement complet du fichier)

```dart
// À intégrer avec précaution dans la classe AppTheme existante.
static const Color backgroundColor = Color(0xFF09090B);
static const Color surfaceColor = Color(0xFF171719);
static const Color cardColor = Color(0xFF202023);
static const Color primaryColor = Color(0xFFB72126);
static const Color accentColor = Color(0xFFD3373E);
static const Color textPrimary = Color(0xFFFFFFFF);
static const Color textSecondary = Color(0xFFC4C4C7);
static const Color outlineColor = Color(0xFF4C4D4F);
static const Color seatAvailable = Color(0xFF343438);
static const Color seatSelected = Color(0xFFB72126);
static const Color seatReserved = Color(0xFF737379);

static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFB72126), Color(0xFF921B20)],
);
```

Ne pas recopier ce bloc en doublon : **remplacer les définitions existantes** et vérifier les éventuels `const` widgets qui les consomment. Répercuter les tokens correspondants dans les décorations du `ThemeData` déjà présent.

## 9. Plan d'application minimal

1. Créer une branche de démonstration à partir de `feature/modern-ui-overhaul-13985521289131252306`, ou travailler localement sans écraser la branche existante.
2. Photographier/capturer les états actuels de l'accueil, détails film, séances, sélection des sièges, réservations, billets et authentification.
3. Mettre à jour `lib/theme/app_theme.dart` sans modifier ses signatures publiques.
4. Remplacer les couleurs de marque codées en dur dans les écrans actifs, écran par écran, sans toucher aux fonctionnalités.
5. Vérifier les états normal, chargement, focus, inactif, sélectionné, réservé, succès et erreur. Ne pas associer rouge de marque et erreur métier.
6. Tester la lecture du ticket PDF et du code-barres avec le lecteur actuel, sans changer la payload.
7. Exécuter `dart format` sur les fichiers Dart touchés, puis `flutter analyze` et les tests existants, avant une vérification manuelle Android/iOS sur les principaux écrans.
8. Comparer les captures avant/après. Refuser toute modification involontaire de navigation, layout, requêtes, modèles, endpoints, textes métier ou prix.

## 10. Critères d'acceptation

- [ ] L'interface utilise harmonieusement noir, rouge Majestic approximatif, blanc et graphite.
- [ ] Les contrastes et états interactifs restent compréhensibles.
- [ ] L'accueil, les séances, les sièges, le billet et l'authentification restent utilisables.
- [ ] Les choix de siège et les couleurs « disponible/réservé/sélectionné » sont clairement distinguables, y compris par la légende.
- [ ] Les affiches, images de films et leurs couleurs d'origine sont inchangées.
- [ ] Aucune logique de réservation, authentification, paiement, API, modèle ou PDF scannable n'est cassée.
- [ ] Aucune nouvelle dépendance ou modification backend n'est introduite.
- [ ] Le branding est présenté comme **concept non officiel**, sauf accord explicite de Majestic.
- [ ] Le diff final se limite aux couleurs, styles, assets autorisés et déclarations nécessaires.

## 11. Instruction prête à donner à un assistant de code

> Travaille sur la branche `feature/modern-ui-overhaul-13985521289131252306` du dépôt `MohamedF2001/ticket_cine`. Lis cette fiche dans son intégralité, puis inspecte la structure et le code existant avant toute modification. Réalise **exclusivement** une adaptation de thème visuel inspirée du logo Majestic fourni, sans modifier le comportement, les écrans, la navigation, la logique métier, les services, les appels réseau, les modèles, la billetterie PDF ou le backend. Commence par `lib/theme/app_theme.dart`, puis corrige les couleurs de marque hardcodées dans les écrans réellement actifs. Conserve les noms publics de `AppTheme`, Poppins, la disposition et les animations. Ne présente pas le produit comme officiel Majestic. À la fin, donne la liste exacte des fichiers changés et les résultats de `flutter analyze`/tests. Aucun changement hors thème ne doit être commité.

---

**Références inspectées :** logo `majestic2.png` fourni ; site public `https://www.majesticcinema.bj/` ; GitHub (branche indiquée), notamment `lib/theme/app_theme.dart`, `lib/views/main/home_navigation_screen.dart`, `lib/views/main/seat_selection_screen.dart`, `lib/views/le_ticket.dart` et `lib/views/splash_screen_new.dart`.
