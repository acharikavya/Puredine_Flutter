import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local screen palette — matches AdminDashboardScreen, MenuScreen,
/// OrdersScreen, and TablesScreen exactly, so this screen reads as part of
/// the same consistent brand instead of its own one-off theme. Used ONLY
/// for this screen's restyle. Nothing here touches AppColors or any other
/// file — pure UI enhancement, no logic changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a large faint watermark emblem, and a fine glass highlight
/// line along the top edge) matching the Orders / Admin Dashboard screens'
/// Pass-2 treatment, and the full-screen backdrop gained an extra diagonal
/// sheen plus a secondary ambient glow for more depth. The role cards
/// picked up a slim gold top cap so they carry the same color-coded
/// identity language used on the Orders stat cards. No navigation, hover
/// state, sizing, or card-selection logic was touched anywhere in this
/// pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 3: two purely presentational changes — zero changes
/// to navigation, hover state, card sizing/selection, or any other logic
/// anywhere in this file.
///   1. HEADER: `_buildCustomHeader()` was rebuilt from the old dark
///      four-stop maroon "command bar" (ribbon accents, big watermark
///      emblem, glass highlight line, deep rounded corners) into a flat,
///      standard-mobile-app top bar in the spirit of a payments-app home
///      screen — a plain white bar with a soft bottom border/shadow, the
///      "Staff Management" title as a two-tone maroon→gold `ShaderMask`,
///      the same date text and subtitle as before, a thin gold underline
///      accent, and a small circular gold-on-maroon badge icon in the
///      top-right corner (in place of a search bar, which was explicitly
///      not wanted here). No search field of any kind was added anywhere.
///   2. PALETTE: `canvas` (the screen's background) was brightened to a
///      true, near-white tone, matching the requested "majorly white"
///      brand balance.
///
/// UI-ENHANCEMENT PASS 4: presentation-only, exactly like every pass
/// above — no navigation, hover state, card sizing/selection, or any
/// other logic anywhere in this file was touched, and no field, callback,
/// route, or keyword was renamed.
///   1. PALETTE — full PUREDINE mapping: every field name inside
///      `_Palette` is unchanged on purpose (every widget in this file
///      already reads from these exact names, so swapping only the
///      underlying `Color` values re-skins the whole screen with no other
///      code touched):
///        • `milanoRed`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `milanoRedLight`   → Wine `#813244` (topbar lighter gradient)
///        • `milanoRedDeep`    → Burgundy `#8A183F` (primary accent)
///        • `milanoRedDarkest` → Deep Brown/Black `#2E0D16`
///        • `canvas`           → Warm Off-White `#FBF8F5` (main background)
///        • `canvasDeep`       → Soft Cream `#F7F1ED` (card background)
///        • `lemonChiffon`     → Warm Gold `#F3C564` (gold accent)
///        • `lemonChiffonDeep` → deeper gold `#D9A421` (derived companion)
///        • `textDark`         → Deep Brown/Black `#2E0D16`
///        • `textMuted`        → Muted Taupe `#9B707A`
///        • `success`          → Fresh Green `#44AF70`
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so any future error state stays legible.
///      Four supporting PUREDINE tones were ADDED as new fields — nothing
///      existing was removed — `dustyBlush` (`#F3D9DC`, icon backgrounds),
///      `paleRose` (`#EFD7DA`, card borders), `softYellow` (`#FCE1AB`,
///      gold highlight) and `paleMint` (`#EAF6EF`, success backgrounds).
///      `headerGradient` now holds the supplied header gradient exactly
///      (`#742A3C → #813244`), and a new `ctaGradient` field holds the
///      supplied CTA gradient exactly (`#6E1832 → #9B3E4E → #F3C564`) —
///      unused elsewhere in this file today, added only so the palette
///      matches the other admin screens' `_Palette` shape.
///   2. TOP BAR: `_buildCustomHeader()` is no longer a flat white bar —
///      it now carries the PUREDINE Deep Wine Maroon → Wine diagonal
///      gradient, a medium-depth (not near-black) maroon band running the
///      full width from the very top of the screen down to the scrollable
///      body. It gained the same ambient dressing the other admin headers
///      use — a soft warm-gold corner glow, a large very faint watermark
///      emblem, and a subtle diagonal glass sheen — plus a warm-gold
///      hairline along its bottom edge. Structurally nothing inside
///      changed: the same two-tone `ShaderMask` title, the same
///      desktop-only date text, the same subtitle copy, the same thin gold
///      underline accent, and the exact same circular badge icon in the
///      top-right corner (still purely decorative, no tap action or
///      navigation attached). Only the copy's colors changed (white /
///      soft-gold instead of maroon / taupe) so it reads clearly against
///      the wine backdrop.
///   3. TOP-TO-BOTTOM CONSISTENCY: so the whole screen reads as one brand
///      rather than just a re-colored header, the role cards' resting
///      border now uses the Pale Rose tone and their icon badge ring uses
///      the Dusty Blush / Warm Gold pairing, and an extra soft blush glow
///      was added low in the backdrop so the bottom of the scroll keeps
///      the same warm tint as the top.
///
/// UI-ENHANCEMENT PASS 5: presentation-only, exactly like every pass
/// above — no navigation, hover state, or card-selection logic anywhere
/// in this file was touched, and no field, callback, route, or keyword
/// was renamed.
///   1. ROLE CARDS — ORIENTATION: the two role cards were tall, narrow
///      rectangles placed side by side in a `Row` (with a horizontal
///      scroll fallback for very narrow screens). They are now wide,
///      short "horizontal" cards stacked one above the other in a
///      `Column` — each card spans the available content width, with the
///      icon badge on the left and the title/description/hint content on
///      the right (left-aligned), instead of everything centered in a
///      vertical stack. `_StaffTypeCard`'s inner content was rebuilt from
///      a centered `Column` (icon → title → divider → description → hint,
///      stacked top to bottom) into a `Row` (icon badge → `Expanded`
///      left-aligned `Column` of title/description/hint). The same
///      title/description copy, the same icon, the same step-index tag,
///      top gold cap, corner glows, hover glow/lift, and the exact same
///      `context.go('/admin/staff/${widget.role}')` tap callback are all
///      unchanged — only how that content is arranged inside the card
///      changed.
///
/// UI-ENHANCEMENT PASS 6: presentation/layout-only — no navigation, hover
/// state, card-selection logic, copy, icons, or any field/callback/route/
/// keyword anywhere in this file was touched.
///   1. BUG FIX — CARD OVERFLOW: the two role cards previously used a
///      fixed pixel height (`132` mobile / `168` desktop) for their
///      content, which on some devices/text-scale settings was shorter
///      than the title + divider + description + hint-pill stack needed,
///      producing a yellow/black "RenDERFLEX OVERFLOWED" bar inside the
///      card. The card's inner title/description/hint column is now
///      wrapped in a left-aligned `FittedBox` (`BoxFit.scaleDown`), so if
///      the available height is ever tighter than the content needs, the
///      content scales down smoothly to fit instead of erroring — it
///      never crops, never clips, and never throws an overflow exception.
///      No text, spacing, or ordering inside that column changed.
///   2. LAYOUT — BOTH CARDS FIXED ON ONE SCREEN, NO SCROLLING: the
///      `SingleChildScrollView` wrapping the cards area has been removed.
///      The cards area now uses a `LayoutBuilder` + `Expanded` pair so the
///      two horizontal role cards always split the exact remaining
///      vertical space below the header and the "CHOOSE A ROLE" label —
///      both cards are always fully visible together on one screen, with
///      no scrollbar and nothing to scroll, and each card is as big as
///      the screen allows. `cardWidth`/`cardHeight` are no longer
///      precomputed fixed numbers in `build()`; instead each card reads
///      its exact width/height straight from the `LayoutBuilder`
///      constraints of the space it now fills, so sizing always matches
///      the real available screen space on every device instead of a
///      hardcoded guess. Card content, hover behaviour, the step-index
///      tag, the top gold cap, and the tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 7: layout-only, and MOBILE-ONLY — no navigation,
/// hover state, card-selection logic, copy, icons, or any field/callback/
/// route/keyword anywhere in this file was touched, and the
/// desktop/wide-screen layout from PASS 6 is unchanged.
///   1. BUG FIX — CARDS TOO TALL ON MOBILE: PASS 6 made each card fill an
///      equal half of the entire remaining screen height, which on a
///      phone stretched each card into a very tall, oversized block (as
///      shown in the reported screenshot) instead of a normal short
///      rectangular row. On mobile only, each card now instead uses a
///      fixed, "little shorter" target height (`118`, down from the old
///      `132`) via a `LayoutBuilder` around the pair of cards: if the
///      phone screen has enough room, both cards render at that exact
///      short height with the leftover space simply sitting below them
///      (no stretching, no scrollbar); only on a phone screen too short
///      to fit both at that height does the height shrink further so both
///      still always fit on one screen without ever overflowing or
///      needing to scroll. On desktop/wide screens the two cards still
///      split the full remaining height evenly, exactly as in PASS 6.
///      Card content, hover behaviour, the step-index tag, the top gold
///      cap, and the tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 8: layout-only, mobile-only — no navigation, hover
/// state, card-selection logic, copy, icons, or any field/callback/route/
/// keyword anywhere in this file was touched, and the desktop/wide-screen
/// layout is unchanged.
///   1. Mobile cards made a little shorter still: the mobile target
///      height used by the `LayoutBuilder` around the two cards was
///      `118`; it is now `104` so the two cards read as clearly short,
///      wide rectangles on a phone screen instead of the taller blocks
///      from PASS 7. The same shrink-to-fit safety (both the outer
///      `LayoutBuilder` cap and the inner `FittedBox` on the card's text
///      column) is still in place, so this can never overflow or throw a
///      "RenderFlex overflowed" error on any device. Desktop is untouched
///      — it still splits the full remaining height evenly, as before.
///
/// UI-ENHANCEMENT PASS 9: BUG FIX ONLY — no navigation, hover state,
/// card-selection logic, copy, icons, or any field/callback/route/keyword
/// anywhere in this file was touched.
///   1. CRASH FIX — "Assertion failed ... debugNeedsLayout is not true":
///      PASS 7/8 computed both cards' height inside a `LayoutBuilder`
///      whose `builder` callback directly constructed the two animated
///      (`flutter_animate` `.animate()`) card widgets. Building animated
///      widgets straight inside a `LayoutBuilder` callback is a known
///      trigger for a re-entrant layout assertion in Flutter — which is
///      exactly the red error screen reported (cards not rendering at
///      all on mobile). The `LayoutBuilder` has been removed entirely.
///      Each card now simply uses a fixed height (`104` mobile / `170`
///      desktop, matching PASS 8's mobile size) wrapped in a plain
///      `SizedBox`, with no `LayoutBuilder` anywhere near the animated
///      card widgets. As a safety net for any unusually small screen, the
///      two-card block sits inside a `SingleChildScrollView` with its
///      scrollbar explicitly hidden (via a local `ScrollBehavior`) — on
///      every normal phone/desktop screen both cards fit with nothing to
///      scroll and no scrollbar ever shows, and only on a pathologically
///      short screen would a silent, invisible scroll ever kick in
///      instead of an overflow error. The inner `FittedBox` text-scaling
///      safety net from PASS 6 is unchanged. Card content, hover
///      behaviour, the step-index tag, the top gold cap, and the tap
///      callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 10: SIZE-ONLY — no navigation, hover state,
/// card-selection logic, copy, icons, or any field/callback/route/
/// keyword anywhere in this file was touched, and the PASS 9 crash fix
/// (no `LayoutBuilder` near the animated card widgets, scrollbar-free
/// `SingleChildScrollView` safety net) is fully preserved.
///   1. CARDS RESIZED TO MEDIUM: the fixed card height from PASS 9 (`104`
///      mobile / `170` desktop) read as too small/cramped. Both role
///      cards now use a fixed, "medium" rectangular height instead —
///      `132` on mobile (up from `104`) and `198` on desktop (up from
///      `170`) — so each card reads as a clear, comfortably sized
///      rectangle without becoming oversized. The same overflow-proofing
///      stays in place unchanged: the inner `FittedBox` on the card's
///      text column still scales content down if it's ever tight, and
///      the outer scrollbar-free `SingleChildScrollView` still exists as
///      a silent safety net on pathologically short screens — so both
///      cards continue to always render (never an overflow error) no
///      matter the device. Card content, hover behaviour, the step-index
///      tag, the top gold cap, and the tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 11: SIZE-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, or any field/callback/route/
/// keyword anywhere in this file was touched, and the PASS 9 crash fix
/// (no `LayoutBuilder` near the animated card widgets, scrollbar-free
/// `SingleChildScrollView` safety net) is fully preserved.
///   1. CARDS NUDGED TO A TRUER MEDIUM: on the reported mobile screenshot
///      PASS 10's `132` mobile height still read as a little small, with
///      noticeably empty space left below the two cards. The fixed card
///      height is now `150` on mobile (up from `132`) and `210` on
///      desktop (up from `198`) — still a clear, short rectangle, not a
///      tall or oversized block, just filling out to a more balanced
///      "medium" size. The same overflow-proofing is fully unchanged:
///      the inner `FittedBox` on the card's text column still scales
///      content down if it's ever tight, and the outer scrollbar-free
///      `SingleChildScrollView` still exists as a silent safety net on
///      pathologically short screens — so both cards continue to always
///      render (never an overflow error) no matter the device. Card
///      content, hover behaviour, the step-index tag, the top gold cap,
///      and the tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 12: layout + color-only — no
/// navigation, hover state, card-selection logic, copy, icons, or any
/// field/callback/route/keyword anywhere in this file was touched. Card
/// size is unchanged from PASS 11 (`150` mobile / `210` desktop).
///   1. MOBILE CENTERING: the "CHOOSE A ROLE" label + two-card block was
///      always pinned to the top of the screen on mobile (via the cards
///      block being wrapped in `Expanded`, which force-filled all
///      remaining height and left visible empty space below the cards).
///      A new private `_buildCardsBlock()` helper now builds the exact
///      same two cards inside the exact same scrollbar-free
///      `SingleChildScrollView` safety net as before, but only wraps that
///      block in `Expanded` on desktop; on mobile it is left unwrapped so
///      it sizes to its own content. The outer content `Column`'s
///      `mainAxisAlignment` is `MainAxisAlignment.center` on mobile (was
///      implicitly `start`), so the label + both cards are now centered
///      as a group in the middle of the mobile screen. Desktop keeps the
///      original top-aligned, `Expanded`-fill behaviour exactly as in
///      PASS 6–11.
///   2. DARKER CARD THEME FOR VISIBILITY: the resting (non-hovered) card
///      look was reported as too washed-out against the backdrop. Three
///      resting-state colors were darkened — all still built from
///      existing `_Palette` fields, no new fields added: the resting
///      background gradient changed from `[cardWhite, canvasDeep]`
///      (near-white on near-white) to `[canvasDeep, dustyBlush@55%]`; the
///      resting border changed from the very pale `paleRose` to
///      `milanoRedLight@45%`; and the description text changed from the
///      light `textMuted` to the darker `textDark`. The hover-state
///      colors, the title color, the icon badge, the top gold cap, the
///      step-index tag, and every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 13: layout + size + color-only — no
/// navigation, hover state, card-selection logic, copy, icons, or any
/// field/callback/route/keyword anywhere in this file was touched.
///   1. CARDS NUDGED A LITTLE BIGGER: the fixed card height from PASS 11
///      (`150` mobile / `210` desktop) is now `165` mobile / `225`
///      desktop — a small step up to a fuller medium size, still a clear
///      short rectangle, never oversized. The overflow-proofing (inner
///      `FittedBox`, outer scrollbar-free `SingleChildScrollView`) is
///      fully unchanged, so this still can never overflow or error.
///   2. CENTERING FIXED TO CARDS ONLY: PASS 12 centered the "CHOOSE A
///      ROLE" label together with the two cards as one group, which also
///      pulled the label away from the top on mobile. The outer content
///      `Column`'s `mainAxisAlignment` is back to `start` (the label sits
///      at the top exactly as in PASS 1–11), and instead `_buildCardsBlock`
///      now wraps its mobile output in `Expanded(child: Center(...))` —
///      so only the two-card block is centered within the remaining
///      space below the label. Desktop is unchanged (still fills that
///      remaining space evenly via `Expanded`, no `Center` needed there).
///   3. CARD THEME DARKENED FURTHER: the resting-state background
///      gradient and border from PASS 12 still read as too light. The
///      resting gradient is now `[dustyBlush@90%, paleRose@90%]` (up from
///      `[canvasDeep, dustyBlush@55%]`) and the resting border is now
///      `milanoRed@60%` (up from `milanoRedLight@45%`) — both still built
///      from existing `_Palette` fields, no new fields added. Title color,
///      description color (`textDark`, set in PASS 12), icon badge, hover
///      colors, the top gold cap, the step-index tag, and every shadow
///      are all unchanged.
///
/// UI-ENHANCEMENT PASS 14: SPACING-ONLY — no navigation,
/// hover state, card-selection logic, copy, icons, sizing, or any
/// field/callback/route/keyword anywhere in this file was touched. Card
/// height is unchanged from PASS 13 (`165` mobile / `225` desktop), and
/// the PASS 13 top-pinned-label / centered-cards-block layout is fully
/// preserved.
///   1. GAP OPENED UP BETWEEN THE TWO CARDS: `cardSpacing` (the fixed
///      gap between the "Billing Staff" and "Serving Staff" cards) is
///      now `48` on mobile (up from `14`) and `36` on desktop (up from
///      `20`). Because the two-card block is still centered as a whole
///      (PASS 13), widening only the internal gap between the cards
///      naturally pushes the first card a little toward the top of that
///      centered block and the second card a little toward the bottom,
///      leaving open space in the middle between them — exactly the
///      "first card a little up, second card a little down, space in
///      the middle" look, with no change to card height, card content,
///      hover behaviour, or the tap callback.
///
/// UI-ENHANCEMENT PASS 15: LAYOUT + SPACING-ONLY — no
/// navigation, hover state, card-selection logic, copy, icons, sizing
/// (card height is unchanged: `165` mobile / `225` desktop), or any
/// field/callback/route/keyword anywhere in this file was touched.
///   1. FIXED POSITIONING FOR A CLEANER, MORE PROFESSIONAL LOOK: PASS 14's
///      very wide `48`/`36` gap combined with dead-center placement left
///      an oddly large, unbalanced empty band in the middle of the mobile
///      screen. Two adjustments fix that:
///        • `cardSpacing` is now `22` on mobile (down from `48`) and `26`
///          on desktop (down from `36`) — a normal, comfortable gap
///          between "Billing Staff" and "Serving Staff" instead of an
///          oversized one.
///        • On mobile, `_buildCardsBlock` now positions the two-card
///          block with `Align(alignment: const Alignment(0, -0.35), ...)`
///          instead of dead-center `Center(...)`, so the pair sits a
///          little closer to the "CHOOSE A ROLE" label near the top of
///          the remaining space — the "first card a little more up" look
///          — rather than floating awkwardly in the exact middle of the
///          screen. Desktop is completely unchanged (still just fills the
///          remaining height via `Expanded`, no `Align`/`Center` there).
///      Card content, hover behaviour, the step-index tag, the top gold
///      cap, and the tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 16: SPACING-ONLY — no navigation,
/// hover state, card-selection logic, copy, icons, sizing (card height is
/// unchanged: `165` mobile / `225` desktop), or positioning (the PASS 15
/// top-pinned-label / upward-biased-cards-block layout is fully
/// preserved), or any field/callback/route/keyword anywhere in this file
/// was touched.
///   1. A LITTLE MORE SPACE BETWEEN THE TWO CARDS: `cardSpacing` is now
///      `32` on mobile (up from PASS 15's `22`) and `34` on desktop (up
///      from `26`) — a modest increase so the gap between "Billing Staff"
///      and "Serving Staff" reads more clearly and attractively, without
///      returning to PASS 14's oversized, unbalanced gap. Card content,
///      hover behaviour, the step-index tag, the top gold cap, and the
///      tap callback are all unchanged.
///
/// UI-ENHANCEMENT PASS 17: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, sizing, or positioning was
/// touched, and no field/callback/route/keyword anywhere in this file was
/// touched. This pass applies the exact "PUREDINE Maroon + Cream" card
/// palette the user specified, verbatim, to the cards only:
///   1. RESTING CARD BACKGROUND is now the exact specified color,
///      `#FBF8F5` (`_Palette.canvas`), as a solid fill — replacing PASS
///      13's darkened `[dustyBlush@90%, paleRose@90%]` gradient.
///   2. RESTING CARD BORDER is now the exact specified color, `#EFD7DA`
///      (`_Palette.paleRose`), at full opacity — replacing PASS 13's
///      `milanoRed@60%`.
///   3. ICON BADGE BACKGROUND (resting) is now the exact specified color,
///      `#F3D9DC` (`_Palette.dustyBlush`), as a solid fill — replacing
///      the earlier two-tone `[dustyBlush, lemonChiffon@50%]` gradient.
///   All three values are taken directly from the `_Palette` fields that
///   already hold these exact hex codes (`canvas`, `paleRose`,
///   `dustyBlush` — no new fields added, none renamed). The hover-state
///   colors, title color, description color, the top gold cap, the
///   step-index tag, and every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 18: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, sizing, spacing, or
/// positioning was touched, and no field/callback/route/keyword anywhere
/// in this file was renamed or removed. PASS 17's near-white/near-pale
/// resting card look read as too light and washed out. The resting
/// (non-hovered) card colors were darkened by blending existing
/// `_Palette` fields (`Color.lerp`, computed locally in `_StaffTypeCard`'s
/// `build()` — no new `_Palette` fields added):
///   1. RESTING CARD BACKGROUND is now a warm maroon-tinted rose gradient
///      (a blend of `dustyBlush`/`paleRose` toward `milanoRedLight`/
///      `milanoRed`) instead of the flat `canvas` fill from PASS 17.
///   2. RESTING CARD BORDER is now a deeper rose-maroon blend (`paleRose`
///      blended further toward `milanoRed`) instead of the pale, low-
///      contrast `paleRose` border from PASS 17.
///   3. ICON BADGE BACKGROUND (resting) is now a deeper blend of
///      `dustyBlush` toward `milanoRedLight` instead of the flat
///      `dustyBlush` fill from PASS 17.
///   The hover-state colors, title color, description color, the top
///   gold cap, the step-index tag, and every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 19: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, sizing, spacing, or
/// positioning was touched, and no field/callback/route/keyword anywhere
/// in this file was renamed or removed. PASS 18's resting card colors
/// read as too dark/heavy a pink-maroon. The same three resting-state
/// `Color.lerp` blends from PASS 18 are kept (same source `_Palette`
/// fields, same structure — only the blend amounts were reduced) so the
/// cards read as a lighter, softer rose tint instead of a deep pink:
///   1. RESTING CARD BACKGROUND blend factors reduced from `0.22`/`0.18`
///      to `0.12`/`0.10` (dustyBlush/paleRose blended only lightly toward
///      milanoRedLight/milanoRed instead of PASS 18's heavier blend).
///   2. RESTING CARD BORDER blend factor reduced from `0.55` to `0.35`
///      (paleRose blended less toward milanoRed) — still clearly defined
///      against the lighter background, but softer than PASS 18.
///   3. ICON BADGE BACKGROUND (resting) blend factor reduced from `0.30`
///      to `0.16` (dustyBlush blended only lightly toward milanoRedLight)
///      instead of PASS 18's deeper tint.
///   The hover-state colors, title color, description color, the top
///   gold cap, the step-index tag, and every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 20: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, sizing, spacing, or
/// positioning was touched, and no field/callback/route/keyword anywhere
/// in this file was renamed or removed. PASS 19's resting pink card tone
/// was requested lighter still, for a softer, more attractive/professional
/// look. The same three resting-state `Color.lerp` blends from PASS 19
/// are kept (same source `_Palette` fields, same structure — only the
/// blend amounts were reduced further):
///   1. RESTING CARD BACKGROUND blend factors reduced from `0.12`/`0.10`
///      to `0.07`/`0.06` — a subtle, light pink instead of PASS 19's
///      more noticeable rose tint.
///   2. RESTING CARD BORDER blend factor reduced from `0.35` to `0.22` —
///      still clearly defined against the lighter background, but softer
///      than PASS 19.
///   3. ICON BADGE BACKGROUND (resting) blend factor reduced from `0.16`
///      to `0.10` — a lighter pink badge fill than PASS 19.
///   The hover-state colors, title color, description color, the top
///   gold cap, the step-index tag, and every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 21: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, sizing, spacing, or
/// positioning was touched, and no field/callback/route/keyword anywhere
/// in this file was renamed or removed. The resting (non-hovered) card's
/// yellow/gold accents — the top gold cap strip, the step-index tag
/// background, and the icon badge's outer ring — read as too pale. All
/// three now use the deeper `lemonChiffonDeep` field (already defined in
/// `_Palette`, unchanged, just used in more places) instead of the
/// lighter `lemonChiffon`, at similar opacities:
///   1. TOP GOLD CAP (resting) is now `lemonChiffonDeep@75%` (was
///      `lemonChiffon@75%`).
///   2. STEP-INDEX TAG BACKGROUND (resting) is now `lemonChiffonDeep@60%`
///      (was `lemonChiffon@55%`).
///   3. ICON BADGE OUTER RING (resting) is now `lemonChiffonDeep@55%`
///      (was `lemonChiffon@50%`).
///   The hover-state colors, title color, description color, card
///   background/border (PASS 20), the step-index tag's text color, and
///   every shadow are all unchanged.
///
/// UI-ENHANCEMENT PASS 22: COLOR-ONLY — no navigation, hover
/// state, card-selection logic, copy, icons, or positioning was
/// touched, and no field/callback/route/keyword anywhere in this file was
/// touched. The card's description line (the "subtitle" under each card's
/// title, e.g. "Manage cashier terminals and transaction logs.") was
/// requested more visible/darker. It already used `_Palette.textDark`
/// (the darkest text color defined in `_Palette`), so to add real visible
/// contrast without introducing a new color, its `FontWeight` was raised
/// from the implicit regular weight to `FontWeight.w600` — the same dark
/// color reads noticeably bolder and more prominent against the card
/// background. Title color, the top gold cap, the step-index tag, the
/// icon badge, hover colors, card background/border, and every shadow are
/// all unchanged.
///
/// UI-ENHANCEMENT PASS 23: COLOR + DECORATIVE-DETAIL-ONLY,
/// matching a supplied reference screenshot — no navigation, hover-STATE
/// LOGIC, card-selection logic, sizing, spacing, positioning, copy, or
/// any field/callback/route/keyword anywhere in this file was touched.
/// Only the resting-card visual details inside `_StaffTypeCardState.build()`
/// were restyled to match the reference image exactly:
///   1. RESTING CARD BACKGROUND is now a single flat soft blush-pink fill
///      (a `Color.lerp` blend of `canvas` toward `paleRose`) instead of
///      PASS 20's two-tone maroon-tinted gradient, matching the flat pink
///      card look in the reference image.
///   2. RESTING CARD BORDER is now the plain `paleRose` tone at full
///      opacity (a soft, clearly-defined pink line) instead of the PASS
///      20 blended border.
///   3. STEP-INDEX TAG (both states) is now a solid dark maroon fill
///      (`milanoRedDeep` resting, `milanoRedDarkest` on hover) with white
///      numerals — replacing PASS 21's gold-tinted resting fill — matching
///      the badge color shown in the reference image.
///   4. ICON BADGE (resting) fill is now a very light blush tint (a light
///      blend of white toward `dustyBlush`) with a `lemonChiffonDeep`
///      gold ring, matching the light icon circle + thin gold ring shown
///      in the reference image. Hover-state icon colors are unchanged.
///   5. TITLE: the underline `_TitleDivider` beneath the title was
///      replaced with a short vertical maroon accent bar placed to the
///      LEFT of the title text (matching the "| Billing Staff" look in
///      the reference image). `_TitleDivider` itself is left fully intact
///      and untouched in the file — it is simply not invoked from this
///      card anymore.
///   6. DESCRIPTION color/weight is now a softer muted maroon-brown blend
///      (`milanoRedDeep` blended toward `textMuted`) at a lighter
///      `FontWeight.w500` when resting, matching the lighter, muted
///      description tone in the reference image. On hover it stays the
///      darker, bolder `textDark`/`w600` treatment from PASS 22 for
///      clear contrast against the hover fill.
///   7. TRAILING CHEVRON: the hover-only "Manage →" pill has been
///      replaced with a small, ALWAYS-VISIBLE chevron icon on the card's
///      right edge (matching the plain "›" shown in the reference image
///      on every card, not just on hover — important since touch devices
///      never trigger `_isHovered` in the first place). The tap target,
///      tap callback (`context.go('/admin/staff/${widget.role}')`), and
///      every other piece of card logic are completely unchanged — this
///      is a like-for-like swap of one decorative trailing widget for
///      another, both purely visual.
///
/// UI-ENHANCEMENT PASS 24: ICON AVATAR ONLY, matching a
/// second supplied reference screenshot — no navigation, hover-state
/// LOGIC, card-selection logic, sizing, spacing, positioning, copy, or
/// any field/callback/route/keyword anywhere in this file was touched.
/// Only the resting-state icon-badge circle inside
/// `_StaffTypeCardState.build()` was restyled to read as a cleaner,
/// crisper, more premium "avatar" — closer to the reference image and
/// more polished than PASS 23's flat light-blush fill:
///   1. ICON BADGE FILL (resting) was a clean, near-white → soft-cream
///      radial gradient (`Colors.white` at the center fading to
///      `_Palette.canvas`) instead of PASS 23's flat blended blush tint —
///      a crisper, "porcelain" avatar look, built only from existing
///      colors (`Colors.white`, `_Palette.canvas`).
///   2. GOLD RING (resting) is a touch more defined: opacity raised from
///      `0.65` to `0.85` and width from `1.4` to `1.6`, so the ring reads
///      as a clear, deliberate gold outline (matching the reference
///      image) rather than a faint hairline. Hover-state ring color/width
///      is unchanged.
///   3. ALWAYS-ON SOFT SHADOW: the icon badge now always casts a subtle
///      shadow (a soft warm-gold glow plus a faint neutral drop shadow),
///      not only on hover, so the avatar reads as a raised, professional
///      badge sitting slightly above the card instead of flat artwork.
///      The hover-state's stronger maroon glow shadow is unchanged.
///   4. A thin inner highlight ring (a very faint white stroke just
///      inside the gold ring) was added purely for polish, giving the
///      avatar a subtle "embossed" edge like a printed badge.
///   Icon glyph, icon color, icon size, the outer gold ring's shape/
///   position, the step-index tag, the top gold cap, the title/
///   description styling, the trailing chevron, and every callback are
///   all completely unchanged from PASS 23.
///
/// UI-ENHANCEMENT PASS 25: ICON AVATAR FILL
/// COLOR ONLY — no navigation, hover-state logic, card-selection logic,
/// sizing, spacing, positioning, copy, icons, or any field/callback/
/// route/keyword anywhere in this file was touched. PASS 24's icon-badge
/// resting fill (a near-white → soft-cream radial gradient) read as an
/// off-theme white patch sitting inside an otherwise warm blush-pink
/// card. It has been swapped for the same PUREDINE blush palette the
/// rest of the card already uses, so the icon circle now visibly belongs
/// to the same color family instead of standing out as a separate white
/// disc — matching the tonal, consistent card look in the reference
/// image:
///   1. ICON BADGE FILL (resting) is now a radial gradient built only
///      from existing `_Palette` fields — `dustyBlush` at the center
///      fading to `paleRose` at the edge — replacing PASS 24's
///      `Colors.white` → `_Palette.canvas` gradient. No new `_Palette`
///      fields were added.
///   2. INNER HIGHLIGHT RING (resting) — the thin embossed stroke just
///      inside the gold ring — is now a softer, semi-transparent white
///      (`alpha: 0.55`, down from a fully opaque `0.9`) so it still reads
///      as a polished edge without washing the new blush fill back out
///      toward white.
///   Icon glyph, icon color, icon size, the gold ring's opacity/width,
///   the always-on soft shadow, the outer gold ring's shape/position, the
///   step-index tag, the top gold cap, the title/description styling, the
///   trailing chevron, and every callback are all completely unchanged
///   from PASS 24. Hover-state icon colors are untouched.
///
/// UI-ENHANCEMENT PASS 26: COLOR-ONLY, split
/// between mobile description contrast and desktop hover contrast — no
/// navigation, hover-state LOGIC (only its colors), card-selection logic,
/// sizing, spacing, positioning, copy, icons, or any field/callback/
/// route/keyword anywhere in this file was touched.
///   1. MOBILE — DESCRIPTION MADE BLACK: on mobile only, the card
///      description text now always renders as solid black instead of
///      the blended `restingDescriptionColor`/`textDark` tones used
///      before, so the subtitle reads clearly and professionally on
///      small screens (mobile essentially never triggers `_isHovered`
///      anyway, since touch devices don't hover). Desktop's description
///      colors (resting `restingDescriptionColor`, hover — see below) are
///      unchanged in kind, only adjusted for the new hover background.
///   2. DESKTOP — HOVER CONTRAST FIX: on hover, the card's background
///      gradient was a near-white → light-gold combination
///      (`cardWhite` → `lemonChiffon@25%`), while the title, the vertical
///      title-accent bar, and the trailing chevron all switched to plain
///      white — white text on a near-white card, which is why the hover
///      state read as washed-out/invisible. The hover background is now
///      a solid dark maroon gradient (`milanoRedDeep` → `milanoRed`,
///      both existing `_Palette` fields) instead, so the existing white
///      title/accent-bar/chevron colors (left completely unchanged) are
///      finally clearly visible against it, and the card reads as a rich,
///      premium "selected" state instead of a faded one. (SUPERSEDED BY
///      PASS 27 below — the dark-maroon hover theme was removed.)
///
/// UI-ENHANCEMENT PASS 27: COLOR-ONLY — REMOVES THE HOVER
/// COLOR THEME ON DESKTOP. No navigation, tap callback, hover-STATE
/// LOGIC (`_isHovered`, `MouseRegion`, `onEnter`/`onExit`), card-selection
/// logic, sizing, spacing, positioning, copy, icons, or any field/
/// callback/route/keyword anywhere in this file was touched or renamed.
/// The dark-maroon hover theme from PASS 26 was reported as too dark, so
/// every hover-driven COLOR change inside `_StaffTypeCardState.build()`
/// now resolves to the exact same value as the resting (normal) state —
/// the card looks identical whether or not the cursor is over it:
///   1. CARD BACKGROUND / BORDER: always `restingBg` / `restingBorder`
///      (the dark maroon hover gradient and maroon hover border are gone).
///   2. TOP GOLD CAP, STEP-INDEX TAG, CORNER GLOW: always their resting
///      colors/opacities.
///   3. ICON BADGE (ring, inner ring, fill gradient, glyph color, shadows):
///      always the resting blush badge with the burgundy glyph.
///   4. TITLE, TITLE ACCENT BAR, DESCRIPTION, TRAILING CHEVRON: always
///      their resting colors/weights (no more white-on-hover text).
///   Only the small non-color hover effects are kept exactly as they were:
///   the 6px upward lift (`transform`) and the elevated `glowShadow` on
///   the card. The `_isHovered` flag itself is still tracked as before.
///
/// UI-ENHANCEMENT PASS 28: FONT-SIZE-ONLY, SCOPED TO THE CARDS ONLY — no
/// navigation, tap callback, hover state, card-selection logic, card
/// height/width, spacing, colors, copy, icons, or any field/callback/
/// route/keyword anywhere in this file was touched or renamed. The
/// topbar (`_buildCustomHeader()`) — its "Staff Management" title and its
/// "Select a role to manage credentials and access." subtitle — was
/// deliberately left untouched at its original sizes
/// (`isMobile ? 21 : 28` for the title, `isMobile ? 12.5 : 14` for the
/// subtitle). Only the title and description text INSIDE the two role
/// cards were made bigger.
///   1. FONT SIZES INCREASED (inside `_StaffTypeCardState.build()`,
///      i.e. only the card's own title/description, never the topbar):
///        • `titleFontSize`        mobile 16   → 20,   desktop 21   → 26
///        • `descriptionFontSize`  mobile 12   → 15,   desktop 13.5 → 16
///      The vertical title-accent bar already scales from
///      `titleFontSize`, so it grows with the title automatically.
///   2. WHY A SMALL LAYOUT ADJUSTMENT WAS ALSO NEEDED (so the bigger
///      font is actually VISIBLE): the card's text column sat inside a
///      `FittedBox(BoxFit.scaleDown)`, and a `FittedBox` lays its child
///      out with unlimited width — so the description never wrapped and
///      was instead shrunk to squeeze onto one long line, which is why
///      it looked tiny. Simply raising `fontSize` would have been
///      shrunk right back down again. The text column is now given the
///      real available width (read via a `LayoutBuilder` placed INSIDE
///      the card, around plain `Text` widgets only — nothing animated is
///      built in that callback, so the PASS 9 crash cannot recur), so
///      the description wraps onto multiple lines at the full new size.
///      The `FittedBox` is kept around it as the same overflow safety
///      net as before (it now only ever scales down if the wrapped text
///      would be taller than the card).
///   3. SMALL SUPPORTING TWEAKS: the description's `maxLines` on mobile
///      is `3` (was `2`) so the longer wrapped text is never cut off
///      with "…" at the larger size, and the title `Text` is wrapped in
///      a `Flexible` so a very narrow screen ellipsizes the title
///      instead of throwing a RenderFlex overflow.
/// ─────────────────────────────────────────────────────────────────────────

/// PASS 9: a `ScrollBehavior` that never paints a scrollbar. Used only to
/// wrap the two-card safety-net `SingleChildScrollView` below so that,
/// even on the rare screen small enough to need the extra scroll room,
/// no visible scrollbar ever appears — purely a rendering/behaviour
/// detail, not a feature change.
class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class _Palette {
  _Palette._();

  // PUREDINE Maroon + Cream — field names unchanged on purpose (see the
  // PASS 4 note above); only the underlying Color values changed.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedDeep =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color milanoRedDarkest = Color(0xFF2E0D16); // Deep Brown/Black
  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color lemonChiffonDeep =
      Color(0xFFD9A421); // Deeper Warm Gold (derived)
  static const Color canvas =
      Color(0xFFFBF8F5); // Warm Off-White (Main background)
  static const Color canvasDeep = Color(0xFFF7F1ED); // Soft Cream (Card bg)
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black text
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color success = Color(0xFF44AF70); // Fresh Green
  static const Color danger = Color(0xFFE0323F); // Clear alert red

  // PASS 4: four supporting PUREDINE tones added — nothing above this
  // line was removed; these are new fields only.
  static const Color dustyBlush =
      Color(0xFFF3D9DC); // Dusty Blush — icon backgrounds
  static const Color paleRose = Color(0xFFEFD7DA); // Pale Rose — card borders
  static const Color softYellow = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color paleMint = Color(0xFFEAF6EF); // Pale Mint background

  /// The supplied top-header gradient, exactly: `#742A3C → #813244`.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRed, milanoRedLight],
  );

  /// The supplied CTA gradient, exactly: `#6E1832 → #9B3E4E → #F3C564`.
  /// Kept defined for palette-shape parity with the other admin screens;
  /// not referenced elsewhere in this file today, so an unused private
  /// static field here causes no compile error.
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), lemonChiffon],
  );

  /// Themed soft shadow for resting cards/panels — matches MenuScreen's and
  /// OrdersScreen's softShadow exactly, so every surface across the admin
  /// app shares the same warm, branded tint.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Themed elevated/hover shadow — matches MenuScreen's glowShadow, used
  /// on card hover for a richer, more premium lift effect.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
}

class StaffLandingScreen extends StatelessWidget {
  const StaffLandingScreen({super.key});

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _todayLabel() {
    final now = DateTime.now();
    return '${_monthNames[now.month - 1]} ${now.day}, ${now.year}';
  }

  // The role cards' content column never exceeds this width even on wide
  // desktop screens — matches the `ConstrainedBox(maxWidth: 1000)` wrapper
  // further down in `build()`, so the card-width math below stays in sync
  // with the actual space the cards are laid out in.
  static const double _maxContentWidth = 1000;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // ── Layout metrics ──────────────────────────────────────────────────
    // PASS 6: the cards no longer use a precomputed fixed pixel height.
    // Both horizontal role cards now live inside `Expanded` slots (see
    // below) so they always split the exact remaining vertical space on
    // the screen between the header and the bottom edge — meaning both
    // cards are always fully visible together, with nothing to scroll.
    // These metrics only control spacing/padding around that area.
    final double horizontalPadding = isMobile ? 16 : 40;
    final double verticalPadding = isMobile ? 20 : 32;
    // PASS 16: a little more space between the two cards — up from PASS
    // 15's `22`/`26` — for a clearer, more attractive gap, without
    // returning to PASS 14's oversized spacing. Card height, padding,
    // and everything else is unchanged.
    final double cardSpacing = isMobile ? 32 : 34;

    // PASS 13: a small further step up in card height — still a clear,
    // medium short rectangle, never oversized. Everything else about the
    // layout (the scroll-safety-net, the FittedBox overflow guard,
    // spacing, padding) is unchanged.
    final double cardHeight = isMobile ? 165 : 225;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — layered gold/maroon glows plus a faint
          // textured photograph, matching MenuScreen's/OrdersScreen's
          // "foggy" backdrop so the whole admin experience feels like one
          // cohesive, premium brand.
          Positioned.fill(
            child: Container(
              color: _Palette.canvas,
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    right: -60,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffon.withValues(alpha: 0.32),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -90,
                    left: -80,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRed.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 260,
                    right: -110,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // UI-ENHANCEMENT PASS 2: extra low, wide glow further down
                  // the page — gives the role-card area a second soft focal
                  // point instead of all the ambient light sitting only
                  // near the header. Matches the Orders / Admin Dashboard
                  // screens' Pass-2 backdrop.
                  Positioned(
                    top: 560,
                    left: -100,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRedLight.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // PASS 4: a soft blush glow low on the right, so the
                  // bottom of the screen carries the same warm brand tint
                  // as the top instead of fading to flat white. Purely
                  // decorative.
                  Positioned(
                    bottom: 40,
                    right: -70,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.dustyBlush.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.04,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping across the
          // whole body — a subtle extra layer of depth so the cream backdrop
          // doesn't read as flat behind the header, echoing the glass-
          // highlight language used in the header itself. Purely cosmetic,
          // sits above the ambient blobs and below all real content.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.26),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildCustomHeader(context, isMobile),
              // PASS 6: `SingleChildScrollView` removed. This `Expanded`
              // now takes up exactly the remaining screen height below the
              // header, and everything inside it (the "CHOOSE A ROLE"
              // label plus both cards) is laid out to fill that space
              // directly — nothing scrolls, and both cards are always
              // visible together.
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: _maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        verticalPadding,
                        horizontalPadding,
                        verticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // PASS 13: back to always `start` — the "CHOOSE A
                        // ROLE" label stays fixed at the top on every
                        // device. Centering now happens only inside the
                        // cards block itself (see `_buildCardsBlock` /
                        // PASS 13 note below), not on this whole Column.
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _Palette.milanoRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'CHOOSE A ROLE',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                  color: _Palette.textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _Palette.milanoRedDeep
                                            .withValues(alpha: 0.14),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 16 : 24),
                          // ── Role cards ────────────────────────────────
                          // PASS 9: no `LayoutBuilder` here anymore (see
                          // the PASS 9 note at the top of this file for
                          // why — it was causing a real Flutter layout
                          // crash). Each card now just uses a plain fixed
                          // height via a `SizedBox` (PASS 11: a medium
                          // `150` mobile / `210` desktop), and the
                          // whole two-card block sits inside a
                          // scrollbar-free `SingleChildScrollView` purely
                          // as a safety net for unusually small screens —
                          // on any normal screen both cards fit exactly as
                          // sized, with nothing to scroll and no scrollbar
                          // ever visible. Card content, hover behaviour,
                          // and navigation are completely unchanged from
                          // PASS 5.
                          //
                          // PASS 13: on mobile this block centers only
                          // itself (via `Expanded(child: Center(...))`
                          // inside `_buildCardsBlock`) within the space
                          // left below the "CHOOSE A ROLE" label — the
                          // label no longer moves. Desktop is untouched —
                          // the cards area there still uses `Expanded` to
                          // fill the remaining height exactly as before.
                          _buildCardsBlock(cardHeight, cardSpacing, isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  /// PASS 12/13/15: builds the two-card block exactly as PASS 9/10/11 did
  /// (same `_NoScrollbarBehavior` + `SingleChildScrollView` safety net,
  /// same two `_StaffTypeCard`s, same `cardHeight`/`cardSpacing`, same tap
  /// callback). PASS 13: on mobile the block sits within the remaining
  /// space below the "CHOOSE A ROLE" label (`Expanded`), so the label
  /// always stays pinned to the top. PASS 15: within that remaining
  /// space, the block is now positioned with a slight upward bias
  /// (`Align(0, -0.35)`) instead of dead-center, for a cleaner,
  /// properly-balanced placement instead of floating in the exact
  /// middle. On desktop, nothing changed from PASS 6–13: the cards area
  /// still fills the remaining height evenly via `Expanded`, no
  /// `Align`/`Center` needed there. No card content, hover behaviour, or
  /// navigation logic was touched.
  Widget _buildCardsBlock(
      double cardHeight, double cardSpacing, bool isMobile) {
    final Widget scrollableCards = ScrollConfiguration(
      behavior: _NoScrollbarBehavior(),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: cardHeight,
              child: _StaffTypeCard(
                title: 'Billing Staff',
                description: 'Manage cashier terminals and transaction logs.',
                icon: Icons.receipt_long_rounded,
                role: 'cashier',
                index: 0,
                isMobile: isMobile,
                width: double.infinity,
                height: cardHeight,
              ),
            ),
            SizedBox(height: cardSpacing),
            SizedBox(
              height: cardHeight,
              child: _StaffTypeCard(
                title: 'Serving Staff',
                description: 'Manage floor staff and service assignments.',
                icon: Icons.restaurant_rounded,
                role: 'server',
                index: 1,
                isMobile: isMobile,
                width: double.infinity,
                height: cardHeight,
              ),
            ),
          ],
        ),
      ),
    );

    // PASS 15: mobile fills the remaining space with `Expanded` (so the
    // label above keeps its own natural top position) and positions the
    // two-card block with a slight upward bias inside that remaining
    // space via `Align(0, -0.35)` — closer to the label, properly
    // balanced, instead of PASS 13's dead-center `Center`. Desktop is
    // unchanged — it still just fills that space, no Align/Center.
    return Expanded(
      child: isMobile
          ? Align(
              alignment: const Alignment(0, -0.35),
              child: scrollableCards,
            )
          : scrollableCards,
    );
  }

  /// PASS 3 rebuilt this into a flat, standard-mobile-app top bar.
  ///
  /// PASS 4: the same bar now carries the PUREDINE Deep Wine Maroon →
  /// Wine gradient (`#742A3C → #813244`) instead of flat white — a
  /// medium-depth maroon top bar spanning the full width of the screen,
  /// with a soft warm-gold corner glow, a large very faint watermark
  /// emblem behind the copy, a subtle diagonal glass sheen, and a
  /// warm-gold hairline along the bottom edge. Structurally identical to
  /// before: the same two-tone `ShaderMask` title, the same desktop-only
  /// date text, the same subtitle copy, the same thin gold underline
  /// accent, and the exact same circular badge icon in the top-right
  /// corner (still purely decorative, no tap action or navigation
  /// attached). Only the copy's colors changed so it reads clearly on the
  /// wine backdrop. No navigation, sizing, or any other logic was touched
  /// — presentation only.
  ///
  /// PASS 28: this header's title/subtitle font sizes were deliberately
  /// left exactly as they were (`isMobile ? 21 : 28` for the title,
  /// `isMobile ? 12.5 : 14` for the subtitle) — the font-size increase in
  /// PASS 28 applies only to the two role cards below, never to this
  /// topbar.
  Widget _buildCustomHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _Palette.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: _Palette.lemonChiffon.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Ambient dressing for the wine backdrop — a soft warm-gold
          // corner glow, a large very faint watermark emblem behind the
          // copy, and a diagonal glass sheen. Purely decorative, clipped
          // to the header's own bounds.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -50,
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _Palette.lemonChiffon.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: isMobile ? -22 : -14,
                      bottom: isMobile ? -20 : -16,
                      child: Icon(
                        Icons.badge_rounded,
                        size: isMobile ? 120 : 160,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 18 : 32,
                isMobile ? 16 : 22,
                isMobile ? 18 : 32,
                isMobile ? 18 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row — the two-tone brand title on the left, the
                  // date (desktop only), and a small circular badge icon
                  // on the right in place of a search bar / avatar photo.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              _Palette.lemonChiffon,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Staff Management',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              // PASS 28: left exactly as-is — topbar font
                              // size is out of scope for the card-only
                              // font-size increase.
                              fontSize: isMobile ? 21 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isMobile) ...[
                        Text(
                          _todayLabel(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: _Palette.softYellow,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      // Small circular gold-on-maroon badge, standing in
                      // for the avatar/profile circle a standard mobile
                      // top bar would show — purely decorative, no tap
                      // action or navigation attached.
                      Container(
                        width: isMobile ? 40 : 44,
                        height: isMobile ? 40 : 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.16),
                              _Palette.lemonChiffon.withValues(alpha: 0.30),
                            ],
                          ),
                          border: Border.all(
                            color: _Palette.lemonChiffon.withValues(
                              alpha: 0.75,
                            ),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          color: Colors.white,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    'Select a role to manage credentials and access.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      // PASS 28: left exactly as-is — topbar font size is
                      // out of scope for the card-only font-size increase.
                      fontSize: isMobile ? 12.5 : 14,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  // Thin gold gradient hairline — the same soft divider
                  // language used across the rest of the app's headers.
                  // Purely decorative.
                  Container(
                    width: 46,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.95),
                          _Palette.lemonChiffon.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }
}

/// Compact icon-only "back" control — a circular glass button showing only
/// a plain "‹" glyph. Replaces the previous arrow-icon + "Back to
/// Dashboard" pill with a minimal, professional control that matches the
/// other 40×40 circular header buttons used across the app (Menu, Orders).
class _BackChevronButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackChevronButton({required this.onTap});

  @override
  State<_BackChevronButton> createState() => _BackChevronButtonState();
}

class _BackChevronButtonState extends State<_BackChevronButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.10),
            border: Border.all(
              color: _isHovered
                  ? _Palette.lemonChiffon.withValues(alpha: 0.7)
                  : _Palette.lemonChiffon.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _Palette.lemonChiffon.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Text(
            '‹',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the card title —
/// purely cosmetic, mirrors the same accent used on the dashboard, menu,
/// and orders screens so the title treatment matches exactly across the
/// admin app.
///
/// PASS 5: now left-aligned (a solid-to-transparent gradient instead of a
/// transparent-to-solid-to-transparent one) to sit naturally under a
/// left-aligned card title instead of a centered one — purely cosmetic.
///
/// PASS 23: this widget class is left fully intact and untouched — it is
/// simply no longer invoked from `_StaffTypeCard`, which now places a
/// short vertical accent bar to the LEFT of the title instead, matching
/// the reference image. Kept here unchanged in case it's wanted again.
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            _Palette.lemonChiffon.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _StaffTypeCard extends StatefulWidget {
  final String title, description, role;
  final IconData icon;
  final int index;
  final bool isMobile;
  final double width;
  final double height;

  const _StaffTypeCard({
    required this.title,
    required this.description,
    required this.role,
    required this.icon,
    required this.index,
    required this.isMobile,
    required this.width,
    required this.height,
  });

  @override
  State<_StaffTypeCard> createState() => _StaffTypeCardState();
}

class _StaffTypeCardState extends State<_StaffTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // PASS 5: content metrics tuned for the wide/short "horizontal" card
    // shape — the icon badge sits to the left at a fixed size and the
    // title/description sit to its right.
    final double iconBoxSize = widget.isMobile ? 54 : 68;
    final double iconSize = widget.isMobile ? 24 : 30;
    // PASS 28: title and description font sizes increased — SCOPED ONLY
    // TO THE CARD (this is the card's own title/description, never the
    // topbar's title/subtitle in `_buildCustomHeader()`, which stays at
    // its original sizes):
    //   card title:        mobile 16 → 20,   desktop 21   → 26
    //   card description:  mobile 12 → 15,   desktop 13.5 → 16
    final double titleFontSize = widget.isMobile ? 20 : 26;
    final double descriptionFontSize = widget.isMobile ? 15 : 16;
    final double contentPadding = widget.isMobile ? 16 : 24;
    // UI-ENHANCEMENT PASS 2: slim gold top-cap height, matching the Orders
    // screen's stat-card identity strip. Reserved from the card's own fixed
    // height so it never disturbs the existing content layout below it.
    const double topCapHeight = 3;

    // PASS 23: resting-state (non-hovered) card colors, restyled to match
    // the supplied reference screenshot exactly — a flat, soft blush-pink
    // card, a plain pale-rose border, a light-blush icon circle with a
    // thin gold ring, and a muted maroon-brown description tone. All
    // values are still built only from existing `_Palette` fields (via
    // `Color.lerp` or direct field references) — no `_Palette` fields
    // were added, renamed, or removed.
    //
    // PASS 27: these resting colors are now used in BOTH states — the
    // hover color theme was removed, so the card looks the same whether
    // or not the cursor is over it.
    final Color restingBg =
        Color.lerp(_Palette.canvas, _Palette.paleRose, 0.55)!;
    final Color restingBorder = _Palette.paleRose;
    // PASS 24: the resting icon-badge ring is a touch more defined —
    // opacity raised from `0.65` to `0.85` (width bumped below from `1.4`
    // to `1.6`) so the gold outline reads as clear and deliberate, closer
    // to the reference image, instead of a faint hairline. Still built
    // only from the existing `lemonChiffonDeep` field.
    final Color restingIconRing = _Palette.lemonChiffonDeep.withValues(
      alpha: 0.85,
    );
    final Color restingDescriptionColor = Color.lerp(
      _Palette.milanoRedDeep,
      _Palette.textMuted,
      0.55,
    )!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/admin/staff/${widget.role}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget
              .height, // Fixed height passed in by the parent (PASS 11: medium size)
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -6.0))
              : Matrix4.identity(),
          // NOTE: BoxDecoration only ever uses `gradient` here (never mixed
          // with a plain `color`) so both states interpolate cleanly.
          // Mixing color + gradient across the two states is what threw
          // "Cannot provide both a color and a gradient" during the
          // hover animation before this fix.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // PASS 27: the dark maroon hover gradient from PASS 26 was
              // removed — the card background is the same normal resting
              // fill whether hovered or not.
              colors: [
                restingBg,
                restingBg,
              ],
            ),
            borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 26),
            // PASS 27: same normal border in both states (no maroon hover
            // border anymore).
            border: Border.all(
              color: restingBorder,
              width: 1.2,
            ),
            // The hover lift (transform above) and elevated shadow are the
            // only hover effects kept — no color theme change.
            boxShadow: _isHovered ? _Palette.glowShadow : _Palette.softShadow,
          ),
          // The card has a fixed width/height (passed in from the parent so
          // it can be computed responsively). Decorative corner accents now
          // live in a ClipRRect + Stack that is bounded by this exact
          // width/height, so they can bleed right up to the rounded edge
          // without any risk of overflowing outside the card.
          //
          // PASS 5: the main content is a horizontal `Row` (icon badge on
          // the left, an `Expanded` left-aligned `Column` of
          // title/description/hint on the right).
          //
          // PASS 6 — OVERFLOW FIX: that title/description `Column` is
          // now wrapped in a left-aligned `FittedBox` (`BoxFit.scaleDown`).
          // If the card's given height is ever tighter than the content
          // needs (e.g. a very short or narrow device), the content simply
          // scales down proportionally to fit — it can never overflow or
          // throw a "RenderFlex overflowed" error. On any normal-sized
          // screen the content already fits, so nothing visibly changes.
          //
          // PASS 23: a small always-visible trailing chevron was added as
          // a final `Row` child (after the `Expanded` text column) so the
          // card matches the reference image's persistent "›" on the
          // right edge, replacing the old hover-only "Manage →" hint pill.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 26),
            child: Stack(
              children: [
                // ── Decorative corner glow (purely cosmetic) ─────────────
                // PASS 27: constant resting opacity (no stronger glow on
                // hover).
                Positioned(
                  top: -36,
                  right: -36,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.milanoRedDeep.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // UI-ENHANCEMENT PASS 2: slim gold top cap spanning the full
                // width of the card — echoes the Orders screen's stat-card
                // color-coded identity strip. Purely decorative, sits above
                // the corner glows and below the step-index tag.
                //
                // PASS 27: same resting gold cap in both states.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: topCapHeight,
                    color: _Palette.lemonChiffonDeep.withValues(alpha: 0.75),
                  ),
                ),
                // ── Step index tag, flush to the top-left corner ─────────
                // PASS 23: solid dark-maroon fill with white numerals,
                // matching the maroon badge shown in the reference image.
                //
                // PASS 27: same `milanoRedDeep` fill in both states (the
                // darker `milanoRedDarkest` hover fill was removed).
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 11 : 14,
                      vertical: widget.isMobile ? 5 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: _Palette.milanoRedDeep,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.isMobile ? 20 : 26),
                        bottomRight: Radius.circular(widget.isMobile ? 14 : 18),
                      ),
                    ),
                    child: Text(
                      '0${widget.index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: widget.isMobile ? 10 : 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // ── Main content ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    contentPadding + (widget.isMobile ? 6 : 8),
                    contentPadding,
                    contentPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Icon Container (Avatar) ────────────────────────
                      // Gradient-only fill, wrapped in a soft outer ring for
                      // a more premium "badge" look.
                      //
                      // PASS 23: light blush tint with a `lemonChiffonDeep`
                      // gold ring.
                      //
                      // PASS 24: a more defined gold ring (see
                      // `restingIconRing` above), an always-on soft shadow
                      // so the badge reads as raised/professional, and a
                      // faint inner highlight ring for a subtle embossed
                      // finish.
                      //
                      // PASS 25: the fill is a radial gradient built only
                      // from the existing `dustyBlush`/`paleRose` `_Palette`
                      // fields so the icon circle reads as the same blush-
                      // pink family as the rest of the card. The inner
                      // highlight ring is a semi-transparent white
                      // (`alpha: 0.55`).
                      //
                      // PASS 27: the hover styling of this badge (dark
                      // maroon fill, white glyph, gold-on-dark ring, no
                      // inner ring, maroon glow shadow) was removed — the
                      // badge looks the same whether hovered or not.
                      Container(
                        // Always-on soft shadow beneath the badge — a warm
                        // gold glow plus a faint neutral drop shadow — so
                        // the avatar reads as a raised, polished badge.
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _Palette.lemonChiffonDeep
                                  .withValues(alpha: 0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(widget.isMobile ? 5 : 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: restingIconRing,
                              width: 1.6,
                            ),
                          ),
                          child: Container(
                            // PASS 24: thin inner highlight ring — a very
                            // faint white stroke just inside the gold ring
                            // — purely for polish, giving the avatar a
                            // subtle "embossed" edge like a printed badge.
                            // PASS 25: softened to `alpha: 0.55`.
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.55,
                                ),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(1.5),
                            child: Container(
                              width: iconBoxSize,
                              height: iconBoxSize,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.topLeft,
                                  radius: 1.3,
                                  colors: [
                                    _Palette.dustyBlush,
                                    _Palette.paleRose,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    widget.isMobile ? 16 : 20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _Palette.lemonChiffonDeep
                                        .withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: _Palette.milanoRedDeep,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: widget.isMobile ? 16 : 22),
                      // ── Title + description, left-aligned ──────────────
                      // PASS 6: wrapped in `Align` + `FittedBox` so this
                      // block scales down instead of overflowing if the
                      // card's given height/width is ever tighter than the
                      // content needs. Same content, same order, same
                      // styling — only a safety wrapper was added.
                      //
                      // PASS 23: the underline `_TitleDivider` beneath the
                      // title was replaced with a short vertical maroon
                      // accent bar placed to the LEFT of the title text
                      // (the "| Billing Staff" look from the reference
                      // image). The hover-only "Manage →" hint pill that
                      // used to sit below the description has been
                      // removed from this column entirely — its always-
                      // visible replacement (a plain trailing chevron) now
                      // sits as its own item at the end of the outer Row,
                      // matching the reference image's persistent "›" on
                      // the card's right edge.
                      //
                      // PASS 27: title, accent bar, and description use
                      // their normal resting colors in every state (no
                      // white-on-hover text anymore).
                      //
                      // PASS 28: a `LayoutBuilder` (around plain widgets
                      // only — nothing animated is built inside it) now
                      // hands the text column its real available width via
                      // a `SizedBox`, so the description wraps at the new
                      // larger font size instead of being shrunk onto one
                      // long line by the `FittedBox`. The `FittedBox`
                      // stays as the same overflow safety net as before.
                      // This affects only the card's own title/description
                      // — the topbar in `_buildCustomHeader()` is untouched.
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 3,
                                            height: titleFontSize * 0.85,
                                            decoration: BoxDecoration(
                                              color: _Palette.milanoRedDeep,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          SizedBox(
                                              width: widget.isMobile ? 7 : 9),
                                          Flexible(
                                            child: Text(
                                              widget.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                color: _Palette.milanoRedDeep,
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: widget.isMobile ? 8 : 10),
                                      // ── Description ─────────────────
                                      // PASS 26: on mobile, the description
                                      // is always solid black for a
                                      // clearer, more professional look on
                                      // small screens.
                                      //
                                      // PASS 27: on desktop it now stays
                                      // the normal resting color/weight
                                      // (`restingDescriptionColor`,
                                      // `w500`) even while hovered.
                                      //
                                      // PASS 28: mobile `maxLines` is `3`
                                      // (was `2`) so the larger, wrapped
                                      // text is never cut off with "…".
                                      Text(
                                        widget.description,
                                        maxLines: widget.isMobile ? 3 : 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: widget.isMobile
                                              ? Colors.black
                                              : restingDescriptionColor,
                                          fontSize: descriptionFontSize,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: widget.isMobile ? 8 : 12),
                      // ── Trailing chevron ───────────────────────────────
                      // PASS 23: always visible (not tied to `_isHovered`)
                      // so it matches the persistent "›" shown on every
                      // card in the reference image, and so touch-device
                      // users — who never trigger hover at all — still see
                      // the affordance. No callback lives here; the whole
                      // card's `onTap` above is what performs the actual
                      // navigation, exactly as before.
                      //
                      // PASS 27: same normal resting color in every state.
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _Palette.milanoRedDeep,
                        size: widget.isMobile ? 24 : 28,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (widget.index * 200).ms).scale(
              begin: const Offset(0.95, 0.95),
              curve: Curves.easeOutCirc,
            ),
      ),
    );
  }
}
