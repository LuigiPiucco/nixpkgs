{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.steam;

  driverSelector =
    pkgs: map (
      entry:
      with config.boot.kernelPackages;
      {
        nvidia = nvidia_x11;
        nvidiaBeta = nvidia_x11_beta;
        nvidiaVulkanBeta = nvidia_x11_vulkan_beta;
        nvidiaLegacy304 = nvidia_x11_legacy304;
        nvidiaLegacy340 = nvidia_x11_legacy340;
        nvidiaLegacy390 = nvidia_x11_legacy390;
        ati_unfree = pkgs.ati_drivers_x11;
        amdgpu-pro = pkgs.amdgpu-pro;
      }.${entry}
        or null
    ) config.services.xserver.videoDrivers;
  driverSelector32 =
    pkgs: map (
      entry:
      with config.boot.kernelPackages;
      {
        nvidia = nvidia_x11.lib32;
        nvidiaBeta = nvidia_x11_beta.lib32;
        nvidiaVulkanBeta = nvidia_x11_vulkan_beta.lib32;
        nvidiaLegacy304 = nvidia_x11_legacy304.lib32;
        nvidiaLegacy340 = nvidia_x11_legacy340.lib32;
        nvidiaLegacy390 = nvidia_x11_legacy390.lib32;
        ati_unfree = pkgs.ati_drivers_x11;
        amdgpu-pro = pkgs.amdgpu-pro;
      }.${entry}
        or null
    ) config.services.xserver.videoDrivers;

  steam = pkgs.steam.override {
    steamrt-fhs = pkgs.steamPackages.steamrt-fhs.override rec {
      videoDrivers = driverSelector;
      videoDrivers32 = driverSelector32;
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
