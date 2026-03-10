{ config, pkgs, ... }:

{
  home.username = "mukund";
  home.homeDirectory = "/home/mukund";

  programs.git = {
    enable = true;
    userName = "mukund-vish";
    userEmail = "terryterros86@gmail.com";

    extraConfig = {
      credential.helper = "store";
    };
  };

  programs.bash.enable = true;

  home.stateVersion = "25.11";
}
