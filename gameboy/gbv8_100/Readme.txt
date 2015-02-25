  ____   ____.___   _________.___ ________    _______              ______
  \   \ /   /|   | /   _____/|   |\_____  \   \      \            /  __  \
   \   Y   / |   | \_____  \ |   | /   |   \  /   |   \   ______  >      <
    \     /  |   | /        \|   |/    |    \/    |    \ /_____/ /   --   \
     \___/   |___|/_______  /|___|\_______  /\____|__  /         \______  /
                          \/              \/         \/                 \/
                            ________ __________
                           /  _____/ \______   \
                          /   \  ___  |    |  _/
                          \    \_\  \ |    |   \
                           \______  / |______  /
                                  \/         \/

                        ******* Vision-8 GB *******

                                Version 1.0
                       by Haroldo de Oliveira Pinheiro
                                  based on
                    Vision-8 - The Portable CHIP8 Emulator
                            by Marcel de Kogel

=============================================================================

 1. Introduction:
        Vision-8 GB is a port of the Vision-8 chip-8 emulator for the 
      GameBoy and GameBoy color. I know that there's already another
      similar chip-8 emulator available for this console, but mine is
      better! 8-)

 2. What it has:
      - Chip-8 emulation based on Vision-8 emulation core;
      - The games are stored on the cartridge's battery-backed RAM, instead
      of the ROM. That way, you DON'T need to alter the ROM-image in order
      to add or remove chip-8 games;
      - Up to seven chip-8 games can be stored on the battery-backed RAM;
      - GB link cable support: GameBoy users can exchange chip-8 games 
      through GB's game link cable;
      - A pretty graphical interface 8-) ;
      - Chip-8 keypad mappings can be set individually for each game;
      - Color GameBoy support;
      - Runs perfectly on most GameBoy emulators.

 3. What it lacks:
      - Super Chip-8 support;
      - More stable serial communication code: sometimes the emulator 
      locks-up while transmitting data through the game link cable;
      - It was never tested on a real GameBoy!

 4. Things planned for the future:
      - Add Super Chip-8 support;
      - Include a built-in icon editor, so that each game can have its own
      individual icon;
      - Include a built-in wallpaper editor, so that the user can use its 
      own wallpapers, besides the ones that are included with the emulator;
      - Improve the serial communication code;
      - Include a color scheme editor, so users can "colorize" the chip-8
      games, just like some Vectrex emulators do;
      - Test this program on a real GameBoy (It should work okay, but who
      knows...).

 5. How to use it:
      - Use the MAKESAV utility to build a battery-backed RAM image with the
      games you want, or just use the one that is included with this ZIP;
      - Copy the .SAV file created that way to the directory where your
      GameBoy emulator stores the battery-backed RAM (no$gmb stores it on
      the .\BATTERY subdirectory. VGB generally stores it on the same
      directory where your ROM image is.);
      - Run the .GB file on your favorite emulator;
      - Of course, you could also burn it to a ROM and use it on a real
      GameBoy, but you should remember that it uses the battery-backed RAM to
      store the chip-8 games.

 6. Special thanks to:
      - Pascal Felber and Michael Hope, for creating GBDK;
      - Jeff Frohwein, for its outstanding GameBoy technical page;
      - Marcel de Kogel, for releasing the source for his Vision-8 chip-8
      emulator;
      - Anders Granlund, for his GB-Chip8 emulator, even though I couldn't
      get it to work on any GB emulator 8-) ;
      - Pan of -ATX-, for its excellent documentation about GameBoy;
      - Anyone else I may have forgotten.

 7. How to contact me:
      - my email is haroldo-o-p@bol.com.br
