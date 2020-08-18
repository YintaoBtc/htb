#!/bin/bash

# Author: Marcelo Vázquez (aka S4vitar)

#Colours
declare -r greenColour="\e[0;32m\033[1m"
declare -r endColour="\033[0m\e[0m"
declare -r redColour="\e[0;31m\033[1m"
declare -r blueColour="\e[0;34m\033[1m"
declare -r yellowColour="\e[0;33m\033[1m"
declare -r purpleColour="\e[0;35m\033[1m"
declare -r turquoiseColour="\e[0;36m\033[1m"
declare -r grayColour="\e[0;37m\033[1m"

# Global Variables
declare -r USER_AGENT="User-Agent: htbExplorer"
declare -r url_machines_get_all="https://hackthebox.eu/api/machines/get/all"
declare -r url_global_data="https://www.hackthebox.eu/api/stats/global"
declare -r url_user_id="https://www.hackthebox.eu/api/user/id"
declare -r url_reset_machine="https://www.hackthebox.eu/api/vm/reset/"
declare -r url_shoutbox_messages="https://www.hackthebox.eu/api/shouts/get/initial/html/"
declare -r url_spawned_machines="https://www.hackthebox.eu/api/machines/spawned"
declare -r url_owned_machines="https://www.hackthebox.eu/api/machines/owns"
declare -r url_deploy_machine="https://hackthebox.eu/api/vm/vip/assign/"
declare -r url_stop_machine="https://hackthebox.eu/api/vm/vip/remove/"
declare -r url_extend_machine="https://hackthebox.eu/api/vm/vip/extend/"
declare -r url_assign_machine="https://hackthebox.eu/api/vm/vip/assign/"
declare -r tmp_file="tmp.json"
declare -r API_TOKEN="qYowR3OF13zjgiVP0N6hpKGoxoeKD7PIPauwnn7EoErH6rPSI07sCjGD0Ck4"

trap ctrl_c INT

if [ ! "$API_TOKEN" ]; then
	echo -e "\n${redColour}[!] You have to enter your API TOKEN in the code${endColour}\n"
	exit 1
fi

function banner(){
    echo -e "${greenColour}
                      .
                   %%%%%%%.
               %%%%%%.  %%%%%%.
          %%%%%%           *%%%%%%.
       %%%%%                   .%%%%%%
       %%%%%%%%               %%%%%%%%
       %%   %%%%%%%      .%%%%%%%  %%%
       %%       #%%%%%%%%%%%#      %%%    ${endColour}${grayColour}htbExplorer - HackTheBox Terminal Client${endColour}${greenColour}
       %%           %%%%#          %%%    ${endColour}${blueColour}\t\t\t     by S4vitar${endColour}${redColour} <3${endColour}${greenColour}
       %%            %%%           %%%
       %%            %%%           %%%
       %%%%%         %%%          %%%%
         %%%%%%%     %%%     %%%%%%.
             #%%%%%%%%%%%%%%%%%
                  %%%%%%%%#
                      .${endColour}\n"

    for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
}

function ctrl_c(){
    tput cnorm
    echo -e "\n\n${redColour}[!] Exiting...${endColour}"
    rm getAllMachines shout* user* searchUserName tmp.json 2>/dev/null
    exit 1
}

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function generateFiles(){

    echo '' > $tmp_file

    while [ "$(cat $tmp_file | wc -l)" != "0" ]; do
        curl -s -H "$USER_AGENT" "$url_machines_get_all?api_token=$API_TOKEN" -X GET -L | tr "'" '"' | sed 's/None/\"None\"/g' | sed 's/True/\"True\"/g' | sed 's/False/\"False\"/g' > $tmp_file
    done
}

function getGlobalData(){

    echo "Sessions, Active VPNs, Total Machines" > global_data
    curl -s -X POST $url_global_data | tr "'" '"' | jq '.["data"]["sessions","vpn","machines"]' | xargs | tr ' ' ',' >> global_data
    echo -ne "${grayColour}"
    printTable ',' "$(cat global_data)"
    echo -ne "${endColour}"
    rm global_data 2>/dev/null
}

function getAllMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getAllMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do

        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getAllMachines
        let id+=1
    done

    echo -ne "${greenColour}"
    printTable ',' "$(cat getAllMachines)"
    echo -e "${endColour}"
    rm getAllMachines 2>/dev/null
}

function getActiveMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                       
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveMachines)"
    echo -e "${endColour}"
    rm getActiveMachines 2>/dev/null
}

function getRetiredMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredMachines)"
    echo -e "${endColour}"
    rm getRetiredMachines 2>/dev/null
}

function getActiveLinuxMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveLinuxMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveLinuxMachines
    sed -i '/Windows/d' getActiveLinuxMachines
    sed -i '/Other/d' getActiveLinuxMachines
    sed -i '/Solaris/d' getActiveLinuxMachines
    sed -i '/OpenBSD/d' getActiveLinuxMachines
    sed -i '/FreeBSD/d' getActiveLinuxMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveLinuxMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveLinuxMachines)"
    echo -e "${endColour}"
    rm getActiveLinuxMachines 2>/dev/null
}

function getActiveWindowsMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveWindowsMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveWindowsMachines
    sed -i '/Linux/d' getActiveWindowsMachines
    sed -i '/FreeBSD/d' getActiveWindowsMachines
    sed -i '/OpenBSD/d' getActiveWindowsMachines
    sed -i '/Other/d' getActiveWindowsMachines
    sed -i '/Solaris/d' getActiveWindowsMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveWindowsMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveWindowsMachines)"
    echo -e "${endColour}"
    rm getActiveWindowsMachines 2>/dev/null
}

function getActiveFreebsdMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveFreebsdMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveFreebsdMachines
    sed -i '/Linux/d' getActiveFreebsdMachines
    sed -i '/Windows/d' getActiveFreebsdMachines
    sed -i '/OpenBSD/d' getActiveFreebsdMachines
    sed -i '/Other/d' getActiveFreebsdMachines
    sed -i '/Solaris/d' getActiveFreebsdMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveFreebsdMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveFreebsdMachines)"
    echo -e "${endColour}"
    rm getActiveFreebsdMachines 2>/dev/null
}

function getActiveOpenbsdMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveOpenbsdMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveOpenbsdMachines
    sed -i '/Linux/d' getActiveOpenbsdMachines
    sed -i '/Windows/d' getActiveOpenbsdMachines
    sed -i '/FreeBSD/d' getActiveOpenbsdMachines
    sed -i '/Other/d' getActiveOpenbsdMachines
    sed -i '/Solaris/d' getActiveOpenbsdMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveOpenbsdMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveOpenbsdMachines)"
    echo -e "${endColour}"
    rm getActiveOpenbsdMachines 2>/dev/null
}

function getActiveOtherMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getActiveOtherMachines
        let id+=1
    done

    sed -i '/Is Active/!d' getActiveOtherMachines
    sed -i '/Linux/d' getActiveOtherMachines
    sed -i '/Windows/d' getActiveOtherMachines
    sed -i '/FreeBSD/d' getActiveOtherMachines
    sed -i '/OpenBSD/d' getActiveOtherMachines
    sed -i '/Solaris/d' getActiveOtherMachines
    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getActiveOtherMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getActiveOtherMachines)"
    echo -e "${endColour}"
    rm getActiveOtherMachines 2>/dev/null
}

function getRetiredWindowsMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredWindowsMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredWindowsMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredWindowsMachines
    sed -i '/Linux/d' getRetiredWindowsMachines
    sed -i '/FreeBSD/d' getRetiredWindowsMachines
    sed -i '/OpenBSD/d' getRetiredWindowsMachines
    sed -i '/Other/d' getRetiredWindowsMachines
    sed -i '/Solaris/d' getRetiredWindowsMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredWindowsMachines)"
    echo -e "${endColour}"
    rm getRetiredWindowsMachines 2>/dev/null
}

function getRetiredFreebsdMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredFreebsdMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredFreebsdMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredFreebsdMachines
    sed -i '/Linux/d' getRetiredFreebsdMachines
    sed -i '/Windows/d' getRetiredFreebsdMachines
    sed -i '/OpenBSD/d' getRetiredFreebsdMachines
    sed -i '/Other/d' getRetiredFreebsdMachines
    sed -i '/Solaris/d' getRetiredFreebsdMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredFreebsdMachines)"
    echo -e "${endColour}"
    rm getRetiredFreebsdMachines 2>/dev/null
}

function getRetiredOpenbsdMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredOpenbsdMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredOpenbsdMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredOpenbsdMachines
    sed -i '/Linux/d' getRetiredOpenbsdMachines
    sed -i '/Windows/d' getRetiredOpenbsdMachines
    sed -i '/FreeBSD/d' getRetiredOpenbsdMachines
    sed -i '/Other/d' getRetiredOpenbsdMachines
    sed -i '/Solaris/d' getRetiredOpenbsdMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredOpenbsdMachines)"
    echo -e "${endColour}"
    rm getRetiredOpenbsdMachines 2>/dev/null
}

function getRetiredLinuxMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredLinuxMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredLinuxMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredLinuxMachines
    sed -i '/Windows/d' getRetiredLinuxMachines
    sed -i '/FreeBSD/d' getRetiredLinuxMachines
    sed -i '/OpenBSD/d' getRetiredLinuxMachines
    sed -i '/Other/d' getRetiredLinuxMachines
    sed -i '/Solaris/d' getRetiredLinuxMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredLinuxMachines)"
    echo -ne "${endColour}"
    rm getRetiredLinuxMachines 2>/dev/null
}

function getRetiredOtherMachines(){

    getGlobalData
    echo "Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID" >> getRetiredOtherMachines

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')                                                                                                                                                                        
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getRetiredOtherMachines
        let id+=1
    done

    sed -i '/Is Active/d' getRetiredOtherMachines
    sed -i '/Windows/d' getRetiredOtherMachines
    sed -i '/Linux/d' getRetiredOtherMachines
    sed -i '/FreeBSD/d' getRetiredOtherMachines
    sed -i '/OpenBSD/d' getRetiredOtherMachines
    sed -i '/Solaris/d' getRetiredOtherMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getRetiredOtherMachines)"
    echo -e "${endColour}"
    rm getRetiredOtherMachines 2>/dev/null
}

function getSpawnedMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do

        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getAllMachines
        let id+=1
    done

    spawned_machines_response=$(curl -s -X GET "$url_spawned_machines?api_token=$API_TOKEN" | jq | grep "status")

    if [ "$(echo $?)" != "0" ]; then

	curl -s -X GET "$url_spawned_machines?api_token=$API_TOKEN" | jq | grep id | awk 'NF{print $NF}' | tr -d ',' | while read spawned_id_machine; do
		cat getAllMachines | grep ",$spawned_id_machine$" >> getSpawnedMachines
	done

	sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getSpawnedMachines

	echo -ne "${greenColour}"
	printTable ',' "$(cat getSpawnedMachines)"
	echo -ne "${endColour}"

	rm getAllMachines getSpawnedMachines 2>/dev/null; tput cnorm
    else
	spawned_machines_response=$(curl -s -X GET "$url_spawned_machines?api_token=$API_TOKEN" | jq '.["status"]' | tr -d '"')
	echo -e "\n${redColour}[!] $spawned_machines_response${endColour}\n"
	rm getAllMachines 2>/dev/null; tput cnorm
    fi
}

function getOwnedMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do

        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getAllMachines
        let id+=1
    done

    curl -s "$url_owned_machines?api_token=$API_TOKEN" | jq | grep id | awk 'NF{print $NF}' | tr -d ',' | while read owned_id_machine; do
	cat getAllMachines | grep ",$owned_id_machine$" >> getOwnedMachines
    done

    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getOwnedMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getOwnedMachines)"
    echo -ne "${endColour}"

    rm getAllMachines getOwnedMachines 2>/dev/null; tput cnorm
}

function getActiveOwnedMachines(){

    getGlobalData

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do

        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> getAllMachines
        let id+=1
    done

    curl -s "$url_owned_machines?api_token=$API_TOKEN" | jq | grep id | awk 'NF{print $NF}' | tr -d ',' | while read owned_id_machine; do
        cat getAllMachines | grep ",$owned_id_machine$" >> getOwnedMachines
    done

    sed -i '/Is Active/!d' getOwnedMachines

    sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' getOwnedMachines

    echo -ne "${greenColour}"
    printTable ',' "$(cat getOwnedMachines)"
    echo -ne "${endColour}"

    rm getAllMachines getOwnedMachines 2>/dev/null; tput cnorm
}

function searchMachineName(){

    getGlobalData
    s_machine_name=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    sed -i "/$s_machine_name/!d" searchMachineName

    if [ "$(cat searchMachineName | wc -l)" != "0" ]; then
	sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' searchMachineName

	echo -ne "${greenColour}"
        printTable ',' "$(cat searchMachineName)"
        echo -ne "${endColour}"
        tput cnorm; rm searchMachineName 2>/dev/null
    else
	echo -e "\n${redColour}[!] There is no machine with that name${endColour}\n"
	rm searchMachineName 2>/dev/null; tput cnorm
	exit 1
    fi
}

function searchIPAddress(){

    getGlobalData
    ipAddress=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchIPAddress
        let id+=1
    done

    sed -i "/$ipAddress,/!d" searchIPAddress

    if [ "$(cat searchIPAddress | wc -l)" != "0" ]; then
	sed -i '1 i\Name, IP Address, Operating System, Points, Rating, User Owns, Root Owns, Retired, Release Date, Retired Date, Free Lab, Machine ID' searchIPAddress

        echo -ne "${greenColour}"
        printTable ',' "$(cat searchIPAddress)"
        echo -ne "${endColour}"
        tput cnorm; rm searchIPAddress 2>/dev/null
    else
	echo -e "\n${redColour}[!] There is no machine with that IP address${endColour}\n"
	rm searchIPAddress 2>/dev/null; tput cnorm
	exit 1
    fi
}

function searchUserName(){

    username=$1
    id_username=$(curl -s -X POST "$url_user_id?api_token=$API_TOKEN" -L --data "username=$username" | tr "'" '"' | sed 's/None/\"None\"/g' | sed 's/True/\"True\"/g' | sed 's/False/\"False\"/g' | jq '.["id"]')

    curl -s "https://www.hackthebox.eu/profile/$id_username" | html2text > user_info

    little_check=$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $3}')

    if [ $little_check ]; then
        if [ $id_username ]; then
            echo "Username,ID,User Owns,System Owns,HallOfFame,Challenges Solved,Respected by,Badges,Rank" > searchUserName
            echo "$username,$id_username,$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $3}'),$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $2}'),$(cat user_info | grep "is at position" | awk '{print $5}'),$(cat user_info | grep "challenges" | awk '{print $4}'),$(cat user_info | grep "respected by" | awk '{print $5}'),$(cat user_info | grep "badges" | awk '{print $5}'),$(cat user_info | grep "\[image\]" -A 3 | awk 'NR==4')" >> searchUserName

            echo -ne "${yellowColour}"
            printTable ',' "$(cat searchUserName)"
            echo -ne "${endColour}"
            tput cnorm; rm searchUserName 2>/dev/null
        fi; rm user_info 2>/dev/null
    else
	echo -e "\n${redColour}[!] User has not public profile${endColour}\n"
	rm searchUserName user_info 2>/dev/null
	tput cnorm
    fi

    tput cnorm; rm user_info 2>/dev/null
}

function resetMachineName(){

    reset_machineName=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    machine_to_reset_id=$(cat searchMachineName | grep "$reset_machineName," | tr ',' ' ' | awk 'NF{print $NF}')

    response=$(curl -s -X POST "${url_reset_machine}${machine_to_reset_id}?api_token=$API_TOKEN" -L | jq '.["output"]' | tr -d '"')

    if [ "$(echo $response)" == "null" ]; then
        echo -e "\n${redColour}[!] It was not posible to restart the machine${endColour}\n"
    else
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} $response${endColour}\n"
    fi

    tput cnorm; rm searchMachineName 2>/dev/null
}

function shoutBoxMessages(){
    shoutbox_chat_value=$1
    curl -s -X POST "$url_shoutbox_messages$shoutbox_chat_value?api_token=$API_TOKEN" -L | jq '.["html"]' | tr -d '[]' | html2text | grep ":" | awk '{print $1}' FS="&" | sed 's/\">//' | grep ":" | sed 's/became a/became a VIP/g' | sed 's/(+1/+1/g' | sed 's/01\\//' | sed 's/  / /g' > shoutBox.tmp

    cat shoutBox.tmp | while read line_in_shoutbox; do
        user=$(echo $line_in_shoutbox | awk '{print $4}')
        echo $user >> users.txt
        echo -e "${blueColour}[$user]:${endColour}${grayColour} $line_in_shoutbox${endColour}" | grep -v -E '\[\]|\["\]'
    done

    rm shoutBox.tmp users.txt user_info 2>/dev/null; tput cnorm
}

function whoisChatting(){
    tput civis; shoutbox_chat_value=$1
    curl -s -X POST "$url_shoutbox_messages$shoutbox_chat_value?api_token=$API_TOKEN" -L | jq '.["html"]' | tr -d '[]' | html2text | grep ":" | awk '{print $1}' FS="&" | sed 's/\">//' | grep ":" | sed 's/became a/became a VIP/g' | sed 's/(+1/+1/g' | sed 's/01\\//' | sed 's/  / /g' > shoutBox.tmp

    cat shoutBox.tmp | while read line_in_shoutbox; do
        user=$(echo $line_in_shoutbox | awk '{print $4}')
        echo $user >> users.txt
    done

    echo "Username,ID,User Owns,System Owns,HallOfFame,Challenges Solved,Respected by,Badges,Rank" > searchUserName

    cat users.txt | sort -u | while read username; do
        id_username=$(curl -s -X POST "$url_user_id?api_token=$API_TOKEN" -L --data "username=$username" | tr "'" '"' | sed 's/None/\"None\"/g' | sed 's/True/\"True\"/g' | sed 's/False/\"False\"/g' | jq '.["id"]')

	curl -s "https://www.hackthebox.eu/profile/$id_username" | html2text > user_info

        little_check=$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $3}')

        if [ $little_check ]; then
            if [ $id_username ]; then
                echo "$username,$id_username,$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $3}'),$(cat user_info | grep "\[image\]" -A 2 | awk 'NR==3' | awk '{print $2}'),$(cat user_info | grep "is at position" | awk '{print $5}'),$(cat user_info | grep "challenges" | awk '{print $4}'),$(cat user_info | grep "respected by" | awk '{print $5}'),$(cat user_info | grep "badges" | awk '{print $5}'),$(cat user_info | grep "\[image\]" -A 3 | awk 'NR==4')" >> searchUserName
                echo -ne "${yellowColour}"
                echo -ne "${endColour}"
                tput cnorm;
            fi; rm user_info 2>/dev/null
        fi
    done

    echo -ne "${yellowColour}"
    printTable ',' "$(cat searchUserName)"
    echo -ne "${endColour}"
    rm shoutBox.tmp users.txt user_info searchUserName 2>/dev/null; tput cnorm
}

function deployMachine(){

    deployMachineName=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    machine_to_deploy_id=$(cat searchMachineName | grep "$deployMachineName," | tr ',' ' ' | awk 'NF{print $NF}')

    response=$(curl -s -X POST "${url_deploy_machine}${machine_to_deploy_id}?api_token=$API_TOKEN" -L | jq '.["status"]' | tr -d '"')

    if [ "$(echo $response)" == "null" ]; then
        echo -e "\n${redColour}[!] It was not posible to deploy the machine${endColour}\n"
    else
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} $response${endColour}\n"
    fi

    tput cnorm; rm searchMachineName 2>/dev/null
}

function stopMachine(){

    stopMachineName=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    machine_to_stop_id=$(cat searchMachineName | grep "$stopMachineName," | tr ',' ' ' | awk 'NF{print $NF}')
    response=$(curl -s -X POST "${url_stop_machine}${machine_to_stop_id}?api_token=$API_TOKEN" -L | jq '.["status"]' | tr -d '"')

    if [ "$(echo $response)" == "null" ]; then
        echo -e "\n${redColour}[!] It was not posible to stop the machine${endColour}\n"
    else
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} $response${endColour}\n"
    fi

    tput cnorm; rm searchMachineName 2>/dev/null
}

function extendMachine(){

    extendMachineName=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    machine_to_extend_id=$(cat searchMachineName | grep $extendMachineName | tr ',' ' ' | awk 'NF{print $NF}')

    response=$(curl -s -X POST "${url_extend_machine}${machine_to_extend_id}?api_token=$API_TOKEN" -L | jq '.["status"]' | tr -d '"')

    if [ "$(echo $response)" == "null" ]; then
        echo -e "\n${redColour}[!] It was not posible to extend the machine time${endColour}\n"
    else
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} $response${endColour}\n"
    fi

    tput cnorm; rm searchMachineName 2>/dev/null
}

function assignMachine(){
    assignMachineName=$1

    id=0; while [ "$field_value" != "null,null,null,null,null,null,null,null,null,null,null,null" ]; do
        field_value=$(cat $tmp_file | jq ".[$id][\"name\",\"ip\",\"os\",\"points\",\"rating\",\"user_owns\",\"root_owns\",\"retired\",\"release\",\"retired_date\",\"free\",\"id\"]" | tr -d '"' | xargs | tr ' ' ',')
        if [ "$(echo $field_value)" == "null,null,null,null,null,null,null,null,null,null,null,null" ]; then
            break
        fi

        echo $field_value | sed 's/true/Yes/g' | sed 's/false/No/g' | sed 's/null/Is Active/' >> searchMachineName
        let id+=1
    done

    machine_to_assign_id=$(cat searchMachineName | grep $assignMachineName | tr ',' ' ' | awk 'NF{print $NF}')

    response=$(curl -s -X POST "${url_assign_machine}${machine_to_assign_id}?api_token=$API_TOKEN" -L | jq '.["status"]' | tr -d '"')

    if [ "$(echo $response)" == "null" ]; then
        echo -e "\n${redColour}[!] It was not posible to assign the machine time${endColour}\n"
    else
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} $response${endColour}\n"
    fi

    tput cnorm; rm searchMachineName 2>/dev/null
}

function downloadVPN(){
    tput cnorm
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} You need to login first...${endColour}\n"
    python downloadVPN.py $1
    echo -e "\n${greenColour}[V]${endColour}${grayColour} The VPN has been download successfuly${endColour}"
}

function dependencies(){

	## Detect base OS for better package management. Can't use "$OSTYPE" by default,
	## it returns linux-gnu for different Linuxes. Fine for Fruitbook Computers...
	if [ -f /etc/os-release ]; then
		OS_RELEASE=$(awk -F= '/^NAME/{print $2}' /etc/os-release | sed 's/"//g')
	else
		OS_RELEASE=echo "$OSTYPE"
	fi

	## Based on what we find, select the appropriate package manager
	if [ "$(echo $UID)" == "0" ]; then

		tput civis
		dependencies_array=(html2text jq)

		echo; for program in "${dependencies_array[@]}"; do
			if [ ! "$(command -v $program)" ]; then
				echo -e "${redColour}[X]${endColour}${grayColour} $program${endColour}${yellowColour} is not installed${endColour}"; sleep 1
				echo -e "\n${yellowColour}[i]${endColour}${grayColour} Installing...${endColour}"; sleep 1

				apt install $program -y > /dev/null 2>&1

				echo -e "\n${greenColour}[V]${endColour}${grayColour} $program${endColour}${yellowColour} installed${endColour}\n"; sleep 2
			fi
		done
	else
		echo -e "\n${redColour}[!] You need to run the program as root${endColour}\n"
		exit 1
	fi

#		if [ "$(echo $counter)" == "1" ]; then
#			sleep
#		fi
}

function helpPanel(){
    banner
    echo -e "\n${redColour}[!] Usage: ./htbExplorer${endColour}"
    for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
    echo -e "\n\n\t${grayColour}[-e]${endColour}${yellowColour} Exploration Mode${endColour}"
    echo -e "\t\t${purpleColour}all_machines${endColour}${yellowColour}:\t\t\t List all machines${endColour}"
    echo -e "\t\t${purpleColour}active_machines${endColour}${yellowColour}:\t\t List active machines${endColour}"
    echo -e "\t\t${purpleColour}retired_machines${endColour}${yellowColour}:\t\t List retired machines${endColour}"
    echo -e "\t\t${purpleColour}active_linux_machines${endColour}${yellowColour}:\t\t List active Linux machines${endColour}"
    echo -e "\t\t${purpleColour}active_windows_machines${endColour}${yellowColour}:\t List active Windows machines${endColour}"
    echo -e "\t\t${purpleColour}active_freebsd_machines${endColour}${yellowColour}:\t List active FreeBSD machines${endColour}"
    echo -e "\t\t${purpleColour}active_openbsd_machines${endColour}${yellowColour}:\t List active OpenBSD machines${endColour}"
    echo -e "\t\t${purpleColour}active_other_machines${endColour}${yellowColour}:\t\t List active Other machines${endColour}"
    echo -e "\t\t${purpleColour}retired_linux_machines${endColour}${yellowColour}:\t\t List retired Linux machines${endColour}"
    echo -e "\t\t${purpleColour}retired_windows_machines${endColour}${yellowColour}:\t List retired Windows machines${endColour}"
    echo -e "\t\t${purpleColour}retired_freebsd_machines${endColour}${yellowColour}:\t List retired FreeBSD machines${endColour}"
    echo -e "\t\t${purpleColour}retired_openbsd_machines${endColour}${yellowColour}:\t List retired OpenBSD machines${endColour}"
    echo -e "\t\t${purpleColour}retired_other_machines${endColour}${yellowColour}:\t\t List retired Other machines${endColour}"
    echo -e "\t\t${purpleColour}spawned_machines${endColour}${yellowColour}:\t\t List spawned machines${endColour}${redColour} [Only for VIP members]${endColour}"
    echo -e "\t\t${purpleColour}owned_machines${endColour}${yellowColour}:\t\t\t List owned machines${endColour}"
    echo -e "\t\t${purpleColour}owned_active_machines${endColour}${yellowColour}:\t\t List owned active machines${endColour}\n"
    echo -e "\t${grayColour}[-s]${endColour}${yellowColour} Search by machine name${endColour} ${blueColour}\t\t (Example: -s Rope)${endColour}\n"
    echo -e "\t${grayColour}[-i]${endColour}${yellowColour} Search by IP Address${endColour} ${blueColour}\t\t (Example: -i 10.10.10.10)${endColour}\n"
    echo -e "\t${grayColour}[-r]${endColour}${yellowColour} Reset a machine${endColour} ${blueColour}\t\t\t (Example: -r Mantis)${endColour}\n"
    echo -e "\t${grayColour}[-d]${endColour}${yellowColour} Deploy a machine${endColour} ${blueColour}\t\t\t (Example: -d Aragog)${endColour}${redColour} [Only for VIP members]${endColour}\n"
    echo -e "\t${grayColour}[-k]${endColour}${yellowColour} Stop a machine${endColour} ${blueColour}\t\t\t (Example: -k Hawk)${endColour}${redColour} [Only for VIP members]${endColour}\n"
    echo -e "\t${grayColour}[-a]${endColour}${yellowColour} Assign a machine${endColour} ${blueColour}\t\t\t (Example: -a Lame)${endColour}${redColour} [Only for VIP members]${endColour}\n"
    echo -e "\t${grayColour}[-x]${endColour}${yellowColour} Extend a machine time${endColour} ${blueColour}\t\t (Example: -x Legacy)${endColour}${redColour} [Only for VIP members]${endColour}\n"
    echo -e "\t${grayColour}[-f]${endColour}${yellowColour} Search username${endColour} ${blueColour}\t\t\t (Example: -f s4vitar)${endColour}\n"
    echo -e "\t${grayColour}[-c]${endColour}${yellowColour} Show latest shoutbox messages${endColour}${blueColour}\t (Example: -c 50)${endColour}\n"
    echo -e "\t${grayColour}[-w]${endColour}${yellowColour} Who is chatting${endColour}${blueColour}\t\t\t (Example: -w 50)${endColour}\n"
    echo -e "\t${grayColour}[-v]${endColour}${yellowColour} Download VPN${endColour}${blueColour}\t\t\t (Example: -v s4vitar.ovpn)${endColour}\n"
    tput cnorm; exit 1
}

dependencies; parameter_counter=0
tput civis; while getopts ":e:s:i:f:r:c:w:d:k:x:a:v:h:" arg; do
    case $arg in
	e) explorer_mode=$OPTARG && let parameter_counter+=1;;
	s) search_machine_name=$OPTARG && let parameter_counter+=1;;
        i) ip_address=$OPTARG && let parameter_counter+=1;;
        f) user_name=$OPTARG && let parameter_counter+=1;;
        r) reset_machineName=$OPTARG && let parameter_counter+=1;;
        c) shoutbox_messages=$OPTARG && let parameter_counter+=1;;
        w) whois_messages=$OPTARG && let parameter_counter+=1;;
        d) machine_to_deploy=$OPTARG && let parameter_counter+=1;;
        k) machine_to_stop=$OPTARG && let parameter_counter+=1;;
        x) machine_to_extend=$OPTARG && let parameter_counter+=1;;
        a) machine_to_assign=$OPTARG && let parameter_counter+=1;;
        v) download_vpn=$OPTARG;;
	h) helpPanel;;
    esac
done

if [ "$parameter_counter" != "0" ]; then
    generateFiles
fi

if [ $search_machine_name ] && [ $API_TOKEN ]; then
    searchMachineName $search_machine_name
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $ip_address ] && [ $API_TOKEN ]; then
    searchIPAddress $ip_address
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $user_name ] && [ $API_TOKEN ]; then
    searchUserName $user_name
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $reset_machineName ] && [ $API_TOKEN ]; then
    resetMachineName $reset_machineName
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $machine_to_deploy ] && [ $API_TOKEN ]; then
    deployMachine $machine_to_deploy
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $machine_to_stop ] && [ $API_TOKEN ]; then
    stopMachine $machine_to_stop
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $machine_to_extend ] && [ $API_TOKEN ]; then
    extendMachine $machine_to_extend
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $machine_to_assign ] && [ $API_TOKEN ];  then
    assignMachine $machine_to_assign
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $shoutbox_messages ]  && [ $API_TOKEN ]; then
    shoutBoxMessages $shoutbox_messages
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $whois_messages ] && [ $API_TOKEN ]; then
    whoisChatting $whois_messages
    rm tmp.json 2>/dev/null; exit 0
fi

if [ $download_vpn ]; then
    downloadVPN $download_vpn
    exit 0
fi

if [ $explorer_mode ] && [ $API_TOKEN ]; then
    if [ "$(echo $explorer_mode)" == "all_machines" ]; then
        getAllMachines
    elif [ "$(echo $explorer_mode)" == "active_machines" ]; then
        getActiveMachines
    elif [ "$(echo $explorer_mode)" == "retired_machines" ]; then
        getRetiredMachines
    elif [ "$(echo $explorer_mode)" == "active_linux_machines" ]; then
		getActiveLinuxMachines
    elif [ "$(echo $explorer_mode)" == "active_windows_machines" ]; then
        getActiveWindowsMachines
    elif [ "$(echo $explorer_mode)" == "retired_linux_machines" ]; then
		getRetiredLinuxMachines
    elif [ "$(echo $explorer_mode)" == "retired_windows_machines" ]; then
		getRetiredWindowsMachines
    elif [ "$(echo $explorer_mode)" == "active_freebsd_machines" ]; then
        getActiveFreebsdMachines
    elif [ "$(echo $explorer_mode)" == "retired_freebsd_machines" ]; then
        getRetiredFreebsdMachines
    elif [ "$(echo $explorer_mode)" == "retired_openbsd_machines" ]; then
        getRetiredOpenbsdMachines
    elif [ "$(echo $explorer_mode)" == "active_openbsd_machines" ]; then
        getActiveOpenbsdMachines
    elif [ "$(echo $explorer_mode)" == "active_other_machines" ]; then
        getActiveOtherMachines
    elif [ "$(echo $explorer_mode)" == "retired_other_machines" ]; then
        getRetiredOtherMachines
    elif [ "$(echo $explorer_mode)" == "spawned_machines" ]; then
		getSpawnedMachines
    elif [ "$(echo $explorer_mode)" == "owned_machines" ]; then
		getOwnedMachines
    elif [ "$(echo $explorer_mode)" == "owned_active_machines" ]; then
		getActiveOwnedMachines
    fi
else
    helpPanel
fi

rm tmp.json 2>/dev/null; tput cnorm
