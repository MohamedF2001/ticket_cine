# Brag Plan: CinéBook

## What is this app?
CinéBook est une application mobile Flutter qui permet de parcourir les films à l'affiche, choisir sa séance, sélectionner son siège, et obtenir un ticket digital avec QR code et code-barres — le tout sans impression ni file d'attente.

## The angle
Un teaser cinématographique French Touch — Apple keynote rencontre le cinéma français. Le téléphone émerge de l'obscurité comme un objet précieux. L'interface du ticket apparaît avec une élégance lumineuse. Le ticket digital flotte en 3D comme un artefact de luxe. La voix-off française guide la narration, posée et chaleureuse. Mouvement de caméra continu, plans larges et macros intimes.

## Hook (first 2-3 seconds)
Noir total. Une fine lumière dessine la silhouette d'un smartphone qui émerge de l'obscurité, tournant lentement. L'écran s'allume d'une impulsion douce. Une voix-off commence : « Et si votre cinéma tenait dans une seule application ? »

## Key moments (the middle)
- Le ticket se construit élément par élément : affiche du film, titre, date, heure, salle, numéro de siège, code-barres, QR code
- Macro sur le QR code avec une ligne de scan lumineuse qui le parcourt
- Le ticket se détache du téléphone, flotte et tourne à 360° dans l'espace
- Le PDF se déplie comme un papier depuis sa pliure centrale
- Le téléphone se centre, logo CinéBook, tagline « Book. Scan. Enjoy. »

## Outro / punchline
Téléphone centré, rotation lente. Le logo CinéBook apparaît. En dessous, « Book. Scan. Enjoy. » s'écrit lettre par lettre. Une lueur rouge (#E50914) pulse derrière. Fade to black avec halo chaleureux.

## User flow worth showing
Parcourir → Choisir une séance → Sélectionner un siège → Obtenir le ticket digital → Scanner à l'entrée. Le ticket est le climax — la vidéo centre le ticket comme la récompense finale.

## Tone
- Preset: cinematic
- Creative direction: teaser Apple keynote / film commercial français haut de gamme
- Interpretation: Épique, lent, délibéré. Plans larges du téléphone dans l'obscurité. Macros intimes sur les détails du ticket. Typographie propre en Poppins. Crossfades lents avec scale. La voix-off féminine ou masculine grave guide la narration. La musique enfle au logo final.

## Format: landscape — 1920x1080
## Duration: 22 seconds

## Visual identity (from the project)
- Background: #121212 (dark cinema black)
- Background gradient: #121212 → #1A1A1A → #121212
- Text: #FFFFFF (white)
- Secondary text: #B3B3B3
- Accent: #E50914 (CinéBook red)
- Glass: rgba(255,255,255,0.1) with rgba(255,255,255,0.2) border
- Card surface: #1E1E1E with gradient #2A2A2A → #1E1E1E
- Display font: Poppins Bold
- Body font: Poppins Regular
- Strongest visual element: Le ticket blanc avec bords crantés (TicketClipper), affiche du film, code-barres (code128), QR code, infos séance en rouge sur fond sombre

## Share copy (draft)
CinéBook — Book. Scan. Enjoy. Votre cinéma au bout des doigts. 🎬

## Voiceover script
```
[Scène 1 — 0s-3s]
Et si votre cinéma tenait dans une seule application ?

[Scène 2 — 3s-7.5s]
CinéBook. Parcourir les films, choisir votre séance, réserver votre place.

[Scène 3 — 7.5s-11.5s]
Votre ticket digital, généré en un instant. Élégant. Sécurisé. Prêt à l'emploi.

[Scène 4 — 11.5s-16s]
Fini les files d'attente. Fini les billets perdus.

[Scène 5 — 16s-20s]
Votre place est sur votre téléphone. Et toujours accessible, même hors ligne.

[Scène 6 — 20s-22s]
CinéBook. Book. Scan. Enjoy.
```

## Audio direction
- Role: cinematic voice-led — la voix-off guide, la musique soutient
- Music: `happy-beats-business-moves-vol-12-by-ende-dot-app.mp3` — steady and clean, parfait pour polished/cinematic
- Music treatment: Fade-in sur les 2 premières secondes à 0.25 volume. Maintenir à 0.25 pendant la voix-off. Swell subtil à 18s pour le logo. Fade-out sur les 2 dernières secondes.
- Music cue guidance: Bundled preset available at `assets/music/cues/happy-beats-business-moves-vol-12-by-ende-dot-app.music-cues.json`. Strong cues: 8.74s (0.99), 17.47s (0.99), 22.37s (0.98), 22.93s (1.00). Beat grid at ~1.09s intervals from 0.56s.
- Audio-reactive treatment: subtle; use music RMS to make the phone edge glow and ticket card presence breathe. No waveform/equalizer visuals.
- SFX posture: 3 SFX max, cinématiques et discrets. Un pulse doux à l'allumage de l'écran, une cloche résonante quand le ticket se détache, un hit pour le logo final.
- Audio-coupled moments:
  - Scene 1 — screen power-on glow at ~2.5s synced to 2.73s beat
  - Scene 4 — ticket lift-off at ~10.5s aligned to 10.93s strong cue
  - Scene 6 — logo reveal at ~22.37s strong cue
- Restraint rule: Pas plus de 3 SFX. La voix-off et la musique portent le poids émotionnel.

## Storyboard

### Scene 1 — Émergence — 3.0s
Noir total. Une fine lumière dessine la silhouette du téléphone. Le téléphone tourne lentement d'une perspective 3D (~30° Y) à centré. L'écran est noir. À 2.5s, pulse lumineux — l'écran s'allume sur l'interface CinéBook.
**Texte apparaissant :** aucun (voix-off seulement)
**VO :** « Et si votre cinéma tenait dans une seule application ? »
**Séquentiel/interaction :** non — un seul mouvement caméra continu
**Audio intent :** Anticipation silencieuse. La musique commence à fade-in.
**Audio-coupled idea :** Pulse d'allumage à 2.5s synchronisé sur le beat à 2.73s
**Transition :** crossfade dramatique (0.6s) → Scène 2

### Scene 2 — Révélation du ticket — 4.5s
Le ticket est affiché sur l'écran. Le téléphone penche doucement (Y -5° à +5°). Les éléments apparaissent séquentiellement : affiche du film glisse du haut (0.3s), titre du film fade in (0.7s), DATE glisse de gauche (1.0s), HEURE de droite (1.0s), SALLE (1.4s), SIÈGE (1.8s). À 2.5s, le code-barres s'anime de gauche à droite avec un glow subtil. À 3.5s, le QR code apparaît avec une ligne de scan lumineuse.
**VO :** « CinéBook. Parcourir les films, choisir votre séance, réserver votre place. »
**Séquentiel/interaction :** oui — le ticket se construit élément par élément sur 3.5s
**Audio intent :** Merveille douce. Chaque arrivée est précise et légère.
**Audio-coupled idea :** Éléments du ticket révélés tous les 2 beats (~2.18s)
**Transition :** crossfade doux avec léger zoom avant (0.5s) → Scène 3

### Scene 3 — Macro QR Code — 4.0s
La caméra zoome en macro sur le QR code. Une ligne de scan lumineuse descend sur le QR (0-1.2s). La caméra orbite doucement vers le code-barres (1.2-2.8s). Recul pour révéler le ticket complet — bords crantés, affiche, séance, siège, prix. Particules lumineuses subtiles flottent autour des bords.
**VO :** « Votre ticket digital, généré en un instant. Élégant. Sécurisé. Prêt à l'emploi. »
**Séquentiel/interaction :** oui — scan QR, orbite code-barres, recul ticket complet
**Audio intent :** Intime, raffiné. Détail de près.
**Audio-coupled idea :** Scan QR synchronisé sur le strong cue à 8.74s
**Transition :** crossfade dramatique lent avec scale (0.6s) → Scène 4

### Scene 4 — Ticket en lévitation — 4.5s
Le ticket se détache de l'écran du téléphone et s'élève. Il tourne lentement en 3D — vue face (0-2s), rotation pour révéler le dos avec le code-barres (2-3.5s), retour face (3.5-4.5s). Ombre portée subtile en dessous. Particules dorées et bleues autour des bords. Le téléphone s'assombrit à l'arrière-plan.
**VO :** « Fini les files d'attente. Fini les billets perdus. »
**Séquentiel/interaction :** oui — rotation 360° continue du ticket
**Audio intent :** Magique. Le ticket comme artefact précieux.
**Audio-coupled idea :** Détachement du ticket à ~10.5s aligné sur le strong cue à 10.93s
**Transition :** wipe dramatique (0.4s) → Scène 5

### Scene 5 — Déploiement PDF — 4.0s
Le ticket retourne dans le téléphone. L'écran passe en mode PDF — le ticket apparaît comme un document papier qui se déplie depuis le centre (0-1.5s). Le PDF complet est visible avec tous les détails. Le téléphone penche doucement, puis la vue revient à l'interface ticket de l'app.
**VO :** « Votre place est sur votre téléphone. Et toujours accessible, même hors ligne. »
**Séquentiel/interaction :** oui — PDF se déplie depuis le centre comme du papier
**Audio intent :** Résolution chaleureuse. Accomplissement.
**Audio-coupled idea :** Déploiement PDF aligné sur le strong cue à 17.47s
**Transition :** crossfade doux (0.5s) → Scène 6

### Scene 6 — Outro — 2.0s
Téléphone centré dans le cadre, rotation Y lente et douce. Le logo CinéBook apparaît en dessous du téléphone (0.3s). En dessous, « Book. Scan. Enjoy. » s'écrit lettre par lettre (0.5-1.5s). Une lueur rouge douce (#E50914) pulse derrière le téléphone. Tout tient 0.3s, puis fade to black avec halo chaleureux.
**VO :** « CinéBook. Book. Scan. Enjoy. »
**Séquentiel/interaction :** oui — logo apparaît, tagline s'écrit
**Audio intent :** Résolution finale. Swell musical, logo hit, silence.
**Audio-coupled idea :** Logo reveal sur le strong cue à 22.37s
**Transition :** fade to black avec lueur douce

**Music mood for this video:** Cinématique, posé, chaleureux — vol-12 à 0.25 volume, swell discret sur l'outro
**Audio summary:** Commence calme, construit progressivement, culminé sur le logo, puis silence.
