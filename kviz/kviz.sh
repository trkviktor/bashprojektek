#!/bin/bash

#változók
kviz_fajl=kviz.txt
pontok=0
N=5
x=0

if [[ $* != "" ]] && [[ "$*" != "-h" ]]
then
    printf "\t${0##*/} Nem felismerhető flag: $*\n"
	printf "\tHasználat: ${0##*/} [h]"
	exit 0
fi


#-h help funkció
if [[ $* = "-h" ]]
then
    printf "\tHasználata: ${0##*/} [OPCIÓ]\n"
    printf "\tSzimpla 5 kérdéses kvíz ranglistával\n\n"

	printf "\tkviz.txtbe formátum:\n"
	printf "\tsorszám(0-9) kérdés# #1.válasz #2.válasz #3.válasz #4.válasz #megoldás"
    exit 0
fi

#kvíz fájl ellenőrzése
if [ ! -f $kviz_fajl ]
then
    echo "A kvíz fájl nem létezik."
    exit 1
fi

clear

#random kérdések generálása
random=( $(seq 1 9 | shuf) )
randomkerdes=( $(seq 0 3 | shuf) )
betuk=("a" "b" "c" "d")


echo "Kvíz játék 1.0
"

#a kód magja
while [ $N -gt 0 ]
do
	#random sor beolvasása majd adatok eltárolása
	line=`grep ${random[$x]} kviz.txt`
	kerdes=`echo $line | cut -d'#' -f1 | cut -c2-`
    dontes1=`echo $line | cut -f3 -d'#'`
    dontes2=`echo $line | cut -f4 -d'#'`
    dontes3=`echo $line | cut -f5 -d'#'`
	dontes4=`echo $line | cut -f6 -d'#'`
    megoldas=`echo $line | cut -f7 -d'#'`

#betűmegoldás(a,b,c vagy d) átírása a tényleges megoldásra
case $megoldas in

	a)
    megoldas=$dontes1
    ;;

	b)
    megoldas=$dontes2
    ;;

	c)
    megoldas=$dontes3
    ;;

	d)
    megoldas=$dontes4
    ;;

	*)
    echo -n "Ismeretlen";;
esac

	dontesek=("$dontes1" "$dontes2" "$dontes3" "$dontes4")
	valaszok=()

    echo "$kerdes?"

	#válaszok összekeverése 2 tömb segítségével(randomkerdes,dontesek)
	z=0

	#kérdések kiíratása
	for i in `seq 0 3`
	do
		y=${randomkerdes[$z]}
		echo "- ${betuk[$i]})${dontesek[$y]}"
		z="$(($z+1))"
		valaszok+=("${dontesek[$y]}")
		
	done

	#ellenőrzött beolvasás
    read -p "- Választásod: " valasztas
	ok=0
	while [ $ok -eq 0 ]
	do
		if [[ $valasztas =~ ^[a-dA-D]{1}$ ]];
		then
			ok=1
		else
			echo "Helytelen input.(Max 1 karakter [a-D]"
			read -p "- Választásod: " valasztas
		fi
	done

#betűválasz átírása a tényleges válaszra
case $valasztas in

	a)
    valasztas="${valaszok[0]}";;

	b)
    valasztas="${valaszok[1]}";;

	c)
    valasztas="${valaszok[2]}";;

	d)
    valasztas="${valaszok[3]}";;

	*)
    echo -n "Ismeretlen";;
esac

	echo $valasztas
    
	#válasz ellenőrzés
    if [ "$valasztas" == "$megoldas" ]
    	then
        	pontok=$(( ++pontok ))
        	echo "Helyes válasz!"
    	else
      	  	echo "Rossz válasz, a megoldás: $megoldas"
   	fi

	
	N="$(($N-1))"
	x="$(($x+1))"
done


#pontoktól függően névbekérés és tárolás
if [ $pontok -eq 5 ]
then
	echo "Gratulálunk! Ön nyert! Írja be a nevét, hogy felkerülhessen a győztesek falára!"
	read -p "" nev
	#ellenőrzött beolvasás
	ok=0
	while [ $ok -eq 0 ]
	do
		if [[ $nev =~ ^[a-zA-Z0-9]{1,9}$ ]];
		then
			ok=1
		else
			echo "Helytelen input.(Max 9 karakter [a-Z0-9]"
			read -p "" nev
		fi
	done
	echo "Kedves $nev! Felkerült a győztesek falára maximális ponttal!"
	#pontok elmentése temp.txtbe
	printf "%s\n" >> temp.txt
	printf "%-10s" "$nev" "$pontok" "igen" >> temp.txt
else
	echo "Gratulálunk! Ön nem nyert! Írja be a nevét, hogy felkerülhessen a szégyenfalra!"
	read -p "" nev
	#ellenőrzött beolvasás
	ok=0
	while [ $ok -eq 0 ]
	do
		if [[ $nev =~ ^[a-zA-Z0-9]{1,9}$ ]];
		then
			ok=1
		else
			echo "Helytelen input.(Max 9 karakter [a-Z0-9]"
			read -p "" nev
		fi
	done
	echo "Kedves $nev! Felkerült a vesztesek falára $pontok ponttal!"
	#pontok elmentése temp.txtbe
	printf "%s\n" >> temp.txt
	printf "%-10s" "$nev" "$pontok" "nem"  >> temp.txt
	
fi	

#ranglista elmentése és rendezése a ranglista.txt fájlba egy temp.txt segítségével
awk 'NR==1{print; next} {print | "sort -k2,2gr"}' temp.txt > ranglista.txt