{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.steam;

  steam = pkgs.steam.override {
    extraLibraries = with config.hardware.opengl; pkgs: [ (
      if pkgs.hostPlatform.is64bit then package else package32
    ) ];
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

    environment.systemPackages = [ steam ] ++ (with pkgs; [ gcc.cc.lib libGL ]);
  };

  meta.maintainers = with maintainers; [ mkg20001 ];
}
