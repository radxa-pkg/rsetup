# shellcheck shell=bash

__yz-update-overlays() {
    # shellcheck disable=SC2034
    local ABI="${1:-}" IMAGE="${2:-}"

    exec </dev/null >&2
    eval set -- "$DEB_MAINT_PARAMS"
    # shellcheck disable=SC2034
    local ACTION="${1:-}" VERSION="${2:-}"

    case $ACTION in
        configure)
            echo "Updating overlays for $ABI ..."
            reset_overlays "$ABI" "$(get_soc_vendor)"
            ;;
        remove)
            ;;
    esac
}