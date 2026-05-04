#!/bin/sh

# Terminal graphics reference script

# There are many ANSI code reference pages online that say things like "red is
# color number 31", but this one actually displays colors in your terminal
# exactly as they would appear.

# TODO include some helpful unicode block/arrow/shape characters in addition to just colors

BOLD='\e[1m'
CLEAR='\e[0m'

# 'echo' will not apply escape sequences unless you give it '-e'

# \e  \x1b  \033  \u001b are some common ways to indicate an escape sequence, try them until one works

# echo -e "\e[0;1;34m \\e can be used"
# echo -e "\x1b[0;1;34m as can \\x1b"

echo -e $CLEAR

echo -e 'Think of ANSI escape codes like functions, but the name is at the end and semicolons are used instead of commas:'
echo -e $BOLD'\\e[0;1;34m'$CLEAR' is like a function '$BOLD'm(0, 1, 34)'$CLEAR
# echo -e "\e[0;1;34m"'Looks like this'$CLEAR

echo ''

echo "Remember that your terminal might not support all of these (or even if it does, you might have them disabled in your terminal settings)"
echo '0 turns everything off'
echo -e "\e[1m"'\\e[1m Bold'$CLEAR
echo -e "\e[2m"'\\e[2m Faint'$CLEAR
echo -e "\e[3m"'\\e[3m Italic'$CLEAR
echo -e "\e[4m"'\\e[4m Underline'$CLEAR
echo -e "\e[5m"'\\e[5m Blinking'$CLEAR
echo -e "\e[7m"'\\e[7m Reverse'$CLEAR
echo -e "\e[8m"'\\e[8m Hidden'$CLEAR
echo -e "\e[9m"'\\e[9m Strikethrough'$CLEAR
echo ''

echo '30-37 represent basic colors:'
echo -en "\e[30m"'30 '$CLEAR
echo -en "\e[31m"'31 '$CLEAR
echo -en "\e[32m"'32 '$CLEAR
echo -en "\e[33m"'33 '$CLEAR
echo -en "\e[34m"'34 '$CLEAR
echo -en "\e[35m"'35 '$CLEAR
echo -en "\e[36m"'36 '$CLEAR
echo -en "\e[37m"'37 '$CLEAR
echo -en "\e[39m"'39/Default'$CLEAR
echo ""

echo '40-47 are also basic colors but for the background:'
echo -en "\e[40m"'40 '$CLEAR
echo -en "\e[41m"'41 '$CLEAR
echo -en "\e[42m"'42 '$CLEAR
echo -en "\e[43m"'43 '$CLEAR
echo -en "\e[44m"'44 '$CLEAR
echo -en "\e[45m"'45 '$CLEAR
echo -en "\e[46m"'46 '$CLEAR
echo -en "\e[47m"'47 '$CLEAR
echo -en "\e[49m"'49/Default'$CLEAR
echo ""

echo ""
echo -e "\e[1;35;44m" '\\e[1;35;44m' 'Combined bold, 35 front, 44 back'$CLEAR
echo "On some terminals, the 'bolded' version of a color looks slightly brighter)"
echo ""

echo "The 'watch' command doesn't handle all colors correctly, even with -c"
echo ""
echo "Also note that most effects and colors can be individually disabled, but I find it easy enough to just clear all effects and re-set the ones I want"
echo ""

echo -n "8-bit colors use 38;5 (foreground) or 48;5 (background):"
echo -en "\e[38;5;0m" # (set foreground to black for readability)
i=0
for i in $(seq 0 255); do
    if [ $(( i % 32 )) -eq 0 ]; then
        echo ''
    fi
    echo -en "\e[48;5;${i}m" "x"
    echo -en $CLEAR
    i=$(( $i + 1 ))
done
echo ""
