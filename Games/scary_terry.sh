#!/bin/bash
#This is Jigsaw puzzel like game in order to play it please install this:
#sudo apt install espeak
#This is in order to feel the full experience
#Let's plat a game?
echo -n "Let's play " && espeak "Let's play" && echo "a game?" && espeak "a game"
clear
sleep 1
#If you guess a number between 1 and 10 you win!
echo -n  "If you " && espeak "If you" && echo -n "guess a number " && espeak "guess a number"  && echo -n "between " && espeak "between" && echo -n "1 and 10 " && espeak "one and ten" && echo "you win!" && espeak "you win"
clear
#Else you get everything taken from you!!
echo -n "Else you " && espeak "Else you" && echo -n "get " && espeak "get" && echo -n "everything taken " && espeak "everything taken" && echo "from you !!!" && espeak "from you" && espeak "haha"
clear
sleep 2
#Do you want to play?
echo -n "Do you " && espeak "Do you" && echo "want to play?" && espeak "want to play"
echo "yes or no"
read answer
clear
sleep 2
if [[ $answer == "no" ]]; then
        echo "Goodbye" && espeak "goodbye"
elif [[ $answer == "yes" ]]; then
        echo -n "Guess a " && espeak "Guess a" && echo -n "number between " && espeak "number betwenn" && echo "1 and 10:" && espeak "one and ten"
        read number
        sleep 5
        random_number=$(shuf -i 1-10 -n 1)
        if [[ number -eq random_number ]]; then
               echo " You win! " && espeak "You win" && echo "Goodbye" && espeak "Goodbye"
        else
               echo "You loose it was $random_number :( " && espeak " You loose it was $random_number"
               for ((i=10;i>=1;i--)) ; do
                       echo "$i.."
                       espeak "$i"
                       clear
                       sleep 1
               done
               echo "BOOM" && espeak "haha" && espeak "BOOM"
               reboot now
        fi
fi
