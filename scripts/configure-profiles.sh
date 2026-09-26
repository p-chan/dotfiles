#!/bin/bash

set -e

DOTFILES_DIR="${1:-${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}}"
MISE_CONFIG_DIR="$DOTFILES_DIR/home/.config/mise"
PROFILES_DIR="$MISE_CONFIG_DIR/profiles"
CONF_D_DIR="$MISE_CONFIG_DIR/conf.d"

available_profiles="desktop server"
saved_profiles=""

for profile in $available_profiles; do
  activation="$CONF_D_DIR/profile-$profile.toml"

  if [ -L "$activation" ]; then
    saved_profiles="${saved_profiles:+$saved_profiles,}$profile"
  elif [ -e "$activation" ]; then
    echo "$activation must be a symlink managed by configure-profiles.sh." >&2
    exit 1
  fi
done

if [ "${DOTFILES_PROFILES+x}" = "x" ]; then
  requested_profiles="$DOTFILES_PROFILES"
elif [ -n "$saved_profiles" ]; then
  requested_profiles="$saved_profiles"
else
  requested_profiles="desktop"
fi

desktop_enabled=false
server_enabled=false

OLD_IFS="$IFS"
IFS=','
read -r -a requested_profile_list <<< "$requested_profiles"
IFS="$OLD_IFS"

for profile in "${requested_profile_list[@]}"; do
  profile="${profile#"${profile%%[![:space:]]*}"}"
  profile="${profile%"${profile##*[![:space:]]}"}"

  case "$profile" in
    desktop) desktop_enabled=true ;;
    server) server_enabled=true ;;
    '')
      echo "DOTFILES_PROFILES must contain at least one profile." >&2
      exit 1
      ;;
    *)
      echo "Unknown dotfiles profile: $profile (expected desktop and/or server)." >&2
      exit 1
      ;;
  esac
done

normalized_profiles=""
for profile in $available_profiles; do
  enabled=false
  case "$profile" in
    desktop) enabled="$desktop_enabled" ;;
    server) enabled="$server_enabled" ;;
  esac

  if [ "$enabled" = "true" ]; then
    normalized_profiles="${normalized_profiles:+$normalized_profiles,}$profile"
  fi
done

if [ -z "$normalized_profiles" ]; then
  echo "DOTFILES_PROFILES must contain at least one profile." >&2
  exit 1
fi

mkdir -p "$CONF_D_DIR"

# プロジェクトが独自の MISE_ENV を選んだ場合でもマシンの役割は有効なままにする必要があるので、
# 代わりにグローバルの conf.d の階層を通じて、管理しているプロファイルの設定を有効にする
for profile in $available_profiles; do
  activation="$CONF_D_DIR/profile-$profile.toml"
  target="../profiles/$profile.toml"

  case ",$normalized_profiles," in
    *",$profile,"*)
      if [ ! -f "$PROFILES_DIR/$profile.toml" ]; then
        echo "Dotfiles profile not found: $PROFILES_DIR/$profile.toml" >&2
        exit 1
      fi

      if [ -L "$activation" ] && [ "$(readlink "$activation")" = "$target" ]; then
        continue
      fi

      rm -f "$activation"
      ln -s "$target" "$activation"
      ;;
    *)
      [ ! -L "$activation" ] || rm "$activation"
      ;;
  esac
done

printf 'Active dotfiles profiles: %s\n' "$normalized_profiles"
