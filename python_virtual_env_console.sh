#!/bin/bash

# Function to activate a virtual environment
activate_venv() {
    if [ -z "$1" ]; then
        echo "Please provide the name of the virtual environment."
        return 1
    fi
    source "$1"/bin/activate
    echo "Activated virtual environment: $1"
}

# Function to deactivate a virtual environment
deactivate_venv() {
    if [ -z "$venv_name" ]; then
        echo "No virtual environment is currently activated."
        return 1
    fi

    # Attempt to deactivate the virtual environment
    if ! deactivate &> /dev/null; then
        echo "Unable to deactivate. Virtual environment not activated."
        return 1
    fi

    echo "Deactivated virtual environment: $venv_name"
}

is_venv() {
    local dir="$1"
    if [ -f "$dir/bin/activate" ] && [ -f "$dir/pyvenv.cfg" ]; then
        return 0
    else
        return 1
    fi
}
# Function to list all virtual environment folders in a path
list_venvs() {
    local path="${1:-$PWD}"  # Use current directory if path not provided

    # Find directories containing both /bin/activate and /pyvenv.cfg files
    find "$path" -type d -exec test -f '{}/bin/activate' \; -exec test -f '{}/pyvenv.cfg' \; -print
}

# ansi_codes: https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
# Terminal colors
# Define colors for highlighting
red="\033[31m"
red_high_intensity="\e[0;91m"
yellow="\033[33m"
yellow_high_intensity="\e[0;93m"
cyan="\e[4;36m"
cyan_high_intensity="\e[0;96m"
black="\e[0;30m	"
cyan_high_background="\e[0;106m"
blue_high_background="\e[0;104m"
green_high_background="\e[0;102m"
green_highlight="\033[1;32m"  # Green
green_high_intensity="\e[0;92m"
normal="\033[0m"        # Reset to default
reset="\e[0m"

options=(
"************ Python venv management console for linux ************"
""
"1. List all venvs"
"2. Create virtual environment"
"3. Delete virtual environment"
"4. Activate virtual environment"
"5. Deactivate virtual environment"
"6. Exit"
""
"Enter your choice and press enter: "
)

selected_index=2 #Starts with option 1 highlighted
num_options=${#options[@]}

display_menu() {
    clear
    for ((i=0; i<$num_options; i++)); do
        if [[ "${options[$i]}" =~ ^[0-9]+ ]]; then
            if [ $i -eq $selected_index ]; then

                echo -e "${green_high_intensity}|====> ${options[$i]}${reset}"
            else
                echo "   ${options[$i]}"
            fi
        else
            echo "   ${options[$i]}"
        fi
    done
}
# Function to handle user input for main menu
handle_input_main_menu() {
    echo " "
    read -rsn1 input
    case $input in
        "A")  # Up arrow
            ((selected_index--))
            ;;
        "B")  # Down arrow
            ((selected_index++))
            ;;
        "")   # Enter key

            if [[ "${options[selected_index]}" =~ ^[0-9]+ ]]; then
                case $((selected_index-1)) in

                    1)
                        echo
                        read -p "Enter the path to list virtual environment folders: " path_to_list
                        echo
                        echo -e ${cyan_high_intensity}
                        list_venvs "$path_to_list"
                        echo -e ${normal}
                        echo
                        echo "--------------------------------------------------------------"
                        read -p "Press enter to get back to main menu: " enter
                        ;;
                    2)
                        echo
                        read -p "Enter the full path and name of the virtual environment to create (Example: /path/to/venv_name): " venv_name
                        python3 -m venv "$venv_name"

                        echo
                        echo -e "${cyan_high_intensity}Created venv $venv_name in: $venv_path/$venv_name${normal}"
                        echo
                        echo -e ${green_high_intensity}
                        ls -lha "$venv_path/$venv_name"
                        echo -e ${normal}
                        echo
                        echo "--------------------------------------------------------------"
                        read -p "Press enter to get back to the main menu: " enter
                        ;;

                    3)
                        #echo "Listing venv in $PWD: "
                        #echo -e ${cyan_high_intensity}
                        #list_venvs "$path_to_list"
                        #echo -e ${normal}
                        read -p "Enter the name of the virtual environment to delete: " venv_name
                        if [ -d "$venv_name" ]; then
                            rm -rf "$venv_name"
                            echo -e ${yellow_high_intensity}
                            echo "Virtual environment '$venv_name' deleted."
                            echo -e ${normal}
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                        else
                            echo
                            echo -e "${red_high_intensity}ERROR: Virtual environment '$venv_name' not found.${normal}"
                            echo
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                            fi
                        ;;
                    4)
                        echo
                        #echo "Listing venv in $PWD: "
                        #echo -e ${cyan_high_intensity}
                        #list_venvs "$path_to_list"
                        #echo -e ${normal}
                        echo
                        read -p "Enter the name of the virtual environment to activate: " venv_name
                        if [ -d "$venv_name" ]; then
                            #source "$venv_name/bin/activate"
                            echo -e ${cyan_high_intensity}
                            activate_venv "$venv_name"
                            echo -e ${normal}
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                        else
                            echo
                            echo -e "${red_high_intensity}ERROR: Virtual environment '$venv_name' not found.${normal}"
                            echo
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                        fi
                        ;;
                    5)
                        echo
                        #echo "Listing venv in $PWD: "
                        #echo -e ${cyan_high_intensity}
                        #list_venvs "$path_to_list"
                        #echo -e ${normal}
                        read -p "Enter the name of the virtual environment to deactivate: " venv_name
                        if [ -d "$venv_name" ]; then
                            echo -e ${yellow_high_intensity}
                            deactivate_venv "$venv_name"
                            echo -e ${normal}
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                        else
                            echo
                            echo -e "${red_high_intensity}ERROR: Virtual environment '$venv_name' not found.${normal}"
                            echo
                            echo "--------------------------------------------------------------"
                            read -p "Press enter to get back to main menu: " enter
                        fi
                        ;;
                    6)
                        echo "Exiting..."
                        exit
                        ;;

                esac
            else
                echo
                echo -e "${red_high_intensity}This option cannot be selected. Select Only numbered options${normal}"
                echo
                read -p "Press enter to go back to the selection menu: " enter
            fi
            ;;
    esac

    # Ensure selected_index stays within bounds
    if [ $selected_index -lt 0 ]; then
        selected_index=0
    elif [ $selected_index -ge $num_options ]; then
        selected_index=$((num_options - 1))
    fi
}

# Main loop for main menu
while true; do
    display_menu
    handle_input_main_menu
done
