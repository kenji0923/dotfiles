#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo." >&2
  exit 1
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: sudo bash $0 /path/to/client-public-key.pub [port]" >&2
  exit 2
fi

key_file=$1
ssh_port=${2:-22}
target_user=${SUDO_USER:-}

if [[ ! $ssh_port =~ ^[0-9]+$ ]] ||
    ((ssh_port < 1 || ssh_port > 65535)); then
  echo "Port must be an integer from 1 through 65535: $ssh_port" >&2
  exit 2
fi

if [[ -z $target_user || $target_user == root ]]; then
  echo "Run this script as the login user via sudo; SUDO_USER is missing." >&2
  exit 1
fi

if [[ ! -r $key_file ]]; then
  echo "Public-key file is not readable: $key_file" >&2
  exit 1
fi

target_passwd=$(getent passwd "$target_user")
if [[ -z $target_passwd ]]; then
  echo "User does not exist: $target_user" >&2
  exit 1
fi

target_group=$(id -gn "$target_user")
target_home=$(cut -d: -f6 <<<"$target_passwd")
public_key=$(sed -e 's/\r$//' -e '/^[[:space:]]*$/d' "$key_file")

if [[ -z $public_key || $public_key == *$'\n'* ]]; then
  echo "The public-key file must contain exactly one non-empty key line." >&2
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server

if ! ssh-keygen -l -f <(printf '%s\n' "$public_key") >/dev/null; then
  echo "Invalid OpenSSH public key: $key_file" >&2
  exit 1
fi

ssh_dir="$target_home/.ssh"
authorized_keys="$ssh_dir/authorized_keys"
install -d -m 700 -o "$target_user" -g "$target_group" "$ssh_dir"
touch "$authorized_keys"
chown "$target_user:$target_group" "$authorized_keys"
chmod 600 "$authorized_keys"

if ! grep -qxF "$public_key" "$authorized_keys"; then
  printf '%s\n' "$public_key" >>"$authorized_keys"
fi

config_path=/etc/ssh/sshd_config.d/60-wsl-external.conf
config_tmp=$(mktemp)
trap 'rm -f "$config_tmp"' EXIT
printf '%s\n' \
  "Port $ssh_port" \
  'AddressFamily any' \
  'ListenAddress 0.0.0.0' \
  'ListenAddress ::' \
  'PubkeyAuthentication yes' \
  'PasswordAuthentication no' \
  'KbdInteractiveAuthentication no' \
  'PermitRootLogin no' \
  "AllowUsers $target_user" >"$config_tmp"
install -m 644 -o root -g root "$config_tmp" "$config_path"

sshd -t
systemctl enable --now ssh.service
systemctl restart ssh.service

if command -v ufw >/dev/null && ufw status | grep -q '^Status: active'; then
  ufw allow "$ssh_port/tcp" comment 'WSL SSH'
fi

echo "OpenSSH is listening on TCP/$ssh_port with public-key-only authentication for $target_user."
ss -ltn "sport = :$ssh_port"
