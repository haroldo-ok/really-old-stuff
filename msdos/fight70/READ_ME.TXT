
                             FIGHTX GAME SYSTEM v0.67
                          by Haroldo de Oliveira Pinheiro

                                 INSTRUCTION MANUAL


    This is the instruction manual for FIGHTX v0.67, fighting game creation
system. It is not what I would call a "definitive manual", but I'm a
programmer, not a writer.

    0. Basical Instructions

        This section contains only the minimum instructions needed to play the
    game.

        0.1. Starting the game

            To run the game, just go into MS-DOS prompt, change to the
        directory where the game is installed, and type FIGHT. The game should
        run immediately. If you prefer using Windows, simply run the executable
        FIGHT.EXE

        0.2. Sound

            The program searches for the BLASTER environment variable to see if
        you have a Sound Blaster installed on your computer. If it doesn't find
        it, the game will run with no sound. What? You don't know what's the
        BLASTER environment variable? Windows is sucking your brain, my friend!

        0.3. Controls

            The current version of FIGHTX only recognizes keyboard commands.
            The keyboard mappings are:

            Command          Player 1 Keys         Player 2 Keys

            Up               Up arrow              U
            Down             Down arrow            J
            Left             Left arrow            H
            Right            Right arrow           K
            Punch            Control               S
            Kick             Alt                   D

            In a future version I may include a keyboard configuration utility
        or even joystick support, but that's not a priority at the moment.


        0.4. Playing

            Once you start the game, it should spend some time loading some
        data, and then it will present you the title screen. Once on the title
        screen, press Enter. Then you'll be taken to the fighter selection
        screen. Select your fighter, and then press the punch button. If a
        second player wants to join the fight, all it has to do is to press
        its punch button.
            After you select your fighter, the program sould take some more
        time loading data, and then you will enter on the fight itself. To
        jump, move up, to duck, move down, and to defend, move to the opposite
        direction of where your enemy is. The Punch and Kick buttons activate
        your punch and your kick, obviously. To perform the special attacks,
        use directional sequences followed by punch or kick (if you ever
        played any fighting game, you'll know what i'm talking about).

    1. Customizing FIGHTX game system

        The FIGHTX game system is more than a simple game: it's a complete
    system for creating fighting games! You can easily add your own graphics,
    your own music, your own sound, and your own fighters to the game. In a
    nutshell: you can make your own fighting game! This chapter explains
    exactly how to do it.

        1.1. The interface

            BKGND.PCX -> Contains the graphics used on the fighting interface
            CONSOLE.PCX -> It's the wallpaper for the game's console
            TITLSMAL.PCX -> The title that appears at the top of the console
            TITLBIG.PCX -> The game's title screen
            TIT_BKGD.PCX -> The title screen wallpaper
            SEL_BKGD.PCX -> Fighter selection screen wallpaper
            MNTAIN.PCX -> The default fighting scenery just in case your
                       doesn't have its own

            1.1.1. The CREDITS.LST file

                The CREDITS.LST file contains the game credits that apper on
            the title screen

        1.2. The fighters

            The title of this section talks for itself! ;-)

            1.2.1. The FIGHTERS.LST file

                A simple text file, containing a list of the files where
            fighter data is stored.
                IMPORTANT!!! - When FIGHTERS.LST refers to some file, like
            BDROID.FGT, for example, it is pointing to two files: BDROID.FGT
            (the fighter's script) e BDROID.ANS (the fighter's animation).

            1.2.2. The .FGT files

                The FGT files are text-files containing the fighter definition
                script. Its main commands ar:

                #name <name of fighter>
                    Contains the name of the fighter

                #stand <image.pcx> <X offset> <Y offset>
                    Contains the images of the fighter on a standing position.
                  The offsets are there to adjust the position of the image's
                  center.

                #defend <image.pcx> <X offset> <Y offset>
                    Image of the fighter's defending position

                #dodge <image.pcx> <X offset> <Y offset>
                    Image of the fighter on dodging position

                #duck <image.pcx> <X offset> <Y offset>
                    Image of ducking fighter

                #jumpup <image.pcx> <X offset> <Y offset>
                    Image of the raising phase of the fighter's jump

                #jumpfall <image.pcx> <X offset> <Y offset>
                    Image of the falling phase of the fighter's jump

                #hit <image.pcx> <X offset> <Y offset>
                    Imagem of the fighter being hit

                #selface <image.pcx> <X offset> <Y offset>
                    Image of the fighter on the fighter selection screen

                #selicon <image.pcx>
                    Fighter's selection screen icon

                #bgmusic <music.mod>
                    The fighter's music

                #background <background.pcx>
                    The fighter's scenery

                #attack <sequence>
                    param1
                    param2
                    .
                    .
                #end
                    Defines the fighter's attack. The sequence indicates which
                  sequence of commands will activate which attack. The numbers
                  represent directions (look at your numeric keypad), while P
                  and K represent Punch and Kick. WARNING: Due to the way the
                  program scans the attack list, the longer sequences should
                  come first, or it won't work correctly.
                    The parameters for the attack command are:

                      anim <anim name>
                          Indicates the name of the animation that represents
                        the attack. See below for the animation script
                        structure.

                      damage <how much>
                          Indicates the damage caused by the attack

                      power <energy>
                          Indicates how much energy the attack consumes

                      aerial
                          If present, indicates that the attack is aerial

                      midair
                          If present, indicates that the attack can only be
                        used during a jump

        1.3. The animations

            This section explains the structure of the animation scripts used
        by the game.

            1.3.1. Sprites

                The animation system used on FIGHTX is sprite-based. A sprite
            is an image with transparent parts, that can be freely moved on
            the screen
                A sprite is defined on the following way:

                #sprite <name of sprite>
                    image <image.pcx> (<X>,<Y>[,<Z>])
                    colors <number of colors> [<remap to>]
                #end

                    <image.pcx> indicates the name of the file which contains
                  the sprite's image
                    X,Y and Z are coordinates used to adjust the sprite's
                  center
                    colors indicates how many colors ere effectively used on
                  the file, and to which colors they should be remapped. This
                  way, colors 64 128 means that the colors 0 to 63 should be
                  remapped to colors 128 to 191, and all the other colors
                  should be remapped to 0 (transparent color)

            1.3.2. Sprite sequences

                Sprite sequences are just an sequence of sprites that are
            shown sequentially, one after the other.
                They're defined on the following way:

                #spriteseq <sprite sequence name>
                    frame <sprite 1> <delay 1>
                    frame <sprite 2> <delay 2>
                    .
                    .
                #end

                    <sprite> indicates the name of the sprite to show.
                    <dura‡Æo> Indicates for how many 1/100th seconds the
                  sprite will be shown before going to the next one. After
                  showing the last sprite, the sequence will return to the
                  first one.

            1.3.3. Animations

                Finally, we come to the most important part: the animation
            itself.
                An animation is defined on the following way:

                #anim <animation name> <length>
                    command1
                    command2
                    command3
                    .
                    .
                #end
                    <length> is given in 1/100th of second.

                The commands that can be used on an animation are:
                 
                place <sprite name> <(X,Y,Z)> [<when>]
                    Moves a sprite to a given position, at a given time

                path <sprite name> <end time> <start time> <(X,Y,Z)> [<(X,Y,Z)> ...]
                    Moves a sprite smoothly through a series of positions

                show <sprite name> [<when>]
                    Makes a sprite visible at a given time

                hide <sprite name> [<when>]
                    Makes a sprite invisible at a given time

                write <text> <color> <start time> <end time> [<delay>]
                    Writes a text at an given time

                stars <kind> <start> <end> <start color> <(R,G,B)> <end color> <(R,G,B)> <count> <speed>
                    Makes "stars" on the backgorund. The available kinds are:
                        x -> horizontal movement
                        y -> vertical movement
                        z -> zoom
                        n -> as dots
                        v -> as vertical lines
                        h -> as horizontal lines

                flash <start time> <end time> <periode> <(R,G,B)> [<(R,G,B)> ...]
                    Generates a flesh or a series of flashes on the screen

                background <sprite name> <end time> <start time> <(X speed,Yspd,Zspd)> [<(X position,Ypos,Zpos)>]
                    Uses a sprite as a tiled wallpaper


