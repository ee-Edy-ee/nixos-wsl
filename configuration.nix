{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "edy";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;

  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.activationScripts = {
      postActivate = ''
        mount -o remount,rw /tmp/.X11-unix
      '';
    };

  nixpkgs.overlays = [
    (final: prev: with final; {
      systemd-wsl = final.systemd.overrideAttrs ({ patches, ... }: {
        patches = patches ++ [
          ./patches/systemd-systemctl-status-wsl.patch
        ];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    # other packages...
    git
    wget
    nodejs
  ];

  systemd.package = pkgs.systemd-wsl;

  system.stateVersion = "22.05";
}
