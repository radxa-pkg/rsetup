# shellcheck shell=bash

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
  fi
}

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# -------------------------------------------------------------------
# systemd
# -------------------------------------------------------------------
__systemd_sleep_control() {
  local action="$1"
  local f="/etc/systemd/sleep.conf.d/99-disable-sleep.conf"

  if [[ "$action" == "true" ]]; then
    install -d /etc/systemd/sleep.conf.d
    cat >"$f" <<EOF
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
EOF
    systemctl mask sleep.target suspend.target hibernate.target \
      hybrid-sleep.target suspend-then-hibernate.target
  else
    rm -f "$f"
    systemctl unmask sleep.target suspend.target hibernate.target \
      hybrid-sleep.target suspend-then-hibernate.target
  fi
}

# -------------------------------------------------------------------
# logind
# -------------------------------------------------------------------
__logind_control() {
  local action="$1"
  local f="/etc/systemd/logind.conf.d/99-disable-sleep.conf"

  if [[ "$action" == "true" ]]; then
    install -d /etc/systemd/logind.conf.d
    cat >"$f" <<EOF
[Login]
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
  else
    rm -f "$f"
  fi
}

# -------------------------------------------------------------------
# GNOME schema
# -------------------------------------------------------------------
__gnome_schema_patch() {
  local action="$1"
  local schema_dir="/usr/share/glib-2.0/schemas"
  local schema_file="$schema_dir/org.gnome.settings-daemon.plugins.power.gschema.xml"
  local backup="$schema_file.bak.sleep-toggle"

  [[ -f "$schema_file" ]] || return 0

  if [[ "$action" == "true" ]]; then
    if [[ ! -f "$backup" ]]; then
      cp "$schema_file" "$backup"
    fi

    # set default timeouts to 0 (never)
    sed -i \
      -e "s|\(<key name=\"sleep-inactive-ac-timeout\" type=\"i\">\s*<default>\)[0-9]\+|\10|g" \
      -e "s|\(<key name=\"sleep-inactive-battery-timeout\" type=\"i\">\s*<default>\)[0-9]\+|\10|g" \
      "$schema_file"

    glib-compile-schemas "$schema_dir"
  else
    if [[ -f "$backup" ]]; then
      cp "$backup" "$schema_file"
      glib-compile-schemas "$schema_dir"
    fi
  fi
}

# -------------------------------------------------------------------
# GNOME user gsettings
# -------------------------------------------------------------------
__gnome_gsettings() {
  local action="$1"
  cmd_exists gsettings || return 0

  for d in /run/user/*; do
    [[ -S "$d/bus" ]] || continue
    local uid="${d##*/}"
    local user
    user="$(getent passwd "$uid" | cut -d: -f1)"
    [[ -n "$user" ]] || continue

    if [[ "$action" == "true" ]]; then
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0 || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' || true
    else
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type || true
      sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$d/bus" \
        gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type || true
    fi
  done
}

# -------------------------------------------------------------------
# KDE（best-effort）
# -------------------------------------------------------------------
__kde_control() {
  local action="$1"
  for home in /home/*; do
    [[ -d "$home/.config" ]] || continue
    local f="$home/.config/powermanagementprofilesrc"

    if [[ "$action" == "true" ]]; then
      [[ -f "$f" ]] && cp "$f" "$f.bak.sleep-toggle" || true
      cat >>"$f" <<EOF

[AC]
idleTime=0

[Battery]
idleTime=0
EOF
    fi
  done
}

# -------------------------------------------------------------------
