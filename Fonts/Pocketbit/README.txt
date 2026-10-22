Pocketbit v1.0 - pixel font
by fcidade

Thanks for downloading! License: see LICENSE.txt (commercial use allowed).


FILES

  Pocketbit.ttf
      TrueType font. Crisp at 9px and its multiples (9, 18, 27...).

  Pocketbit.fnt
      BMFont (text format), uses Pocketbit.png. Works in Godot, Phaser, LOVE,
      MonoGame, libGDX, Defold and others.

  Pocketbit.png
      Spritesheet: white glyphs on transparent background, 16 per row,
      8x9px cells. Tint it any color in your engine.

  Pocketbit-chars.txt
      The characters in the spritesheet, in order.


CHARACTER SET

  196 glyphs: ASCII, Latin-1 and the euro sign. Covers English, Portuguese,
  Spanish, French, German, Italian and most Western European languages.


QUICK START

  Godot 4
    BMFont: put Pocketbit.fnt and Pocketbit.png in the same folder of your project
    (the .fnt needs the .png next to it) and use the .fnt as the font of
    a Label.
    TTF: in the .ttf import settings set Antialiasing to None and
    Subpixel Positioning to Disabled, then use font size 9 or a multiple.

  Unity
    Import Pocketbit.ttf and use a font size that is a multiple of 9. Set the
    font texture filter to Point (no filter) to keep the pixels sharp.

  GameMaker
    Import Pocketbit.png as a sprite strip (196 frames, 16 per row,
    8x9 each), then create the font with font_add_sprite_ext(),
    passing the contents of Pocketbit-chars.txt as the string map.

  Anything else
    Use the .ttf at 9px or a multiple, with antialiasing / smoothing off.
