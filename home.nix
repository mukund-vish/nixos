{ config, pkgs, lib, ... }:
{
  home.username = "mukund";
  home.homeDirectory = "/home/mukund";

  programs.git = {
    enable = true;
    settings = {
      user.name = "mukund-vish";
      user.email = "terryterros86@gmail.com";
      credential.helper = "store";
    };
  };

  programs.bash.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
    };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_ICON_THEME = "Papirus-Dark";
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  home.packages = with pkgs; [
    rofi
    swww
    hyprlock
    grim
    slurp
    wl-clipboard
    copyq
    brightnessctl
    pavucontrol
    networkmanagerapplet
    nerd-fonts.jetbrains-mono
    papirus-icon-theme
    pamixer
    playerctl
    blueman
    bluez
    libnotify
    hyprpicker
    wlogout
    swaynotificationcenter
    gnome-calendar
  ];

  systemd.user.services.copyq-clear-on-shutdown = {
  Unit = {
    Description = "Clear CopyQ history on shutdown";
    DefaultDependencies = false;
    Before = [ "shutdown.target" "reboot.target" "halt.target" ];
  };
  Service = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStop = "copyq clear";
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
};
  # ── Hyprlock ──────────────────────────────────────────────────────────
programs.hyprlock = {
  enable = true;
  settings = {
    general = {
      disable_loading_bar = true;
      hide_cursor = true;
      grace = 0;
    };

    background = [{
      path = "/home/mukund/Pictures/wallpaper.png";
      blur_passes = 3;
      blur_size = 7;
      brightness = 0.6;
    }];

    input-field = [{
      size = "280, 48";
      position = "0, -80";
      halign = "center";
      valign = "center";
      outline_thickness = 1;
      dots_size = 0.25;
      dots_spacing = 0.2;
      inner_color = "rgba(13, 14, 26, 0.85)";
      outer_color = "rgba(122, 162, 247, 0.25)";
      font_color = "rgb(192, 202, 245)";
      fade_on_empty = true;
      placeholder_text = "<span foreground=\"##565f89\">󰍁  Enter Password</span>";
      fail_color = "rgb(247, 118, 142)";
      fail_text = "<span foreground=\"##f7768e\">󰍁  Wrong password</span>";
      check_color = "rgb(224, 175, 104)";
      capslock_color = "rgb(224, 175, 104)";
    }];

    label = [
      {
        text = "$TIME";
        font_size = 64;
        font_family = "JetBrainsMono Nerd Font";
        color = "rgba(192, 202, 245, 0.9)";
        position = "0, 80";
        halign = "center";
        valign = "center";
      }
      {
        text = ''cmd[update:60000] echo "$(date +"%A, %d %B %Y")"'';
        font_size = 16;
        font_family = "JetBrainsMono Nerd Font";
        color = "rgba(86, 95, 137, 0.9)";
        position = "0, 20";
        halign = "center";
        valign = "center";
      }
    ];
  };
};

  # ── Wlogout ───────────────────────────────────────────────────────────
programs.wlogout = {
  enable = true;
  layout = [
    { label = "lock";      action = "hyprlock";                    keybind = "l"; }
    { label = "logout";    action = "hyprctl dispatch exit 0";     keybind = "e"; }
    { label = "suspend";   action = "systemctl suspend";           keybind = "s"; }
    { label = "hibernate"; action = "systemctl hibernate";         keybind = "h"; }
    { label = "shutdown";  action = "systemctl poweroff";          keybind = "p"; }
    { label = "reboot";    action = "systemctl reboot";            keybind = "r"; }
  ];
  style = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      background: transparent;
    }

    window {
      background: rgba(13, 14, 26, 0.85);
    }

    button {
      color: #c0caf5;
      background: rgba(26, 27, 46, 0.80);
      border: 1px solid rgba(122, 162, 247, 0.12);
      border-radius: 12px;
      background-repeat: no-repeat;
      background-position: center;
      background-size: 40px;
      margin: 6px;
      transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease;
    }

    button:focus, button:hover {
      background-color: rgba(122, 162, 247, 0.10);
      border-color: rgba(122, 162, 247, 0.40);
      outline: none;
    }

    /* Shutdown gets a red tint */
    #shutdown {
      border-color: rgba(247, 118, 142, 0.20);
    }
    #shutdown:hover {
      background-color: rgba(247, 118, 142, 0.10);
      border-color: rgba(247, 118, 142, 0.50);
      color: #f7768e;
    }
    #lock     { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
  #logout   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
  #suspend  { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
  #hibernate{ background-image: url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"); }
  #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
  #reboot   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
  '';
};

  # ── Waybar ────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 36;
      spacing = 6;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;
      exclusive = true;

      modules-left = [
        "custom/dashboard"
        "hyprland/workspaces"
        "temperature"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "backlight"
        "battery#bar"
        "pulseaudio"
        "tray"
        "custom/power"
      ];

      "custom/dashboard" = {
          format = "";
          tooltip = false;
          on-click = "rofi -show drun";
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "●"; "2" = "●"; "3" = "●"; "4" = "●"; "5" = "●";
          urgent  = "●";
          active  = "●";
          default = "○";
        };
        on-click = "activate";
        sort-by-number = true;
        persistent-workspaces."*" = [ 1 2 3 4 5 ];
      };

      battery = {
        format = "{capacity}% {icon}";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        format-charging = "{capacity}% 󰂄";
        tooltip-format = "{timeTo} — {capacity}%";
        states = { warning = 30; critical = 15; };
      };

      temperature = {
        tooltip = false;
        thermal-zone = 0;
        format = "{temperatureC}°C 󰔏";
        critical-threshold = 80;
        format-critical = "{temperatureC}°C 󰸁";
      };

        clock = {
          format = "󱑂  {:%I:%M %p}";
          format-alt = "󰃭  {:%A, %d %B %Y}";
          tooltip = false;
        };
      backlight = {
        tooltip = false;
        format = "{icon} {percent}%";
        format-icons = [ "󰃞" "󰃟" "󰃠" ];
        on-scroll-up = "brightnessctl set 1%+";
        on-scroll-down = "brightnessctl set 1%-";
      };

      "battery#bar" = {
        format = "󱈑 {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-full = "󰁹 Full";
        tooltip-format = "Battery: {capacity}%\n{timeTo}";
        states = { warning = 30; critical = 15; };
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Muted";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "pavucontrol";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      "custom/power" = {
        format = "󰐥";
        tooltip = false;
        on-click = "wlogout";
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        background: transparent;
        color: #c0caf5;
      }

      tooltip {
        background: rgba(13, 14, 26, 0.95);
        border: 1px solid rgba(122, 162, 247, 0.3);
        border-radius: 10px;
        color: #c0caf5;
      }
      tooltip label {
        color: #c0caf5;
        margin: 2px;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(13, 14, 26, 0.75);
        border: 1px solid rgba(122, 162, 247, 0.12);
        border-radius: 10px;
        padding: 0 6px;
        margin: 4px 0;
      }

      .modules-left > widget > *,
      .modules-center > widget > *,
      .modules-right > widget > * {
        padding: 4px 10px;
        color: #c0caf5;
        background: transparent;
        border-radius: 8px;
        transition: background 0.2s ease, color 0.2s ease;
      }

      .modules-left > widget > *:hover,
      .modules-right > widget > *:hover {
        background: rgba(122, 162, 247, 0.12);
        color: #7aa2f7;
      }

      #custom-dashboard {
        color: #7aa2f7;
        font-size: 16px;
        padding: 4px 12px;
      }

      #workspaces { padding: 0 4px; }

      #workspaces button {
        padding: 4px 7px;
        color: #565f89;
        background: transparent;
        border-radius: 6px;
        min-width: 0;
        transition: all 0.2s ease;
      }

      #workspaces button:hover {
        background: rgba(122, 162, 247, 0.1);
        color: #7aa2f7;
      }

      #workspaces button.active {
        color: #7aa2f7;
        background: rgba(122, 162, 247, 0.18);
        border-radius: 8px;
      }

      #workspaces button.urgent {
        color: #f7768e;
        background: rgba(247, 118, 142, 0.15);
      }

      #battery { color: #c0caf5; }
      #battery.charging { color: #9ece6a; }
      #battery.warning:not(.charging) { color: #e0af68; }
      #battery.critical:not(.charging) {
        color: #f7768e;
        animation: blink 1s linear infinite;
      }

      #temperature { color: #c0caf5; }
      #temperature.critical { color: #f7768e; }

      #clock {
        color: #c0caf5;
        font-weight: 500;
        letter-spacing: 0.5px;
        padding: 4px 16px;
      }

      #bluetooth { color: #7aa2f7; }
      #bluetooth.connected { color: #7aa2f7; }
      #bluetooth.disabled { color: #565f89; }

      #network { color: #7dcfff; }
      #network.disconnected { color: #565f89; }

      #backlight { color: #e0af68; }

      #pulseaudio { color: #c0caf5; }
      #pulseaudio.muted { color: #565f89; }

      #custom-power {
        color: #f7768e;
        font-size: 15px;
        padding: 4px 12px;
      }

      #custom-power:hover {
        background: rgba(247, 118, 142, 0.15);
        color: #f7768e;
      }

      @keyframes blink {
        to { color: #f7768e; opacity: 0.5; }
      }
    '';
  };

  # ── GTK theme ─────────────────────────────────────────────────────────
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = ":";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = ":";
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:";
    };
  };

  # ── Rofi WiFi picker ──────────────────────────────────────────────────
  home.file.".local/bin/rofi-wifi" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      nmcli dev wifi rescan 2>/dev/null
      sleep 1
      networks=$(nmcli -t -f ssid,signal,security dev wifi list 2>/dev/null \
        | sort -t: -k2 -rn \
        | awk -F: '!seen[$1]++ && $1!="" {
            icon = ($3 ~ /WPA|WEP/) ? "󰤪 " : "󰤨 "
            printf "%s%s (%s%%)\n", icon, $1, $2
          }')
      chosen=$(echo "$networks" | rofi -dmenu -p "WiFi" -i)
      [ -z "$chosen" ] && exit
      ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ ([0-9]*%)$//')
      saved=$(nmcli -t -f name con show | grep -Fx "$ssid")
      if [ -n "$saved" ]; then
        nmcli con up "$ssid"
      else
        password=$(rofi -dmenu -p "Password for $ssid" -password)
        if [ -z "$password" ]; then
          nmcli dev wifi connect "$ssid"
        else
          nmcli dev wifi connect "$ssid" password "$password"
        fi
      fi
    '';
  };

  # ── Rofi config ───────────────────────────────────────────────────────
  home.file.".config/rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run";
      show-icons: true;
      icon-theme: "Papirus-Dark";
      drun-display-format: "{name}";
      disable-history: false;
      hide-scrollbar: true;
      display-drun: "   Apps";
      display-run: "   Run";
      font: "JetBrainsMono Nerd Font 13";
      kb-cancel: "Escape";
    }
    @theme "~/.config/rofi/theme.rasi"
  '';

  home.file.".config/rofi/theme.rasi".text = ''
    * {
      bg:     rgba(13, 14, 26, 97%);
      bg-alt: rgba(26, 27, 46, 80%);
      fg:     #c0caf5;
      fg-alt: #565f89;
      accent: #7aa2f7;
      urgent: #f7768e;
      background-color: transparent;
      text-color: @fg;
    }
    window {
      background-color: @bg;
      border: 1px solid;
      border-color: rgba(122, 162, 247, 30%);
      border-radius: 12px;
      width: 500px;
      padding: 12px;
    }
    mainbox { background-color: transparent; children: [inputbar, listview]; spacing: 8px; }
    inputbar { background-color: @bg-alt; border-radius: 8px; padding: 8px 12px; spacing: 8px; children: [prompt, entry]; }
    prompt { text-color: @accent; font: "JetBrainsMono Nerd Font 13"; }
    entry { text-color: @fg; placeholder: "Search..."; placeholder-color: @fg-alt; }
    listview { background-color: transparent; columns: 1; lines: 8; scrollbar: false; spacing: 4px; }
    element { background-color: transparent; border-radius: 8px; padding: 8px 12px; spacing: 8px; orientation: horizontal; children: [element-icon, element-text]; }
    element selected { background-color: rgba(122, 162, 247, 15%); text-color: @accent; }
    element-icon { size: 24px; }
    element-text { text-color: inherit; vertical-align: 0.5; }
  '';

  # ── Kitty ─────────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 13;
      background = "#1a1b2e";
      foreground = "#c0caf5";
      background_opacity = "0.92";
      cursor = "#c0caf5";
      cursor_shape = "beam";
      color0  = "#15161e"; color1  = "#f7768e"; color2  = "#9ece6a";
      color3  = "#e0af68"; color4  = "#7aa2f7"; color5  = "#bb9af7";
      color6  = "#7dcfff"; color7  = "#a9b1d6"; color8  = "#414868";
      color9  = "#f7768e"; color10 = "#9ece6a"; color11 = "#e0af68";
      color12 = "#7aa2f7"; color13 = "#bb9af7"; color14 = "#7dcfff";
      color15 = "#c0caf5";
      window_padding_width = 12;
      confirm_os_window_close = 0;
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
        "GTK_THEME,catppuccin-mocha-blue-standard"
      ];

      cursor.no_hardware_cursors = true;

      workspace = [
        "1, layout:master" "2, layout:master"
        "3, layout:dwindle" "4, layout:dwindle" "5, layout:dwindle"
      ];

      exec-once = [
        "swww-daemon"
        "bash -c 'sleep 1 && swww img /home/mukund/Pictures/wallpaper.png'"
        "waybar"                             # ← replaces hyprpanel
        "swaync"                             # ← notification daemon
        "nm-applet --indicator"
        "copyq --start-server"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd --all"
        "systemctl --user start plasma-polkit-agent"
        "gnome-keyring-daemon --start --components=secrets &"
        "logseq"
        "blueman-applet"
      ];

      "$mod" = "SUPER";

      bindm = [
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      windowrule = [
        "workspace special:magic, match:class Logseq"
      ];

      bind = [
        "$mod, K, exec, gnome-calendar"
        "$mod, TAB, exec, hyprctl keyword general:layout master"
        "$mod SHIFT, TAB, exec, hyprctl keyword general:layout dwindle"
        "$mod, N, exec, nm-connection-editor"
        "$mod, Return, exec, kitty"
        "$mod, Space, exec, rofi -show drun"
        "$mod, B, exec, firefox"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, C, exec, copyq toggle"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod ALT, right, resizeactive, 50 0"
        "$mod ALT, left, resizeactive, -50 0"
        "$mod ALT, up, resizeactive, 0 -50"
        "$mod ALT, down, resizeactive, 0 50"
        "$mod, S, exec, FILE=~/Pictures/ss-$(date +%Y%m%d-%H%M%S).png; grim -g \"$(slurp)\" $FILE && notify-send -i $FILE 'Screenshot' 'Saved to Pictures'"
        "$mod SHIFT, S, exec, FILE=~/Pictures/ss-$(date +%Y%m%d-%H%M%S).png; grim $FILE && notify-send -i $FILE 'Screenshot' 'Full screen saved to Pictures'"
        "$mod, 1, workspace, 1" "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3" "$mod, 4, workspace, 4" "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1" "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3" "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "ALT, F4, exec, systemctl poweroff"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, R, exec, hyprctl reload"
        "$mod, Z, togglespecialworkspace, magic"
        "$mod SHIFT, Z, movetoworkspace, special:magic"
        "$mod ALT, P, exec, hyprpicker -a"
        "$mod, G, togglegroup"
        "$mod ALT, G, changegroupactive"
        "ALT, Tab, cyclenext"
        "$mod, J, togglesplit"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
        "col.active_border" = "rgba(7aa2f7aa) rgba(bb9af7aa) 45deg";
        "col.inactive_border" = "rgba(1a1b2ecc)";
        layout = "dwindle";
        resize_on_border = true;
      };


      dwindle = { pseudotile = true; preserve_split = true; };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.93;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          xray = false;
          ignore_opacity = true;
        };
        shadow.enabled = false;
      };

     animations = {
  enabled = true;
  bezier = [
    "easeOut,  0.16, 1,    0.3, 1"
    "easeIn,   0.7,  0,    0.84, 0"
    "spring,   0.68, -0.55, 0.27, 1.55"
  ];
  animation = [
    "windows,    1, 3, spring, popin 75%"
    "windowsOut, 1, 2, easeIn, popin 75%"
    "fade,       1, 2, easeOut"
    "workspaces, 1, 4, easeOut, slidefade 20%"
    "specialWorkspace, 1, 3, easeOut, slidevert"
  ];
};
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        animate_manual_resizes = true;
      };
    };
  };

  home.stateVersion = "25.11";
}
