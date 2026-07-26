{ pkgs, ... }:

# Ryzen 7 7800X3D + Radeon RX 9070 XT (RDNA 4) + 32 GB DDR5 + 4 TB SSD.
#
# The big picture: on Linux, AMD's GPU "driver" is the in-kernel `amdgpu`
# module plus Mesa in userspace. There is no separate driver package to
# install (unlike NVIDIA). Our job is only to make sure the pieces are NEW
# enough, because RDNA 4 is recent silicon.
#
# Note: every option here is harmless inside a VM (the amdgpu module simply
# finds no matching hardware and stays idle), so the same file serves both
# your test VM and the real machine.

{
  # Stable NixOS defaults to an older LTS kernel; the 9070 XT wants the newest.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Load the GPU driver already in the initrd (the mini-system that runs in
  # the first moments of boot) so the display works from the start, not only
  # once the full system is up.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # AMD ships bugfixes for the CPU silicon itself; without this you run
  # whatever microcode your motherboard vendor last flashed in a BIOS update.
  hardware.cpu.amd.updateMicrocode = true;

  # Firmware blobs from linux-firmware -- the 9070 XT will not initialize
  # without its firmware. (This is NixOS's default, stated here explicitly
  # because it is essential for this machine.)
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable = true;
    # A 32-bit copy of Mesa next to the 64-bit one. Why: Steam/Wine run many
    # 32-bit games, and a 32-bit game process can only load 32-bit graphics
    # libraries.
    enable32Bit = true;
  };

  # Periodic TRIM tells the SSD which blocks are free; keeps write performance
  # and drive longevity healthy.
  services.fstrim.enable = true;

  # Compressed swap in RAM. With 32 GB you will rarely swap at all, but this
  # makes the rare case graceful instead of disk-thrashing.
  zramSwap.enable = true;

  # Reminder that lives outside this file: DDR5-6000 is reached by enabling
  # EXPO in the BIOS. The operating system cannot see or set memory profiles.
}
