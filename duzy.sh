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
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

cd /etc/init.d
FILES=(*)
OPTIONS=("start" "stop" "status")
EXIT=0
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
	echo "-o status|start|stop	tryb ze zdefiniowaną opcją"
	echo ""
	echo "Więcej informacji znajduje się w manualu (man duzy)."
}
main() {
	while [ $EXIT -eq 0 ]
	do
		ODP=`zenity --list --column=Demony "${FILES[@]}" --height 500`
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
while getopts ':hvo:' OPTS
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
				main
			else
				echo "Argument ${OPTARG} jest nieprawidłowy."
				abnormal
				exit 1
			fi
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
main
