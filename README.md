# computah — NixOS configuration

Flake-based NixOS 26.05 for the machine `computah`, user `aggi`.
Hyprland + Noctalia desktop, German system language, five input systems,
AMD 7800X3D / RX 9070 XT hardware support.

## Repo map — where everything lives

```
flake.nix                    inputs (nixpkgs, home-manager, noctalia) + the
                             `computah` system definition. The entry point.
flake.lock                   appears after the first build; pins every input
                             to exact commits. COMMIT IT — it is what makes
                             the config reproducible.
hardware-configuration.nix   THE machine-specific file. Placeholder until you
                             generate the real one during install (step 4).
configuration.nix            hostname, bootloader, user aggi, nix settings,
                             the `rebuild` alias, unstable overlay.
modules/hardware.nix         CPU/GPU/firmware/kernel for the real machine.
modules/locale-input.nix     German locale + fcitx5 (Pinyin & friends).
modules/desktop.nix          Hyprland, SDDM, PipeWire, portals, fonts.
modules/software.nix         the application list, Steam.
modules/services.nix         VirtualBox, Ollama + Open WebUI, VPN stub.
home.nix                     aggi's user space: Noctalia, Hyprland keybinds,
                             Waterfox baked-in config, git.
```

The general principle: **system-wide things** (drivers, services, login
manager, packages for all users) live in `configuration.nix`/`modules/`;
**your personal environment** (keybinds, dotfiles, per-user app config) lives
in `home.nix`. Both are applied together by one rebuild.

## Step 0 — put this repo on GitHub

On any machine with git:

```
cd nixos-config
git init
git add .
git commit -m "initial config for computah"
# create an empty repo named nixos-config on github.com, then:
git remote add origin https://github.com/YOURNAME/nixos-config.git
git push -u origin main
```

Why before installing: the installer will *clone* this repo, which is both the
cleanest way to get the files into the installer environment and your first
taste of the workflow.

> **The classic flake trap:** flakes only see files **tracked by git**. A file
> you created but never `git add`-ed is invisible, producing baffling
> "No such file or directory" errors. When in doubt: `git add .`

## Step 1 — make the test VM

Download the NixOS ISO (graphical or minimal, either works) from nixos.org.

VirtualBox settings that matter:

- **System → Enable EFI: ON.** Non-negotiable — this config uses the
  `systemd-boot` UEFI bootloader; a BIOS-mode VM cannot boot it.
- 8 GB RAM, 4 CPUs, 60+ GB disk.
- Display → 3D acceleration ON, video memory maxed. Hyprland is a
  GPU-rendered compositor; in a VM it runs on emulated graphics and will feel
  sluggish. That's expected — the VM validates your *configuration*, not
  performance. (If the mouse cursor is invisible in the VM, add
  `cursor { no_hardware_cursors = true }` to the Hyprland settings —
  a known VM quirk.)

What the VM *cannot* test: everything in `modules/hardware.nix` that touches
the real GPU (amdgpu, Vulkan, ROCm, Steam performance). Those options are
harmless in the VM (the driver finds no hardware and idles) but only provable
on the metal.

## Step 2 — boot the ISO, become root, get online

```
sudo -i
```

Wired/VM networking is up automatically. (On the real machine, your MoCA
Ethernet needs nothing special — the adapter presents as ordinary Ethernet.)

## Step 3 — partition and mount

Find your disk name first — `lsblk`. It's `/dev/sda` in VirtualBox, `/dev/vda`
in QEMU, likely `/dev/nvme0n1` on the real machine (partitions then named
`nvme0n1p1`, `p2`). **Substitute accordingly; the commands below erase the
disk they're pointed at.**

```
DISK=/dev/sda   # <-- ADJUST

parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MB 1GB        # EFI system partition
parted $DISK -- set 1 esp on
parted $DISK -- mkpart root ext4 1GB 100%       # everything else

mkfs.fat -F32 -n BOOT ${DISK}1                  # (nvme: ${DISK}p1)
mkfs.ext4 -L nixos ${DISK}2                     # (nvme: ${DISK}p2)

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot
```

Why labels: `hardware-configuration.nix` will record filesystems by
UUID/label, so mounting by label now keeps things unambiguous. (Later
upgrade path: `disko` declares this partitioning *in the repo* so you never
type it again.)

## Step 4 — marry the repo to this machine

```
# generate the machine-specific file
nixos-generate-config --root /mnt

# get git + clone the repo into the future home directory
nix-shell -p git
mkdir -p /mnt/home/aggi
git clone https://github.com/YOURNAME/nixos-config /mnt/home/aggi/nixos-config
cd /mnt/home/aggi/nixos-config

# replace the placeholder with the real hardware file, and TRACK it
cp /mnt/etc/nixos/hardware-configuration.nix .
git add hardware-configuration.nix
```

This is the "where everything integrates" moment: the repo carries the
universal description of `computah`; `hardware-configuration.nix` is the one
piece of local truth (filesystem UUIDs, required kernel modules) that welds it
to a particular box.

## Step 5 — install and reboot

```
nixos-install --flake .#computah
# builds everything; asks you to set the ROOT password at the end
reboot
```

Log in at the SDDM screen as `aggi`, password `changeme`. **Immediately** open
a terminal (SUPER+Return) and run `passwd`. Also fix ownership of the repo
(it was cloned by root):

```
sudo chown -R aggi:users ~/nixos-config
```

Then push the now-married hardware file back up:

```
cd ~/nixos-config && git commit -am "add computah hardware config" && git push
```

## Step 6 — first-boot configuration (the deliberately-imperative bits)

- **Input methods:** run `fcitx5-configtool`. Add, in order: Keyboard-German,
  Keyboard-Hebrew, Keyboard-Arabic (pick your variant — see the comment in
  `modules/locale-input.nix`), Keyboard-English (Dvorak), and Pinyin.
  Ctrl+Space cycles through all five, everywhere.
- **Noctalia:** open its settings panel (from the bar) and configure your
  dock: enable it, position center, floating. It writes
  `~/.config/noctalia/settings.json` — later, when you're happy, copy that
  JSON into `programs.noctalia.settings` in `home.nix` to freeze it. (Frozen
  = reproducible but read-only to the GUI; freeze when done iterating.)
- **BetterDiscord:** launch Discord once, quit it, run
  `betterdiscordctl install`. Repeat after Discord updates undo it.
- **Windscribe:** follow the comment block in `modules/services.nix`.

## Step 7 — the same thing on the real machine

Identical procedure, steps 2–6, with exactly one difference: step 4 generates
a *new* `hardware-configuration.nix` from the real hardware and you overwrite
the VM's version (commit it — since the VM was a disposable rehearsal,
overwriting is fine). Everything else — every package, keybind, locale —
arrives exactly as rehearsed.

## Daily workflow

```
# edit any .nix file, then:
git add -A          # remember: flakes only see tracked files
rebuild             # the alias from configuration.nix
git commit -am "describe the change" && git push

# update all inputs (new package versions) and apply:
update              # also an alias

# something broke? reboot and pick the previous generation in the
# systemd-boot menu — instant rollback. Or without rebooting:
sudo nixos-rebuild switch --rollback
```

## Known caveats, honestly stated

- **Ollama on the 9070 XT:** gfx1201 (RDNA 4) compute support is bleeding-edge
  in ROCm, and nixpkgs' ROCm can trail upstream. If `ollama ps` shows CPU
  instead of GPU: try Ollama's experimental Vulkan backend
  (`OLLAMA_VULKAN=1` in the service's environment), or run the official
  `ollama/ollama:rocm` container. Gaming/Vulkan are unaffected either way.
- **VirtualBox vs. newest kernel:** `linuxPackages_latest` occasionally
  outruns VirtualBox's kernel module. If a rebuild fails there, wait a few
  days and `update` again, or temporarily comment VirtualBox out.
- **MuseScore version:** `unstable.musescore` tracks nixpkgs-unstable, which
  chases upstream 4.7.x with some lag. Check with `mscore --version`; if you
  must have today's upstream release, the AppImage via `appimage-run` is the
  stopgap.
- **VS Code & Noctalia settings are intentionally unmanaged** so their GUIs
  keep working. Both can be "frozen" into the config later — a one-way door
  you choose per app, per moment.
- **Tor Browser:** stable and unmodified on purpose. Customizing it would
  make your fingerprint unique, defeating the tool.
