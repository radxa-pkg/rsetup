# shellcheck shell=bash

#
# Radxa APT sources management module
# Provides APT mirror switching and restoration functionality
#

# Get list of Radxa APT source URLs
# Output: One URL per line, first is official source, rest are mirrors
change_sources_list_radxa_urls() {
    local urls=(
        "https://mirrors.aghost.cn/radxa-deb"
        "https://mirrors.lzu.edu.cn/radxa-deb"
        "https://mirrors.hust.edu.cn/radxa-deb"
        "https://mirrors.sdu.edu.cn/radxa-deb"
        "https://mirror.nju.edu.cn/radxa-deb"
        "https://mirror.nyist.edu.cn/radxa-deb"
    )
    printf '%s\n' "${urls[@]}"
}

# Get list of Debian/Ubuntu APT mirror URLs
# Output: One URL per line, only includes mirror sources (excludes official sources)
change_sources_list_deb_urls() {
    local urls=(
        "https://mirrors.ustc.edu.cn"
        "https://mirrors.tuna.tsinghua.edu.cn"
        "https://mirrors.lzu.edu.cn"
        "https://mirrors.hust.edu.cn"
        "https://mirrors.sdu.edu.cn"
        "https://mirror.nju.edu.cn"
        "https://mirror.nyist.edu.cn"
    )
    printf '%s\n' "${urls[@]}"
}

# Get all Radxa APT source configuration file paths
# Output: One file path per line
__change_sources_get_radxa_lists() {
    shopt -s nullglob
    local files=(/etc/apt/sources.list.d/*radxa*.list)
    shopt -u nullglob

    (( ${#files[@]} == 0 )) && return 0

    printf '%s\n' "${files[@]}"
}

# Apply Radxa mirror replacement
# Args: $1 - new mirror URL
__change_sources_apply_radxa_mirror() {
    local new_mirror="$1"
    local all_mirrors=("https://radxa-repo.github.io")
    local mirror_list=()
    mapfile -t mirror_list < <(change_sources_list_radxa_urls)
    all_mirrors+=("${mirror_list[@]}")

    local file
    while IFS= read -r file; do
        [[ -n "$file" ]] || continue

        # Replace all known Radxa mirrors with new mirror
        local old_mirror
        for old_mirror in "${all_mirrors[@]}"; do
            sed -i "s|$old_mirror|$new_mirror|g" "$file"
        done
    done < <(__change_sources_get_radxa_lists)
}

# Set Radxa mirror
# Args: $1 - mirror URL
# Returns: 0 on success, 1 if mirror is not supported
change_sources_set_radxa_mirror() {
    local mirror="$1"
    local all_mirrors=()
    mapfile -t all_mirrors < <(change_sources_list_radxa_urls)

    if ! __in_array "$mirror" "${all_mirrors[@]}"; then
        echo "Unsupported Radxa mirror: $mirror" >&2
        return 1
    fi

    __change_sources_apply_radxa_mirror "$mirror"
    echo "Radxa mirror set to: $mirror" >&2
}

# Apply Debian/Ubuntu mirror replacement
# Args: $1 - new mirror URL
__change_sources_apply_deb_mirror() {
    local new_mirror="${1%/}"
    local all_mirrors=(
        "https://deb.debian.org"
        "https://deb.ubuntu.com"
    )
    local mirror_list=()
    mapfile -t mirror_list < <(change_sources_list_deb_urls)
    all_mirrors+=("${mirror_list[@]}")

    shopt -s nullglob
    local lists=(/etc/apt/sources.list /etc/apt/sources.list.d/*.list)
    shopt -u nullglob

    local file
    for file in "${lists[@]}"; do
        [[ -f "$file" ]] || continue

        # Skip Radxa source files to preserve chosen Radxa mirror
        [[ "$file" == *radxa*.list ]] && continue

        # Replace all known Debian/Ubuntu mirrors with new mirror
        local old_mirror old_mirror_norm
        for old_mirror in "${all_mirrors[@]}"; do
            old_mirror_norm="${old_mirror%/}"
            sed -i "s|$old_mirror_norm|$new_mirror|g" "$file"
        done
    done
}

# Set Debian/Ubuntu mirror
# Args: $1 - mirror URL
# Returns: 0 on success, 1 if mirror is not supported
change_sources_set_deb_mirror() {
    local mirror="$1"
    local all_mirrors=()
    mapfile -t all_mirrors < <(change_sources_list_deb_urls)

    if ! __in_array "$mirror" "${all_mirrors[@]}"; then
        echo "Unsupported Debian/Ubuntu mirror: $mirror" >&2
        return 1
    fi

    __change_sources_apply_deb_mirror "$mirror"
    echo "Debian/Ubuntu mirror set to: $mirror" >&2
}

# Restore official APT sources
# Restores both Radxa and Debian/Ubuntu sources to official sources
change_sources_restore() {
    # Restore Radxa to official source
    __change_sources_apply_radxa_mirror "https://radxa-repo.github.io"

    # Determine system type from /etc/os-release
    local os_id=""
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        os_id="$ID"
    fi

    # Determine official mirror based on OS
    local official_mirror
    case "$os_id" in
        ubuntu)
            official_mirror="https://deb.ubuntu.com"
            ;;
        debian)
            official_mirror="https://deb.debian.org"
            ;;
        *)
            echo "Unable to determine OS type from /etc/os-release" >&2
            return 1
            ;;
    esac

    # Restore Debian/Ubuntu sources to official sources
    local all_mirrors=(
        "https://deb.debian.org"
        "https://deb.ubuntu.com"
    )
    local mirror_list=()
    mapfile -t mirror_list < <(change_sources_list_deb_urls)
    all_mirrors+=("${mirror_list[@]}")

    shopt -s nullglob
    local lists=(/etc/apt/sources.list /etc/apt/sources.list.d/*.list)
    shopt -u nullglob

    local file old_mirror old_mirror_norm
    for file in "${lists[@]}"; do
        [[ -f "$file" ]] || continue

        # Skip Radxa source files
        [[ "$file" == *radxa*.list ]] && continue

        # Restore to official mirror based on detected OS
        for old_mirror in "${all_mirrors[@]}"; do
            old_mirror_norm="${old_mirror%/}"
            sed -i "s|$old_mirror_norm|$official_mirror|g" "$file"
        done
    done

    echo "APT sources restored to official sources" >&2
}
