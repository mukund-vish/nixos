# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    themeConfig = {
      BlurRadius = "500";
      PartialBlur = "true";
    };
  };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager.users.mukund = import ./home.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Setting up SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = [ custom-sddm-astronaut ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users.mukund = {
    isNormalUser = true;
    description = "Mukund";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    resources
    vim
    wget
    git
    vscode
    antigravity
    brave
    nodejs
    fastfetch
    custom-sddm-astronaut
    kdePackages.qtmultimedia
    bibata-cursors
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- System Optimizations ---
  # Hardlink identical files in the store to save disk space
  nix.settings.auto-optimise-store = true;
  
  # Automatically clean up old Nix generations weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Maintain SSD performance
  services.fstrim.enable = true;

  # Compress RAM to swap, huge improvement for system responsiveness under load
  zramSwap.enable = true;
  # ----------------------------

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Optional but recommended
  security.polkit.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  system.stateVersion = "25.11";

}
