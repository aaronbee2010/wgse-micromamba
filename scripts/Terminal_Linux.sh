#!/usr/bin/env bash
#
# WGS Extract terminal emulator startup script for Linux operating systems
# Copyright (C) 2022 Randolph Harr
#
# License: GNU General Public License v3 or later
# A copy of GNU GPL v3 should have been included in this software package in LICENSE.txt
#
# No forced internal call dummy parameter present as this is only used in
# directly called Linux scripts to start a new terminal emulator window.

# Self-aborts if not being run on a 64-bit x86 Linux system, starts a new terminal window otherwise.
# If this script is executed by another, then the remainder of that script will run in a new window.
case ${OSTYPE} in
linux* )    
    echo "Linux (64-bit x86) detected."
    echo ""
    
    # If not in a Terminal, start one so questions can be answered. Unfortunately Ubuntu window managers
    # do not allow you to set the terminal as the default way to open a shell script.
    # Hints at https://unix.stackexchange.com/questions/233206/ , https://askubuntu.com/questions/72549/ , 
    # https://askubuntu.com/questions/46627/
    if [ ! -t 1 ]; then
        # Determine command needed to initiate installation script from bash PPID.
        # This is similar to the method "neofetch" uses to find the terminal in which it is run.
        TERM=$(ps -p ${PPID} -o comm=)
        if [[ ${0::1} == "/" ]] ; then CMD="$0" ; else CMD="./$0" ; fi
        # Find the terminal this script is being run in, so we can start a new window with the same terminal.
        case ${TERM} in
        gnome-terminal- )        # Terminal bundled with GNOME, GNOME Flashback and Cinnamon.
            gnome-terminal -- ${CMD}
            ;;
        konsole | yakuake )      # Konsole is bundled with KDE Plasma. Yakuake is a drop-down terminal based on Konsole which is available
            konsole -e ${CMD}    # via KDE Discover. Yakuake cannot execute commands so Konsole runs remainder of script if Yakuake is detected.
            ;;
        kitty | st )             # These terminals are usually installed separately, particularly in minimalist desktops using tiling window
            ${TERM} ${CMD}       # managers (i.e. i3, bspwm, dwm) as opposed to full desktop environments (i.e. GNOME, KDE Plasma, Xfce4).
            ;;
        sakura )
            ${TERM} -x ${CMD}    # Minimal terminal without many required dependencies. Usually installed seperately.
            ;;
        xfce4-terminal | mate-terminal | tilix | qterminal | deepin-terminal | lxterminal | \
        termit | roxterm | guake | alacritty | xterm | rxvt | urxvt | mlterm | terminator )
            ${TERM} -e ${CMD}    # Miscellaneous terminals bundled with other desktop environments tested as well as popular terminals used in minimalist desktops.
            ;;                   # There are plenty of other terminals out there, but these are the ones I've seen the most. I may add other terminals in the future
                                 # but the selection here (and also the fallback command below) should suffice for almost everyone using this install script.
        * )
            x-terminal-emulator -e ${CMD} # Fallback command for terminals not found above.
            ;;
        esac
        exit 0 # Close this script/job as a new terminal window is running.
    fi
    ;;
darwin* )
    echo "ERROR: Sorry, but this installation script only works with Linux on 64-bit x86 architectures at the moment."
    echo "       Please try the macOS installer instead."
    echo ""
    echo "Aborting now."
    sleep 2
    echo ""
    exit 1
    ;;
msys* | cygwin* )
    echo "ERROR: Sorry, but this installation script only works with Linux on 64-bit x86 architectures at the moment."
    echo "       Please try the Windows installer instead."
    echo ""
    echo "Aborting now."
    sleep 2
    echo ""
    exit 1
    ;;
* )
    echo "ERROR: Unknown OSTYPE of ${OSTYPE}."
    sleep 2
    exit 1
    ;;
esac

clear # Should now be in new terminal window by the time this command executes.
