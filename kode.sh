#!/usr/bin/env bash

kode() (
    # Determine the config directory
    config_dir
    if [[ -n "${XDG_CONFIG_HOME}" ]]; then
        config_dir="${XDG_CONFIG_HOME}/kodesh"
    else
        config_dir="${HOME}/.config/kodesh"
    fi

    config="${config_dir}/config.json"
    ide_prefs="${config_dir}/ide_preferences.json"
    log_dir="${config_dir}/logs"

    # Function to print help message
    print_help() {
        echo "Usage: kode [OPTIONS] [PROJECT] [IDE]"
        echo
        echo "Options:"
        echo "  --help                Show this help message"
        echo "  --set-default-dir DIR Set the default projects directory"
        echo "  --add-project DIR     Add a project directory manually"
        echo "  cat                   Display the contents of the config file"
        echo "  ls                    List projects in the default directory and manual projects"
        echo
        echo "Arguments:"
        echo "  PROJECT               Name of the project directory"
        echo "  IDE                   (Optional) IDE to use (z: Zed, vs: VS Code, id: IntelliJ IDEA)"
        echo "                        If not specified, the last used IDE for the project will be used"
        echo
        echo "Examples:"
        echo "  kode myproject vs     Open 'myproject' with VS Code and set it as the preferred IDE"
        echo "  kode myproject        Open 'myproject' with the last used IDE"
        echo "  kode --set-default-dir ~/work"
        echo "  kode --add-project ~/documents/project"
    }

    # Function to set default projects directory
    set_default_dir() {
        if [ -d "$1" ]; then
            jq --arg dir "$1" '.default_projects_dir = $dir' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
            echo "Default projects directory set to $1"
        else
            echo "Error: Directory $1 does not exist"
        fi
    }

    # Function to add a project manually
    add_project() {
        if [ -d "$1" ]; then
            project_name=$(basename "$1")
            jq --arg name "$project_name" --arg path "$1" '.manual_projects[$name] = $path' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
            echo "Project $project_name added with path $1"
        else
            echo "Error: Directory $1 does not exist"
        fi
    }

    # Ensure config directory exists
    mkdir -p "${config_dir}"
    
    # Create config files if they don't exist
    [ ! -f "$config" ] && echo '{}' > "$config"
    [ ! -f "$ide_prefs" ] && echo '{}' > "$ide_prefs"
    
    # Parse options
    case "$1" in
        --help)
            print_help
            return 0
            ;;
        --set-default-dir)
            set_default_dir "$2"
            return 0
            ;;
        --add-project)
            add_project "$2"
            return 0
            ;;
        cat)
            echo "Config:"
            cat "$config"
            echo "IDE Preferences:"
            cat "$ide_prefs"
            return 0
            ;;
        ls)
            default_dir=$(jq -r '.default_projects_dir // empty' "$config")
            if [ -d "$default_dir" ]; then
                echo "Projects in $default_dir:"
                ls "$default_dir"
            else
                echo "Default projects directory not set or doesn't exist."
            fi
            echo "Manually added projects:"
            jq -r '.manual_projects | keys[]' "$config"
            return 0
            ;;
    esac

    if [ -z "$1" ]; then
        echo "Error: Project name cannot be empty. Use 'kode --help' for usage information."
        return 1
    fi

    # Get project directory
    default_dir=$(jq -r '.default_projects_dir // empty' "$config")
    manual_project_path=$(jq -r --arg name "$1" '.manual_projects[$name] // empty' "$config")

    if [ -n "$manual_project_path" ]; then
        project_dir="$manual_project_path"
    elif [ -d "$default_dir/$1" ]; then
        project_dir="$default_dir/$1"
    else
        echo "Error: Project '$1' not found. Use 'kode --add-project' to add it manually."
        return 1
    fi

    if [ -z "$2" ]; then
        ide=$(jq -r --arg name "$1" '.[$name] // empty' "$ide_prefs")
        if [ -z "$ide" ]; then
            echo "Error: No IDE preference set for this project. Please specify an IDE."
            return 1
        fi
    else
        ide="$2"
    fi

    # Get IDE paths from config
    zed_path=$(jq -r '.ide_paths.zed // "/usr/bin/zeditor"' "$config")
    vscode_path=$(jq -r '.ide_paths.vscode // "/usr/bin/code"' "$config")
    intellij_path=$(jq -r '.ide_paths.intellij // "/usr/bin/idea"' "$config")

    case "$ide" in
        'z') command="$zed_path $project_dir" ;;
        'vs') command="$vscode_path $project_dir" ;;
        'id') command="$intellij_path $project_dir" ;;
        *) echo "Error: Invalid IDE option. Please use either 'z', 'vs' or 'id'."
           return 1 ;;
    esac

    # Update IDE preference
    jq --arg key "$1" --arg value "$ide" '.[$key] = $value' "$ide_prefs" > "${ide_prefs}.tmp" && mv "${ide_prefs}.tmp" "$ide_prefs"

    mkdir -p "$log_dir"

    timestamp=$(date +"%Y%m%d_%H%M%S")
    log_file="$log_dir/${timestamp}.log"
    
    case "$ide" in
        'z') ide_name="Zed" ;;
        'vs') ide_name="VS Code" ;;
        'id') ide_name="IntelliJ IDEA" ;;
    esac

    # Disabling shellcheck suggestion for printf command
    # shellcheck disable=SC2059
    printf "\e[32mOpening \e[33m\e[1m$1\e[0m\e[32m with \e[33m\e[1m$ide_name\e[0m\e[32m"
    for _ in {1..3}; do
        sleep 0.2
        printf "."
    done
    printf "\e[0m\n"
    sleep 0.2

    # shellcheck disable=SC2086
    nohup $command > "$log_file" 2>&1 &

    cd "$project_dir" || return 1
)

# Initialize config with default values if it's empty
if [ ! -s "${XDG_CONFIG_HOME:-$HOME/.config}/kodesh/config.json" ]; then
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/kodesh"
    cat > "${XDG_CONFIG_HOME:-$HOME/.config}/kodesh/config.json" << EOF
{
  "default_projects_dir": "$HOME/Projects",
  "manual_projects": {},
  "ide_paths": {
    "zed": "/usr/bin/zeditor",
    "vscode": "/usr/bin/code",
    "intellij": "/usr/bin/idea"
  }
}
EOF
fi