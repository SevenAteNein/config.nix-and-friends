# My personal NixOS config and her accoutrements,<br><sup>*gen. 2*

Flake-based NixOS 26.05 for the machine `computah`, user `aggi`.
Hyprland + Noctalia desktop, German system language, five input systems,
AMD CPU and GPU hardware support. Build first in VM through SSH, later ported
to metal.

## Repo map

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
The user's **personal(ized) environment** (keybinds, dotfiles, per-user app config) lives
in `home.nix`. Both are applied together by one rebuild.

## Step 0 — pushing to GitHub

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

> **Avoiding the "flake trap"** flakes only see files **tracked by git**. A file
> you created but never `git add`-ed is invisible, producing baffling
> "No such file or directory" errors. When in doubt: `git add .`

## Step 1 — make the test VM

Download the NixOS ISO (graphical or minimal, either works) from nixos.org.

VirtualBox settings that matter:

- **System → Enable EFI: ON.** Non-negotiable — this config uses the
  `systemd-boot` UEFI bootloader; a BIOS-mode VM cannot boot it.
- 8 GB RAM *(if you can allocate 16, do it, and you can un-comment-out
  RAM-heavy builds like bambu-lab)*, 4 CPUs, 60+ GB disk.
  *(This should also foreshadow some caveats that come with building
  this on a virtual GPU)*
- Display → 3D acceleration ON, video memory maxed. Hyprland is a
  GPU-rendered compositor; in a VM it runs on emulated graphics and will feel
  sluggish. That's expected and should not be seen as representative of the
  way it operates once ported to metal — the purpose of the VM is to validate
  your *configuration*, not performance. *(Though. if the mouse cursor is 
  invisible in the VM, add `cursor { no_hardware_cursors = true }` to the 
  Hyprland settings)*.

What the VM *cannot* test: everything in `modules/hardware.nix` that touches
the real GPU (amdgpu, Vulkan, ROCm, Steam performance). Those options are
harmless in the VM (the driver finds no hardware and idles) but only provable
on the metal.

## Step 2 — boot the ISO, become root

```
sudo -i
```

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

`hardware-configuration.nix` will record filesystems by
UUID/label, so mounting by label now keeps things unambiguous. (Later
upgrade path: `disko` declares this partitioning in the repo so it need
not be typed again.)

## Step 4 — Push the repo to the machine

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

Then push the hardware file (that you should have adapted to your conditions) back up:

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

## Maintenance considerations

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

## Known caveats

- Like much GUI-heavy software, **Ollama is well-optimized for AMD GPUs**.
  gfx1201 (RDNA 4) compute support is bleeding-edge
  in ROCm, and nixpkgs' ROCm can trail upstream. If `ollama ps` shows CPU
  instead of GPU: try Ollama's experimental Vulkan backend
  (`OLLAMA_VULKAN=1` in the service's environment), or run the official
  `ollama/ollama:rocm` container. Gaming/Vulkan are unaffected either way.
- Concerning **VirtualBox**, `linuxPackages_latest` occasionally
  outruns VirtualBox's kernel module. If a rebuild fails there, wait a few
  days and `update` again, or temporarily comment VirtualBox out.
- **`unstable.musescore` tracks nixpkgs-unstable**, which
  chases upstream 4.7.x with some lag. Check with `mscore --version`; if you
  must have today's upstream release, the AppImage via `appimage-run` is the
  stopgap.
- **VS Code & Noctalia's settings are intentionally left untouched** so their GUIs
  keep working. Both can be inducted into the config later.
- Concerning **Tor**, it can be better to leave it unmodified. Customizing it would
  make your fingerprint unique, defeating the philosophy and utility of the
  browser.
