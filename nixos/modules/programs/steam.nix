{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.steam;

  driverSelector =
    entry:
    with config.boot.kernelPackages;
      {
        nvidia = nvidia_x11;
        nvidiaBeta = nvidia_x11_beta;
        nvidiaVulkanBeta = nvidia_x11_vulkan_beta;
        nvidiaLegacy304 = nvidia_x11_legacy304;
        nvidiaLegacy340 = nvidia_x11_legacy340;
        nvidiaLegacy390 = nvidia_x11_legacy390;
        ati_unfree = ati_drivers_x11;
        amdgpu-pro = amdgpu-pro;
      }.${entry}
        or null;

  steam = pkgs.steam.override {
    steamrt-fhs = pkgs.steamPackages.steamrt-fhs.override {
      videoDrivers = map driverSelector config.services.xserver.videoDrivers;
    };
  };
in {
  options.programs.steam.enable = mkEnableOption "steam";

  config = mkIf cfg.enable {
    hardware.opengl = { # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      driSupport32Bit = true;
    };

    # optionally enable 32bit pulseaudio support if pulseaudio is enabled
    hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;

    hardware.steam-hardware.enable = true;

    environment.systemPackages = [ steam ];
  };

  meta.maintainers = with maintainers; [ mkg20001 ];
}
