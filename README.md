# PHP Switch 🐘

A simple and elegant PHP version manager for Linux, inspired by [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager).

Easily switch between multiple PHP versions with a single command!

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

## ✨ Features

- 🔄 **Quick Version Switching** - Switch PHP versions with a single command
- 📋 **List Installed Versions** - See all available PHP versions at a glance
- 🌐 **List Remote Versions** - See all PHP versions available to install
- 📊 **Detailed PHP Info** - View memory limits, config paths, timezone, and more
- 🧩 **Extension Management** - List, compare, and install PHP extensions
- 🎨 **Colored Output** - Beautiful, easy-to-read terminal output
- ⌨️ **Tab Completion** - Auto-complete version numbers and commands
- 🔧 **Tool Switching** - Automatically switches related tools (phpize, phar, php-config)
- 📅 **Support Status** - Shows Active Support, Security Only, and EOL status

## 📋 Prerequisites

- **Linux** (Ubuntu/Debian-based distributions)
- **Bash** shell
- Multiple PHP versions installed via `apt` (e.g., from [Ondřej Surý's PPA](https://launchpad.net/~ondrej/+archive/ubuntu/php))
- `sudo` privileges (for switching PHP versions)

### Installing Multiple PHP Versions (Ubuntu/Debian)

```bash
# Add the PHP repository
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# Install desired PHP versions
sudo apt install php7.4 php8.0 php8.1 php8.2 php8.3 php8.4

# Install common extensions (optional)
sudo apt install php8.3-{cli,fpm,mysql,xml,curl,mbstring,zip,gd,bcmath}
```

## 🚀 Installation

### Quick Install (One-liner)

```bash
curl -o ~/.php-switch https://raw.githubusercontent.com/alanshijo/php-version-manager/main/php-switch.sh && echo 'source ~/.php-switch' >> ~/.bashrc && source ~/.bashrc
```

### Manual Installation

1. **Download the script:**
   ```bash
   curl -o ~/.php-switch https://raw.githubusercontent.com/alanshijo/php-version-manager/main/php-switch.sh
   ```

   Or clone the repository:
   ```bash
   git clone https://github.com/alanshijo/php-version-manager.git
   cp php-switch/php-switch.sh ~/.php-switch
   ```

2. **Add to your shell configuration:**

   For **Bash** (`~/.bashrc`):
   ```bash
   echo 'source ~/.php-switch' >> ~/.bashrc
   ```

   For **Zsh** (`~/.zshrc`):
   ```bash
   echo 'source ~/.php-switch' >> ~/.zshrc
   ```

3. **Reload your shell:**
   ```bash
   source ~/.bashrc
   # or
   source ~/.zshrc
   ```

4. **Verify installation:**
   ```bash
   php-switch --help
   ```

## 📖 Usage

### Switch PHP Version

```bash
# Switch to PHP 8.3
php-switch 8.3

# Alternative syntax
php-use 8.3

# Also accepts 'php' prefix
php-switch php7.4
```

### List Installed Versions

```bash
php-list

# Output:
# Installed PHP versions:
#
#     7.4
#     8.2
#   ► 8.3 (current)
#     8.4
```

### Show Current Version

```bash
php-switch --current
# or
php-switch -c
```

### View Detailed PHP Information

```bash
php-info

# Output:
# ╔═══════════════════════════════════════════╗
# ║           PHP Information                 ║
# ╚═══════════════════════════════════════════╝
#
# Version:        8.3
# Binary:         /usr/bin/php
# Config File:    /etc/php/8.3/cli/php.ini
# Memory Limit:   -1
# Max Execution:  0s
# Upload Max:     2M
# Post Max:       8M
# Timezone:       UTC
# Composer:       2.8.6
```

### List Remote Versions (like nvm ls-remote)

```bash
# Show all supported PHP versions
php-ls-remote

# Output:
# ╔═══════════════════════════════════════════════════════════════╗
# ║              Available PHP Versions (Remote)                  ║
# ╚═══════════════════════════════════════════════════════════════╝
#
#   VERSION    RELEASE         STATUS             SUPPORT
#   ────────────────────────────────────────────────────────────
#     8.5      2025-11-20      Active Support     until 2027-12-31 (Latest)
#   ✓ 8.4      2024-11-21      Active Support     until 2026-12-31 (current)
#   ✓ 8.3      2023-11-23      Security Only      until 2027-12-31
#   ✓ 8.2      2022-12-08      Security Only      until 2026-12-31
#     8.1      2021-11-25      Security Only      until 2025-12-31

# Show only LTS/supported versions
php-ls-remote --lts

# Show all versions including EOL
php-ls-remote --all

# Filter by major version
php-ls-remote 8
```

### Get Latest Release Info

```bash
php-latest

# Fetches latest stable releases from php.net API
```

### List Extensions

```bash
# List extensions for current PHP version
php-extensions

# List extensions for a specific version
php-extensions 8.1
```

### Compare Extensions Between Versions

```bash
php-compare 7.4 8.3

# Shows extensions unique to each version
```

### Search Available Modules

```bash
# List available packages for current PHP version
php-modules

# Search for specific packages
php-modules mysql
php-modules curl
```

### Install Extension

```bash
# Install an extension for current PHP version
php-install curl
php-install mysql
php-install gd
```

## 📚 Command Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `php-switch <version>` | `php-use <version>` | Switch to specified PHP version |
| `php-switch --list` | `php-switch -l` | List all installed versions |
| `php-switch --current` | `php-switch -c` | Show current PHP version |
| `php-switch --info` | `php-switch -i` | Show detailed PHP information |
| `php-switch --help` | `php-switch -h` | Show help message |
| `php-list` | - | List installed versions with current highlighted |
| `php-ls-remote` | - | List all available PHP versions (like nvm ls-remote) |
| `php-ls-remote --lts` | - | List only supported versions |
| `php-ls-remote --all` | - | List all versions including EOL |
| `php-ls-remote <ver>` | - | Filter by version (e.g., 8, 8.3) |
| `php-latest` | - | Fetch latest releases from php.net |
| `php-info` | - | Display detailed PHP configuration |
| `php-extensions [ver]` | - | List extensions (optionally for specific version) |
| `php-modules [keyword]` | - | Search available apt packages |
| `php-install <ext>` | - | Install extension for current version |
| `php-compare <v1> <v2>` | - | Compare extensions between two versions |

## ⚙️ How It Works

PHP Switch uses Ubuntu/Debian's `update-alternatives` system to manage PHP versions. When you switch versions, it updates the symbolic links for:

- `php` - Main PHP binary
- `phar` - PHP Archive tool
- `phar.phar` - PHP Archive tool (alternative)
- `phpize` - PHP extension build tool
- `php-config` - PHP build configuration
- `phpdbg` - PHP debugger

## 🔧 Configuration

### Custom PHP Binary Location

If your PHP binaries are installed in a different location, you can modify the script:

```bash
# Edit ~/.php-switch and change this line:
ls -1 /usr/bin/php[0-9]* 2>/dev/null

# To your custom path:
ls -1 /custom/path/php[0-9]* 2>/dev/null
```

### Disable Colors

To disable colored output, add this before sourcing the script:

```bash
export PHP_SWITCH_NO_COLOR=1
source ~/.php-switch
```

## 🐛 Troubleshooting

### "PHP version is not installed"

Make sure the PHP version is installed:
```bash
ls /usr/bin/php*
```

If not installed, add Ondřej's PPA and install:
```bash
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.3
```

### "Permission denied" when switching

The script requires `sudo` to modify system alternatives. Make sure your user has sudo privileges.

### Tab completion not working

Reload your shell configuration:
```bash
source ~/.bashrc
```

Or restart your terminal.

### Changes not reflected in Apache/Nginx

This script only changes the CLI PHP version. For web servers, you need to:

```bash
# For Apache
sudo a2dismod php7.4
sudo a2enmod php8.3
sudo systemctl restart apache2

# For Nginx with PHP-FPM
sudo systemctl stop php7.4-fpm
sudo systemctl start php8.3-fpm
# Update your nginx config to use the new FPM socket
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager)
- Thanks to [Ondřej Surý](https://launchpad.net/~ondrej) for maintaining the PHP PPA

## 📬 Support

If you encounter any issues or have questions, please [open an issue](https://github.com/alanshijo/php-version-manager/issues) on GitHub.

---

**Happy PHP switching! 🚀**
