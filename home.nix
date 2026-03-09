{ config, pkgs, ... }:

{
  home.username = "mukund";
  home.homeDirectory = "/home/mukund";

  programs.git = {
    enable = true;
    userName = "mukund-dev";
    userEmail = "terryterros86@gmail.com";
  };

  programs.bash.enable = true;

  home.stateVersion = "25.11";
}
