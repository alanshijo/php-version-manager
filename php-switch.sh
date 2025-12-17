#!/bin/bash
# PHP Version Switcher Script
# Similar to NVM for Node.js
# Usage: php-switch <version> or php-use <version>
# Example: php-switch 8.3 or php-use 7.4

# Colors for output
PHP_SWITCH_RED='\033[0;31m'
PHP_SWITCH_GREEN='\033[0;32m'
PHP_SWITCH_YELLOW='\033[0;33m'
PHP_SWITCH_BLUE='\033[0;34m'
PHP_SWITCH_CYAN='\033[0;36m'
PHP_SWITCH_NC='\033[0m' # No Color

# Get available PHP versions
_php_get_versions() {
    ls -1 /usr/bin/php[0-9]* 2>/dev/null | grep -oP 'php\K[0-9.]+' | sort -V
}

# Get current PHP version
_php_current_version() {
    php -v 2>/dev/null | head -n 1 | grep -oP 'PHP \K[0-9]+\.[0-9]+'
}

# Main switch function
php_switch() {
    local version="$1"
    local current=$(_php_current_version)
    
    # No argument - show usage and versions
    if [ -z "$version" ]; then
        echo -e "${PHP_SWITCH_BLUE}Usage:${PHP_SWITCH_NC} php-switch <version>"
        echo -e "       php-switch --list    List all versions"
        echo -e "       php-switch --current Show current version"
        echo ""
        php-list
        return 1
    fi
    
    # Handle flags
    case "$version" in
        -l|--list)
            php-list
            return 0
            ;;
        -c|--current)
            echo -e "Current: ${PHP_SWITCH_GREEN}PHP $current${PHP_SWITCH_NC}"
            return 0
            ;;
        -h|--help)
            php-help
            return 0
            ;;
        -i|--info)
            php-info
            return 0
            ;;
        -e|--extensions)
            php-extensions
            return 0
            ;;
    esac
    
    # Allow "8.3" or "php8.3" format
    version="${version#php}"
    
    # Check if already on this version
    if [ "$version" = "$current" ]; then
        echo -e "${PHP_SWITCH_YELLOW}Already using PHP ${version}${PHP_SWITCH_NC}"
        return 0
    fi
    
    # Check if the specified version exists
    if [ ! -f "/usr/bin/php${version}" ]; then
        echo -e "${PHP_SWITCH_RED}Error:${PHP_SWITCH_NC} PHP ${version} is not installed"
        echo ""
        echo "Available versions:"
        _php_get_versions | while read v; do
            if [ "$v" = "$current" ]; then
                echo -e "  ${PHP_SWITCH_GREEN}► $v (current)${PHP_SWITCH_NC}"
            else
                echo "    $v"
            fi
        done
        return 1
    fi
    
    # Switch PHP CLI version
    sudo update-alternatives --set php "/usr/bin/php${version}" > /dev/null 2>&1
    
    # Also switch related PHP tools if they exist
    local tools=("phar" "phar.phar" "phpize" "php-config" "phpdbg")
    for tool in "${tools[@]}"; do
        if [ -f "/usr/bin/${tool}${version}" ]; then
            sudo update-alternatives --set "$tool" "/usr/bin/${tool}${version}" > /dev/null 2>&1
        fi
    done
    
    # Show success message
    echo -e "${PHP_SWITCH_GREEN}✓ Switched to PHP ${version}${PHP_SWITCH_NC}"
    php -v | head -n 1
}

# List available PHP versions with current highlighted
php-list() {
    local current=$(_php_current_version)
    echo -e "${PHP_SWITCH_BLUE}Installed PHP versions:${PHP_SWITCH_NC}"
    echo ""
    _php_get_versions | while read v; do
        if [ "$v" = "$current" ]; then
            echo -e "  ${PHP_SWITCH_GREEN}► $v ${PHP_SWITCH_NC}(current)"
        else
            echo "    $v"
        fi
    done
    echo ""
}

# Show help
php-help() {
    echo -e "${PHP_SWITCH_BLUE}╔═══════════════════════════════════════════╗${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}║          PHP Version Switcher             ║${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}╚═══════════════════════════════════════════╝${PHP_SWITCH_NC}"
    echo ""
    echo -e "${PHP_SWITCH_CYAN}Commands:${PHP_SWITCH_NC}"
    echo "  php-switch <version>    Switch to specified PHP version"
    echo "  php-switch -l, --list   List all installed versions"
    echo "  php-switch -c, --current Show current version"
    echo "  php-switch -i, --info   Show detailed PHP info"
    echo "  php-switch -e, --extensions List extensions"
    echo "  php-switch -h, --help   Show this help"
    echo ""
    echo -e "${PHP_SWITCH_CYAN}Remote/Install:${PHP_SWITCH_NC}"
    echo "  php-ls-remote           List all available PHP versions"
    echo "  php-ls-remote --lts     List only LTS/supported versions"
    echo "  php-ls-remote --all     List all versions including EOL"
    echo "  php-ls-remote <ver>     Filter by version (e.g., 8, 8.3)"
    echo "  php-latest              Fetch latest releases from php.net"
    echo ""
    echo -e "${PHP_SWITCH_CYAN}Aliases:${PHP_SWITCH_NC}"
    echo "  php-list                List all installed versions"
    echo "  php-use <version>       Same as php-switch"
    echo "  php-info                Show detailed PHP info"
    echo "  php-extensions [ver]    List extensions for a version"
    echo "  php-modules             Search for available modules"
    echo "  php-compare <v1> <v2>   Compare extensions between versions"
    echo ""
    echo -e "${PHP_SWITCH_CYAN}Examples:${PHP_SWITCH_NC}"
    echo "  php-switch 8.3          Switch to PHP 8.3"
    echo "  php-switch php7.4       Switch to PHP 7.4"
    echo "  php-ls-remote --lts     Show supported PHP versions"
    echo "  php-extensions 8.1      List PHP 8.1 extensions"
    echo "  php-modules curl        Search for curl modules"
    echo ""
}

# Show detailed PHP info
php-info() {
    local current=$(_php_current_version)
    local config_file=$(php --ini 2>/dev/null | grep 'Loaded Configuration' | cut -d: -f2 | xargs)
    local memory=$(php -r 'echo ini_get("memory_limit");' 2>/dev/null)
    local max_exec=$(php -r 'echo ini_get("max_execution_time");' 2>/dev/null)
    local upload=$(php -r 'echo ini_get("upload_max_filesize");' 2>/dev/null)
    local post=$(php -r 'echo ini_get("post_max_size");' 2>/dev/null)
    local timezone=$(php -r 'echo ini_get("date.timezone") ?: "Not set";' 2>/dev/null)
    
    echo -e "${PHP_SWITCH_BLUE}╔═══════════════════════════════════════════╗${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}║           PHP Information                 ║${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}╚═══════════════════════════════════════════╝${PHP_SWITCH_NC}"
    echo ""
    echo -e "${PHP_SWITCH_CYAN}Version:${PHP_SWITCH_NC}        ${PHP_SWITCH_GREEN}$current${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_CYAN}Binary:${PHP_SWITCH_NC}         $(which php)"
    echo -e "${PHP_SWITCH_CYAN}Config File:${PHP_SWITCH_NC}    $config_file"
    echo -e "${PHP_SWITCH_CYAN}Memory Limit:${PHP_SWITCH_NC}   $memory"
    echo -e "${PHP_SWITCH_CYAN}Max Execution:${PHP_SWITCH_NC}  ${max_exec}s"
    echo -e "${PHP_SWITCH_CYAN}Upload Max:${PHP_SWITCH_NC}     $upload"
    echo -e "${PHP_SWITCH_CYAN}Post Max:${PHP_SWITCH_NC}       $post"
    echo -e "${PHP_SWITCH_CYAN}Timezone:${PHP_SWITCH_NC}       $timezone"
    echo ""
    
    # Show Composer info if available
    if command -v composer &> /dev/null; then
        local composer_ver=$(composer --version 2>/dev/null | grep -oP 'Composer version \K[0-9.]+')
        echo -e "${PHP_SWITCH_CYAN}Composer:${PHP_SWITCH_NC}       $composer_ver"
    fi
    echo ""
}

# List extensions for current or specified version
php-extensions() {
    local version="${1:-$(_php_current_version)}"
    local php_bin="/usr/bin/php${version}"
    
    # Use specified version or current
    if [ -n "$1" ] && [ -f "$php_bin" ]; then
        echo -e "${PHP_SWITCH_BLUE}Extensions for PHP ${version}:${PHP_SWITCH_NC}"
        echo ""
        $php_bin -m 2>/dev/null | grep -v '^\[' | sort | column
    else
        echo -e "${PHP_SWITCH_BLUE}Extensions for current PHP ($(_php_current_version)):${PHP_SWITCH_NC}"
        echo ""
        php -m 2>/dev/null | grep -v '^\[' | sort | column
    fi
    echo ""
}

# Search for available PHP modules/packages to install
php-modules() {
    local search="${1:-}"
    local current=$(_php_current_version)
    
    if [ -z "$search" ]; then
        echo -e "${PHP_SWITCH_BLUE}Available PHP ${current} packages:${PHP_SWITCH_NC}"
        echo ""
        apt-cache search "php${current}-" 2>/dev/null | sort | head -30
        echo ""
        echo -e "${PHP_SWITCH_YELLOW}Showing first 30 results. Use 'php-modules <keyword>' to search.${PHP_SWITCH_NC}"
    else
        echo -e "${PHP_SWITCH_BLUE}Searching for '${search}' in PHP ${current} packages:${PHP_SWITCH_NC}"
        echo ""
        apt-cache search "php${current}-" 2>/dev/null | grep -i "$search" | sort
    fi
    echo ""
}

# Install a PHP extension for current version
php-install() {
    local extension="$1"
    local current=$(_php_current_version)
    
    if [ -z "$extension" ]; then
        echo -e "${PHP_SWITCH_RED}Usage:${PHP_SWITCH_NC} php-install <extension>"
        echo "Example: php-install curl"
        return 1
    fi
    
    local package="php${current}-${extension}"
    echo -e "${PHP_SWITCH_BLUE}Installing ${package}...${PHP_SWITCH_NC}"
    sudo apt-get install -y "$package"
}

# List remote PHP versions available from Ondřej PPA (like nvm ls-remote)
php-ls-remote() {
    local filter="${1:-}"
    local show_all=false
    local show_lts=false
    local current=$(_php_current_version)
    local installed_versions=$(_php_get_versions | tr '\n' ' ')
    
    # Parse arguments
    case "$filter" in
        --lts)
            show_lts=true
            filter=""
            ;;
        --all)
            show_all=true
            filter=""
            ;;
        -h|--help)
            echo -e "${PHP_SWITCH_BLUE}Usage:${PHP_SWITCH_NC} php-ls-remote [options] [version]"
            echo ""
            echo "Options:"
            echo "  --lts     Show only LTS/Active Support versions"
            echo "  --all     Show all versions including EOL"
            echo "  <version> Filter by major version (e.g., 8, 8.3)"
            echo ""
            echo "Examples:"
            echo "  php-ls-remote           Show supported versions"
            echo "  php-ls-remote --lts     Show only LTS versions"
            echo "  php-ls-remote --all     Show all versions"
            echo "  php-ls-remote 8         Show PHP 8.x versions"
            return 0
            ;;
    esac
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        echo -e "${PHP_SWITCH_RED}Error: curl is required but not installed.${PHP_SWITCH_NC}"
        echo "Install with: sudo apt install curl"
        return 1
    fi
    
    echo -e "${PHP_SWITCH_BLUE}Fetching PHP version data...${PHP_SWITCH_NC}"
    
    # Fetch version data from endoflife.date API (provides accurate support dates)
    local api_json=$(curl -s "https://endoflife.date/api/php.json" 2>/dev/null)
    
    if [ -z "$api_json" ] || [ "$api_json" = "[]" ]; then
        echo -e "${PHP_SWITCH_RED}Error: Could not fetch release data${PHP_SWITCH_NC}"
        echo -e "${PHP_SWITCH_YELLOW}Falling back to cached data...${PHP_SWITCH_NC}"
        _php_ls_remote_fallback "$filter" "$show_all" "$show_lts" "$current" "$installed_versions"
        return
    fi
    
    echo ""
    echo -e "${PHP_SWITCH_BLUE}╔═══════════════════════════════════════════════════════════════╗${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}║              Available PHP Versions (Remote)                  ║${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}╚═══════════════════════════════════════════════════════════════╝${PHP_SWITCH_NC}"
    echo ""
    
    # Print header
    printf "  %-10s %-12s %-18s %s\n" "VERSION" "LATEST" "STATUS" "SUPPORT"
    echo "  ────────────────────────────────────────────────────────────"
    
    # Get current date for comparison
    local current_date=$(date +%Y-%m-%d)
    
    # Parse JSON line by line (works without jq)
    # Extract each version entry
    echo "$api_json" | grep -oP '\{[^}]+\}' | while read -r entry; do
        # Extract fields from JSON entry
        local ver=$(echo "$entry" | grep -oP '"cycle"\s*:\s*"\K[^"]+')
        local latest=$(echo "$entry" | grep -oP '"latest"\s*:\s*"\K[^"]+')
        local support_end=$(echo "$entry" | grep -oP '"support"\s*:\s*"\K[^"]+')
        local eol_date=$(echo "$entry" | grep -oP '"eol"\s*:\s*"\K[^"]+')
        local release_date=$(echo "$entry" | grep -oP '"releaseDate"\s*:\s*"\K[^"]+')
        
        # Skip if version not found
        [ -z "$ver" ] && continue
        
        # Apply filter if specified
        if [ -n "$filter" ]; then
            if [[ ! "$ver" == "$filter"* ]]; then
                continue
            fi
        fi
        
        # Determine status based on dates
        local status=""
        local status_text=""
        local support_text=""
        local color=""
        local label=""
        
        # Compare dates to determine status
        if [[ "$current_date" < "$support_end" ]] || [[ "$current_date" == "$support_end" ]]; then
            status="active"
            status_text="Active Support"
            support_text="until ${support_end}"
            color="${PHP_SWITCH_GREEN}"
        elif [[ "$current_date" < "$eol_date" ]] || [[ "$current_date" == "$eol_date" ]]; then
            status="security"
            status_text="Security Only"
            support_text="until ${eol_date}"
            color="${PHP_SWITCH_YELLOW}"
        else
            status="eol"
            status_text="End of Life"
            support_text="ended ${eol_date}"
            color="${PHP_SWITCH_RED}"
        fi
        
        # Check if this is the latest version
        local first_ver=$(echo "$api_json" | grep -oP '"cycle"\s*:\s*"\K[^"]+' | head -1)
        if [ "$ver" = "$first_ver" ]; then
            label="Latest"
        fi
        
        # Skip EOL if not showing all
        if [ "$show_all" = false ] && [ "$status" = "eol" ]; then
            continue
        fi
        
        # Skip non-active if showing only LTS
        if [ "$show_lts" = true ] && [ "$status" != "active" ]; then
            continue
        fi
        
        # Check if installed
        local installed_marker="  "
        if [[ " $installed_versions " == *" $ver "* ]]; then
            installed_marker="✓ "
        fi
        
        # Check if current
        local current_marker=""
        if [ "$ver" = "$current" ]; then
            current_marker=" (current)"
            color="${PHP_SWITCH_GREEN}"
        fi
        
        # Add label if applicable
        local lts_label=""
        if [ -n "$label" ]; then
            lts_label=" (${label})"
        fi
        
        # Print version line
        echo -e "  ${installed_marker}${color}$(printf '%-8s' "$ver")${PHP_SWITCH_NC} $(printf '%-12s' "$latest") ${color}$(printf '%-18s' "$status_text")${PHP_SWITCH_NC} ${support_text}${current_marker}${PHP_SWITCH_CYAN}${lts_label}${PHP_SWITCH_NC}"
    done
    
    echo ""
    echo -e "  ${PHP_SWITCH_CYAN}Legend:${PHP_SWITCH_NC} ✓ = Installed"
    echo -e "  ${PHP_SWITCH_GREEN}■${PHP_SWITCH_NC} Active Support  ${PHP_SWITCH_YELLOW}■${PHP_SWITCH_NC} Security Only  ${PHP_SWITCH_RED}■${PHP_SWITCH_NC} End of Life"
    echo ""
    
    # Show installation hint
    echo -e "${PHP_SWITCH_CYAN}To install a version:${PHP_SWITCH_NC}"
    echo "  sudo add-apt-repository ppa:ondrej/php"
    echo "  sudo apt update"
    echo "  sudo apt install php<version>   # e.g., sudo apt install php8.4"
    echo ""
}

# Fallback function with cached data (used when network is unavailable)
_php_ls_remote_fallback() {
    local filter="$1"
    local show_all="$2"
    local show_lts="$3"
    local current="$4"
    local installed_versions="$5"
    
    echo -e "${PHP_SWITCH_BLUE}╔═══════════════════════════════════════════════════════════════╗${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}║         Available PHP Versions (Cached Data)                  ║${PHP_SWITCH_NC}"
    echo -e "${PHP_SWITCH_BLUE}╚═══════════════════════════════════════════════════════════════╝${PHP_SWITCH_NC}"
    echo ""
    
    # Cached version data (fallback only)
    local php_versions=(
        "8.5:active:Latest:until 2029-12-31"
        "8.4:active::until 2028-12-31"
        "8.3:security::until 2027-12-31"
        "8.2:security::until 2026-12-31"
        "8.1:security::until 2025-12-31"
        "8.0:eol::ended 2023-11-26"
        "7.4:eol::ended 2022-11-28"
        "7.3:eol::ended 2021-12-06"
        "7.2:eol::ended 2020-11-30"
    )
    
    printf "  %-10s %-18s %s\n" "VERSION" "STATUS" "SUPPORT"
    echo "  ─────────────────────────────────────────────────"
    
    for version_info in "${php_versions[@]}"; do
        IFS=':' read -r ver status label support_text <<< "$version_info"
        
        if [ -n "$filter" ] && [[ ! "$ver" == "$filter"* ]]; then
            continue
        fi
        
        if [ "$show_all" = false ] && [ "$status" = "eol" ]; then
            continue
        fi
        
        if [ "$show_lts" = true ] && [ "$status" != "active" ]; then
            continue
        fi
        
        local color="" status_text=""
        case "$status" in
            active) color="${PHP_SWITCH_GREEN}"; status_text="Active Support" ;;
            security) color="${PHP_SWITCH_YELLOW}"; status_text="Security Only" ;;
            eol) color="${PHP_SWITCH_RED}"; status_text="End of Life" ;;
        esac
        
        local installed_marker="  "
        [[ " $installed_versions " == *" $ver "* ]] && installed_marker="✓ "
        
        local current_marker=""
        [ "$ver" = "$current" ] && current_marker=" (current)" && color="${PHP_SWITCH_GREEN}"
        
        local lts_label=""
        [ -n "$label" ] && lts_label=" (${label})"
        
        echo -e "  ${installed_marker}${color}$(printf '%-8s' "$ver")${PHP_SWITCH_NC} ${color}$(printf '%-18s' "$status_text")${PHP_SWITCH_NC} ${support_text}${current_marker}${PHP_SWITCH_CYAN}${lts_label}${PHP_SWITCH_NC}"
    done
    
    echo ""
    echo -e "  ${PHP_SWITCH_YELLOW}Note: Using cached data. Check php.net for latest info.${PHP_SWITCH_NC}"
    echo ""
}

# Fetch latest PHP release info from php.net (requires curl)
php-latest() {
    echo -e "${PHP_SWITCH_BLUE}Fetching latest PHP releases from php.net...${PHP_SWITCH_NC}"
    echo ""
    
    if ! command -v curl &> /dev/null; then
        echo -e "${PHP_SWITCH_RED}Error: curl is required but not installed.${PHP_SWITCH_NC}"
        echo "Install with: sudo apt install curl"
        return 1
    fi
    
    # Fetch JSON from php.net releases API
    local json=$(curl -s "https://www.php.net/releases/index.php?json&max=5" 2>/dev/null)
    
    if [ -z "$json" ]; then
        echo -e "${PHP_SWITCH_RED}Error: Could not fetch release data from php.net${PHP_SWITCH_NC}"
        return 1
    fi
    
    echo -e "${PHP_SWITCH_CYAN}Latest stable releases:${PHP_SWITCH_NC}"
    echo ""
    
    # Parse and display (simple parsing without jq)
    echo "$json" | grep -oP '"[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | head -10 | while read ver; do
        local major_minor=$(echo "$ver" | grep -oP '^[0-9]+\.[0-9]+')
        local installed=""
        if [ -f "/usr/bin/php${major_minor}" ]; then
            installed="${PHP_SWITCH_GREEN} ✓${PHP_SWITCH_NC}"
        fi
        echo -e "  PHP ${PHP_SWITCH_GREEN}${ver}${PHP_SWITCH_NC}${installed}"
    done
    echo ""
}

# Compare extensions between two PHP versions
php-compare() {
    local ver1="${1:-}"
    local ver2="${2:-}"
    
    if [ -z "$ver1" ] || [ -z "$ver2" ]; then
        echo -e "${PHP_SWITCH_RED}Usage:${PHP_SWITCH_NC} php-compare <version1> <version2>"
        echo "Example: php-compare 7.4 8.3"
        return 1
    fi
    
    local php1="/usr/bin/php${ver1}"
    local php2="/usr/bin/php${ver2}"
    
    if [ ! -f "$php1" ]; then
        echo -e "${PHP_SWITCH_RED}PHP ${ver1} is not installed${PHP_SWITCH_NC}"
        return 1
    fi
    
    if [ ! -f "$php2" ]; then
        echo -e "${PHP_SWITCH_RED}PHP ${ver2} is not installed${PHP_SWITCH_NC}"
        return 1
    fi
    
    echo -e "${PHP_SWITCH_BLUE}Comparing extensions: PHP ${ver1} vs PHP ${ver2}${PHP_SWITCH_NC}"
    echo ""
    
    local ext1=$($php1 -m 2>/dev/null | grep -v '^\[' | sort)
    local ext2=$($php2 -m 2>/dev/null | grep -v '^\[' | sort)
    
    echo -e "${PHP_SWITCH_CYAN}Only in PHP ${ver1}:${PHP_SWITCH_NC}"
    comm -23 <(echo "$ext1") <(echo "$ext2") | sed 's/^/  /'
    echo ""
    
    echo -e "${PHP_SWITCH_CYAN}Only in PHP ${ver2}:${PHP_SWITCH_NC}"
    comm -13 <(echo "$ext1") <(echo "$ext2") | sed 's/^/  /'
    echo ""
}

# Tab completion for php-switch
_php_switch_completions() {
    local versions=$(_php_get_versions)
    COMPREPLY=($(compgen -W "$versions --list --current --help --info --extensions" -- "${COMP_WORDS[COMP_CWORD]}"))
}

_php_extensions_completions() {
    local versions=$(_php_get_versions)
    COMPREPLY=($(compgen -W "$versions" -- "${COMP_WORDS[COMP_CWORD]}"))
}

_php_ls_remote_completions() {
    COMPREPLY=($(compgen -W "--lts --all --help 8 8.5 8.4 8.3 8.2 8.1 7 7.4 7.3" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Register completions
complete -F _php_switch_completions php-switch
complete -F _php_switch_completions php-use
complete -F _php_extensions_completions php-extensions
complete -F _php_extensions_completions php-compare
complete -F _php_ls_remote_completions php-ls-remote

# Aliases
alias php-switch='php_switch'
alias php-use='php_switch'
