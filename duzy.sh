#!/bin/bash
# Author           : Konrad Bryłowski ( s188577@student.pg.edu.pl )
# Created On       : 2022-06-13
# Last Modified By : Konrad Bryłowski ( s188577@student.pg.edu.pl )
# Last Modified On : 2022-06-13
# Version          : 1306
#
# Description      :
# This script allows to start, stop and see status of daemons from /etc/init.d/ directory using zenity graphic interface.
# Using option -h will display help for the user, option -v - current version of the script.
# Using option -o with argument (start|stop|status) will set operation for the duration of the program.
# If option -d is used before -o, the graphical interface will not appear.
# Option -d starts the script in text-mode, its argument is daemon's name.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

cd /etc/init.d
FILES=(*)
OPTIONS=("start" "stop" "status")
EXIT=0
DEMON=""
VERSION=1306
OPCJA=""

abnormal() {
	echo "Uruchom skrypt z opcją -h w celu wyświetlenia pomocy."
	exit 1
}
pomoc() {
	echo "Pomoc dla $0"
	echo "Składnia: duzy.sh [OPCJA]"
	echo "Program pozwala na uruchamianie, zatrzymywanie i wyświetlanie statusu demonów z katalogu /etc/init.d/ za pomocą środowiska graficznego zenity."
	echo "Jeżeli nie zostanie podana opcja -o program będzie pytał jaką operację wykonać przy każdym wybraniu demona."
	echo ""
	echo "Opcje:"
	echo "-h			wyświetl pomoc"
	echo "-v			wyświetl wersję"
	echo "-d DEMON			tryb tekstowy, na podanym DEMON zostanie wykonana operacja ustawiona w opcji -o, której użycie w tym trybie jest wymagane"
	echo "-o status|start|stop	tryb ze zdefiniowaną opcją"
	echo ""
	echo "Więcej informacji znajduje się w manualu (man duzy)."
}
main() {
	if [[ -n $OPCJA ]]
	then
		TEXT="Tryb: $OPCJA"
	else
		TEXT="Wybierz z listy"
	fi
	while [ $EXIT -eq 0 ]
	do
		ODP=`zenity --list --text "$TEXT" --column=Demony "${FILES[@]}" --height 500 --width 250`
		if [ $? -ne 1 ]
		then
			if [ -z $ODP ]
			then
				zenity --error --text "Nie wybrano żadnej opcji"
			else
				if [ -z $OPCJA ]
				then
					OPCJA=`zenity --list --text "Opcje start i stop wymagają uprawnień administratora" --column=Opcje "${OPTIONS[@]}" --height 370`
					if [ -z $OPCJA ]
					then
						RESULT="Nie wybrano żadnej opcji"
					elif [ $? -eq 0 ]
					then
						RESULT=""
					else
						RESULT=`./$ODP $OPCJA`
						OPCJA=""
					fi
				else
					RESULT=`./$ODP $OPCJA`
				fi
				if [[ -n $RESULT ]]
				then
					zenity --info --title "Wynik operacji" --text "$RESULT"
				fi
			fi
		else
			zenity --info --title "Komunikat" --text "Anulowano"
			EXIT=1
		fi
	done
}
while getopts ':hvo:d:' OPTS
do
	case ${OPTS} in
		"h")
			pomoc
			exit
			;;
		"v")
			echo "$0 wersja $VERSION"
			exit
			;;
		"o")
			OPCJA="${OPTARG}"
			if [ $OPCJA = "stop" ] || [ $OPCJA = "start" ] || [ $OPCJA = "status" ]
			then
				if [ -z $DEMON ]
				then
					main
				fi
			else
				echo "Argument ${OPTARG} jest nieprawidłowy."
				abnormal
				exit 1
			fi
			;;
		"d")
			DEMON="${OPTARG}"
			;;
		:)
			echo "Opcja -${OPTARG} wymaga argumentu"
			abnormal
			exit 1
			;;
		*)
			echo "Niespodziewana opcja"
			abnormal
			exit 1
			;;
	esac
done
if [[ -n $DEMON ]] && [[ -z $OPCJA ]]
then
	echo "Użycie opcji -d wymaga użycia opcji -o"
	abnormal
	exit 1
elif [[ -n $OPCJA ]] && [[ -n $DEMON ]]
then
	if printf '%s\0' "${FILES[@]}" | grep -Fxqz "$DEMON"
	then
		RESULT=`./$DEMON $OPCJA`
		echo $RESULT
		exit 0
	else
		echo "Plik $DEMON nie istnieje"
		abnormal
		exit 1
	fi
fi
main
