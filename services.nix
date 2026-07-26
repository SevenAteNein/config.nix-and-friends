{ pkgs, ... }:

{
  ###### VirtualBox ###########################################################

  # Builds VirtualBox's kernel module against your kernel and starts its host
  # services. Heads-up: because we run linuxPackages_latest, a brand-new
  # kernel can occasionally be TOO new for VirtualBox's module to compile
  # against. If a rebuild ever fails inside "virtualbox-modules", either wait
  # a few days and update again, or temporarily comment this out.
  virtualisation.virtualbox.host.enable = true;

  ###### Local LLMs: Ollama + Open WebUI ######################################

  # Ollama = the inference server (downloads and runs models).
  services.ollama = {
    enable = true;
    # Ask for AMD-GPU compute. Honest caveat: your 9070 XT's compute arch
    # (gfx1201) only gained official ROCm support recently, and nixpkgs' ROCm
    # can trail upstream. If models run on CPU instead of GPU, see the README's
    # "known caveats" for the fallbacks (Vulkan backend / official container).
    # Everything else about the GPU -- gaming, Vulkan, video -- is unaffected;
    # ROCm is only the compute stack.
    acceleration = "rocm";
  };

  # Open WebUI = the browser frontend, i.e. the de-facto "Ollama GUI".
  # After a rebuild: http://localhost:8080
  services.open-webui = {
    enable = true;
    port = 8080;
  };

  ###### VPN (Windscribe via WireGuard) #######################################

  # Windscribe ships no NixOS client. The clean route: in your Windscribe
  # account page, generate a WireGuard config file, place it at
  # /etc/wireguard/windscribe.conf (it contains your private key -- that is a
  # secret; it does NOT go into this git repo), then uncomment:
  #
  # networking.wg-quick.interfaces.windscribe = {
  #   configFile = "/etc/wireguard/windscribe.conf";
  #   autostart = false;   # bring up/down on demand:
  #                        #   sudo systemctl start wg-quick-windscribe
  #                        #   sudo systemctl stop  wg-quick-windscribe
  # };
  #
  # (Proper secret management -- sops-nix / agenix -- is a good later chapter.)
}
