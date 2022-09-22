# duzy_skrypt - university project
This script allows to start, stop and see status of daemons from /etc/init.d/ directory using zenity graphic interface and getopts.
# Options
- -d - text interface
- -o - setting operation for entire duration of the script
- -h - help
- -v - version

Using option -h will display help for the user, option -v - current version of the script.

Using option -o with argument (start|stop|status) will set operation for the duration of the program.

If option -d is used before -o, the graphical interface will not appear.

Option -d starts the script in text-mode, its argument is daemon's name.
