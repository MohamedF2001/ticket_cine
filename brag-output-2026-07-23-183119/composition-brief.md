# Hyperframes Composition Brief: CinéBook

## Objective
Create a short launch-style brag video for CinéBook — a premium cinematic product reveal showcasing the digital cinema ticket experience, inspired by Apple keynote product videos. Narration is in French (voiceover will be added separately).

## Output
- Composition directory: `brag-output-2026-07-23-183119/composition/`
- Rendered video: `brag-output-2026-07-23-183119/brag.mp4`
- Format: landscape — 1920x1080
- Duration: 22 seconds

## Source Material
- Project root: `C:\Users\frdmo\StudioProjects\ticket_cine`
- Primary files read: `lib/views/le_ticket.dart` (ticket card with TicketClipper, barcode code128, QR code, movie poster), `lib/theme/app_theme.dart` (colors, gradients, glassmorphism), `lib/views/seat_select.dart` (seat selection UI)
- Product name: CinéBook
- Tagline / strongest claim: "Book. Scan. Enjoy." / "Votre cinéma au bout des doigts"
- Key UI or visual moment to recreate: The white ticket card with clipped edges (TicketClipper), movie poster image, barcode (code128), QR code, session info labels (DATE, HEURE, SALLE, SIÈGE), red accent #E50914 on dark background
- Copy that must appear verbatim:
  - "CinéBook"
  - "Book. Scan. Enjoy."
  - "DATE" / "HEURE" / "SALLE" / "SIÈGE" (on ticket labels)

## Creative Direction
- Tone preset: cinematic
- Creative direction: Apple keynote product reveal / French luxury mobile app commercial
- Interpretation: Epic, deliberate pacing. Wide shots of the phone in darkness with edge lighting. Intimate macro close-ups of the ticket. Full-bleed product moments. Clean mixed-case typography (Poppins). Transitions are slow crossfades with scale. Continuous camera motion throughout — no static shots. French voiceover will be added afterward.
- Angle: The digital cinema ticket as a luxury artifact — revealed through dramatic lighting, continuous camera motion, and premium UI animation. Voiceover guides the narrative.
- Hook: Phone emerges from darkness with soft cinematic edge glow, screen pulses on. Vo: "Et si votre cinéma tenait dans une seule application ?"
- Outro / punchline: Phone centered, CinéBook logo, "Book. Scan. Enjoy." types out, fade to black with warm glow. Vo: "CinéBook. Book. Scan. Enjoy."
- Avoid:
  - Generic SaaS language
  - Abstract filler visuals
  - Static shots — every scene must have continuous motion (camera orbit, phone tilt, ticket rotation, parallax)

## Visual Identity
- Background: #121212 (dark cinema black)
- Background gradient: #121212 → #1A1A1A → #121212
- Text: #FFFFFF
- Accent: #E50914 (CinéBook red)
- Secondary: #B3B3B3
- Glass: rgba(255,255,255,0.1) with rgba(255,255,255,0.2) border
- Display font: Poppins Bold (Google Fonts)
- Body font: Poppins Regular (Google Fonts)
- Visual references from the project: White ticket card with clipped edges (notch at 1/3 height), movie poster image in top section (placeholder), barcode (code128) below divider, QR code in corner, session info (DATE, HEURE, SALLE, SIÈGE), red accents on dark background, glassmorphism effects

## Storyboard
Use the storyboard in `brag-output-2026-07-23-183119/brag-plan.md` as the creative contract.

Scene summary:
1. Émergence — 3.0s — Phone emerges from darkness with edge glow, screen powers on. Vo: "Et si votre cinéma tenait dans une seule application ?"
2. Révélation du ticket — 4.5s — Ticket card builds element by element (poster, title, date, time, salle, seat, barcode, QR). Vo: "CinéBook. Parcourir les films, choisir votre séance, réserver votre place."
3. Macro QR Code — 4.0s — Macro close-up on QR code with scan line, orbit to barcode, pullback to full ticket. Vo: "Votre ticket digital, généré en un instant. Élégant. Sécurisé. Prêt à l'emploi."
4. Ticket en lévitation — 4.5s — Ticket detaches from phone, rotates 360° in 3D showing both sides. Vo: "Fini les files d'attente. Fini les billets perdus."
5. Déploiement PDF — 4.0s — PDF preview unfolds from center crease, returns to app view. Vo: "Votre place est sur votre téléphone. Et toujours accessible, même hors ligne."
6. Outro — 2.0s — Phone centers, CinéBook logo, "Book. Scan. Enjoy." types out, fade to black. Vo: "CinéBook. Book. Scan. Enjoy."

Total: 22.0 seconds

## Audio
- Audio role: cinematic voice-led support — warm, restrained, with swell on logo. Voiceover will be added as a separate WAV track after composition is built.
- Audio arc: Starts quiet and builds. Music carries the emotional arc. 3 SFX total, sparse and cinematic.
- Music: `happy-beats-business-moves-vol-12-by-ende-dot-app.mp3`
- Music treatment: Fade in over first 2s at 0.25 volume. Hold steady at 0.25 through middle (voiceover space). Subtle swell at 18s. Fade out over final 2s.
- Music cue guidance: Bundled preset at `assets/music/cues/happy-beats-business-moves-vol-12-by-ende-dot-app.music-cues.json`. Strong cues in window: 8.74s (0.99), 10.93s (0.97), 13.11s (0.98), 17.47s (0.99), 22.37s (0.98), 22.93s (1.00). Beat grid ~1.09s intervals starting from 0.56s.
- Audio-reactive treatment: subtle; use music RMS to make phone edge glow and ticket card presence breathe. No waveform/equalizer visuals.
- Audio-coupled moments:
  - Scene 1 — screen power-on glow at 2.5s synced to 2.73s beat
  - Scene 4 — ticket lift-off at ~10.5s aligned to 10.93s strong cue
  - Scene 6 — logo reveal at ~22.37s strong cue
  - Scene 2 — sequential ticket card elements on every other beat (~2.18s intervals)
- SFX selection guidance: 3 SFX total, cinematic. One soft pulse for screen-on (impactSoft_medium or interface/bong_001 at low volume), one resonant bell for ticket detach (impactBell_heavy_000 or _004), one logo hit for outro (impactBell_heavy_003). All at 0.55-0.70 volume. Prefer low HF risk for polished moments.
- SFX analysis guidance: Use `skills/brag/assets/sfx/sfx-analysis.md` if available. Prefer low/medium HF risk for this polished tone.
- Exact SFX choice: Hyperframes should choose filenames, timestamps, density, and volume based on the actual implemented animation.
- Audio files: music copied to `composition/assets/music/`. Copy chosen SFX into `composition/assets/sfx/`.

## Hyperframes Instructions
Use the current `hyperframes` skill and CLI workflow. Prefer native Hyperframes conventions over anything in `/brag`.

Requirements:
- Show at least one real UI, copy, or visual element from the source project (the ticket card with clipped edges, barcode, QR code, movie poster, session info)
- Keep all text readable in final render
- Keep video within 15-25 seconds (22s planned)
- Include the planned music/SFX layer unless audio was explicitly disabled or documented as intentionally silent
- Treat `/brag` audio notes as guidance, not a fixed cue sheet. Choose SFX after the visual animation exists.
- Treat music cue metadata as optional timing hints. Hyperframes decides exact animation timing and should ignore cues that hurt readability, scene pacing, or the product story.
- Major reveals may move toward nearby strong cues within about 0.15s. Smaller entrances may align to nearby beat points within about 0.10s. Use only 1-3 strong cue locks in a 15-25s video unless the edit clearly benefits from more.
- Use SFX to support motion and interaction: card sounds for card-like reveals, short announcement cues for major payoffs, key/click sounds for text or user actions, and restraint when the edit is already busy.
- Honor planned music treatment such as fade-outs, ducking, beat-aligned reveals, or letting a final SFX ring over the music, using the best Hyperframes-supported implementation.
- When music is present and the treatment is not `none`, consider Hyperframes audio-reactive workflow: extract audio data and use RMS/frequency bands for subtle, brand-specific motion. Good targets are glow, depth, background warmth, card presence, title emphasis, or other existing visual elements. Avoid waveform/equalizer visuals, musical-note graphics, generic particle systems, strobing, or heavy pulsing.
- Use local assets for audio and any required runtime/media dependencies when possible.
- Run Hyperframes lint and validate before render.

Key creative notes:
- Continuous camera motion is essential — phone should gently rotate/tilt throughout, camera orbits for close-ups
- Ticket card uses clipped edges (notch at 1/3 height from top) — match the TicketClipper design from the codebase
- Barcode is code128, animates left-to-right
- QR code appears with a scanning light trail
- Ticket float in 3D with subtle shadow and particle sparkle
- PDF unfolds from center crease like paper
- Red accent #E50914 for key details (price, confirmation, logo glow)
- Glassmorphism for overlay panels (blur backdrop, subtle border)
- Gold/blue accent particles for premium feel
- Voiceover WAV will be added separately after composition is built (TTS step)
