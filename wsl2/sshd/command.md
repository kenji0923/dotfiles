# WSL2 SSH server commands

## Purpose and prerequisites

These commands expose a WSL2 distribution through SSH while keeping password
and root login disabled. They assume that systemd is enabled and that
`networkingMode=mirrored` is configured in `.wslconfig`.

Mirrored networking lets the LAN reach WSL directly, so no `netsh portproxy`
rule is needed. Only the selected SSH port is opened; the firewall script
requires an explicit source address or subnet.

## Configure Ubuntu

First generate a key on the computer that will connect to WSL:

```sh
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_wsl
```

Copy only `id_ed25519_wsl.pub` to the Windows computer. Then, from this
repository directory in WSL, pass its path and SSH port to the setup script.
This example uses TCP/2222:

```sh
sudo bash ./setup-wsl-sshd.sh /path/to/id_ed25519_wsl.pub 2222
```

Omit the final argument to use the default port, TCP/22. Valid custom values are
integers from 1 through 65535; choose a port not used by another service.

The script installs `openssh-server`, adds the public key for the invoking user,
disables password/interactive/root login, validates the SSH configuration, and
enables and starts `ssh.service`. If UFW is already active, it also permits
the selected TCP port through UFW.

## Configure the Windows Hyper-V firewall

Copy `setup-wsl-ssh-firewall.ps1` to a Windows-accessible location, and open
PowerShell **as Administrator**. For the safest rule, replace the example
documentation address below with the public IP of the computer that will
connect:

```powershell
powershell.exe -ExecutionPolicy Bypass -File `
  "C:\path\to\setup-wsl-ssh-firewall.ps1" `
  -RemoteAddress "203.0.113.10" -Port 2222
```

For a trusted subnet, pass its address in CIDR notation. If the client address
changes and access from anywhere is truly required, use `Any`; public-key
authentication remains mandatory:

```powershell
powershell.exe -ExecutionPolicy Bypass -File `
  "C:\path\to\setup-wsl-ssh-firewall.ps1" `
  -RemoteAddress "Any" -Port 2222
```

## Verify and connect

Run in WSL:

```sh
systemctl status ssh --no-pager
ss -ltn 'sport = :2222'
ssh-keygen -lf ~/.ssh/authorized_keys
```

Run on the external client:

```sh
ssh -p 2222 -i ~/.ssh/id_ed25519_wsl <WslUser>@<WindowsHostOrIp>
```

Check the current address in WSL with:

```sh
hostname -I
```

If the service works locally but an external connection times out, an upstream
router, organizational firewall, VPN policy, or ISP may still block the selected
inbound TCP port.

## Diagnostic commands used

Use these non-mutating checks before applying the configuration:

```sh
uname -a
cat /etc/os-release
systemctl is-system-running
dpkg-query -W openssh-server
systemctl status ssh --no-pager
hostname -I
ip -brief address show
ip route show
ss -ltnp 'sport = :22'
wsl.exe --version
wsl.exe --status
```

From PowerShell, the equivalent firewall checks are:

```powershell
$id = '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}'
Get-NetFirewallHyperVVMSetting -PolicyStore ActiveStore -Name $id
Get-NetFirewallHyperVRule -VMCreatorId $id
Get-NetTCPConnection -State Listen -LocalPort 22
Get-NetIPConfiguration
```

## Check for machine-specific data before publication

Search the repository for IPv4 literals. Review each match because documentation
ranges, such as `203.0.113.0/24`, are intentionally safe examples:

```sh
rg -n --pcre2 --hidden -g '!.git/**' \
  '(?<![0-9])(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?:/[0-9]{1,2})?(?![0-9])' .
```

Search separately for known local usernames, hostnames, and absolute paths,
replacing the placeholders with the private values being checked:

```sh
rg -n --hidden -g '!.git/**' \
  -e '<local-user>' -e '<local-host>' -e '<local-absolute-path>' .
```

## Roll back

Remove only the rule and SSH override created here:

```powershell
Remove-NetFirewallHyperVRule -Name 'Codex-WSL-SSH'
```

```sh
sudo systemctl disable --now ssh.service
sudo rm /etc/ssh/sshd_config.d/60-wsl-external.conf
```

The installed package and `~/.ssh/authorized_keys` are deliberately retained.
