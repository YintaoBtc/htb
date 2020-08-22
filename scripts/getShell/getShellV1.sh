#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables globales
declare -a local_path
declare -r my_path="/usr/local/bin:/usr/bin:/bin:/usr/games" # Read only

trap ctrl_c INT

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo...${endColour}"
    exit 1
}

function helpPanel(){
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: .getShell.sh${endColour}\n"
    echo -e "\t${purpleColour}u)${endColour}${yellowColour} Dirección URL${endColour}"
}

function obtainShell(){
    for path in $(echo $my_path | tr ':' ' '); do
        echo "Estamos con el path $path"
    done
}

# Main Function
declare -i parameter_counter=0; while getopts ":u:h:" arg; do
    case $arg in 
        u) url=$OPTARG; let parameter_counter+=1 ;;
        h) helpPanel;;
    esac 
done

if [ $parameter_counter -ne 1 ]; then
    helpPanel
else
    obtainShell
fi
