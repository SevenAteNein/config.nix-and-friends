# ============================================================================
# PLACEHOLDER -- REPLACE ME (see README, installation step 4)
# ============================================================================
#
# This file is deliberately broken. It is the ONE machine-specific file in the
# repo: it records which filesystems to mount (by UUID) and which kernel
# modules this particular machine's hardware needs at boot.
#
# During installation, after partitioning and mounting your disk at /mnt, run:
#
#     nixos-generate-config --root /mnt
#
# and copy the generated file over this one:
#
#     cp /mnt/etc/nixos/hardware-configuration.nix  <this repo>/hardware-configuration.nix
#     git add hardware-configuration.nix   # flakes only see git-tracked files!
#
# When you later install on different hardware (VM -> real machine), you
# regenerate and replace this file again. Everything else transfers as-is.
# ============================================================================

throw ''

  hardware-configuration.nix is still the placeholder from the repo.
  Generate the real one with `nixos-generate-config --root /mnt` during
  installation and copy it over this file. See README.md, step 4.
''
