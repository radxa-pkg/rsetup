# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("remove_packages")

__depends_package() {
    local p missing_packages=()
    for p in "$@"
    do
        if ! dpkg -l "$p" &>/dev/null
        then
            missing_packages+=( "$p" )
        fi
    done

    if (( ${#missing_packages[@]} != 0 ))
    then
        if ! yesno "This feature requires the following packages: ${missing_packages[*]}.

Do you want to install them right now?"
        then
            return 1
        fi
        apt-get update
        apt-get install --no-install-recommends -y "${missing_packages[@]}"
    fi
}

remove_packages() {
    apt-get autoremove -y "$@"
}
