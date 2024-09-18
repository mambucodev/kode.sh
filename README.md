# kode.sh

`kode.sh` is a bash utility that simplifies opening projects with your preferred Integrated Development Environment (IDE). It allows you to quickly navigate to your project directories and launch them with your chosen IDE, all from the command line.

## Features

- Quickly open projects with your preferred IDE
- Support for multiple IDEs (Zed, VS Code, IntelliJ IDEA)
- Easily set and manage default project directories
- Add custom project locations
- Remembers your IDE preference for each project
- Simple command-line interface

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/mambucodev/kode-script.git
   ```

2. Add the following line to your `.bashrc` or `.zshrc`:
   ```
   source /path/to/kodesh/kode.sh
   ```

3. Reload your shell configuration:
   ```
   source ~/.bashrc  # or source ~/.zshrc if you're using Zsh
   ```

## Usage

```
kode [OPTIONS] [PROJECT] [IDE]
```

### Options:
- `--help`: Show the help message
- `--set-default-dir DIR`: Set the default projects directory
- `--add-project DIR`: Add a project directory manually
- `cat`: Display the contents of the config file
- `ls`: List projects in the default directory and manual projects

### Arguments:
- `PROJECT`: Name of the project directory
- `IDE`: (Optional) IDE to use (z: Zed, vs: VS Code, id: IntelliJ IDEA)

### Examples:
```
kode myproject vs     # Open 'myproject' with VS Code and set it as the preferred IDE
kode myproject        # Open 'myproject' with the last used IDE
kode --set-default-dir ~/work
kode --add-project ~/documents/project
```

## Configuration

The script uses two JSON configuration files stored in `~/.config/kodesh/` (or `$XDG_CONFIG_HOME/kodesh/` if set):

1. `config.json`: Stores the default project directory, manually added projects, and IDE paths.
2. `ide_preferences.json`: Stores the preferred IDE for each project.

You can edit these files manually, but it's recommended to use the script's commands for making changes.

## Dependencies

- `jq`: For JSON parsing (must be installed separately)
- Bash 4.0 or later

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any problems or have any questions, please open an issue on the GitHub repository.