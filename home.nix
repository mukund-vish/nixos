{ config, pkgs, lib, ... }:
{
  home.username = "mukund";
  home.homeDirectory = "/home/mukund";

  programs.git = {
    enable = true;
    userName = "mukund-vish";
    userEmail = "terryterros86@gmail.com";
    settings = {
      credential.helper = "store";
    };
  };

  programs.bash.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    waybar
    rofi
    mako
    swww
    hyprlock
    grim
    slurp
    wl-clipboard
    brightnessctl
    pavucontrol
    networkmanagerapplet
    nerd-fonts.jetbrains-mono
    papirus-icon-theme
    swayosd
    pamixer
    eww
    playerctl
    wf-recorder      # screen recorder
    cliphist         # clipboard history manager (optional, wl-paste used as fallback)
  ];

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
  };

  # ── Rofi WiFi picker script ───────────────────────────────────────────
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

  # ── Eww toggle helper scripts ─────────────────────────────────────────
  # Each waybar module gets its own toggle script that closes all other popups first.

  home.file.".local/bin/eww-toggle-volume" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      eww close brightness-popup clock-popup dashboard-overlay 2>/dev/null
      eww open --toggle volume-popup
    '';
  };

  home.file.".local/bin/eww-toggle-brightness" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      eww close volume-popup clock-popup dashboard-overlay 2>/dev/null
      eww open --toggle brightness-popup
    '';
  };

  home.file.".local/bin/eww-toggle-clock" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      eww close volume-popup brightness-popup dashboard-overlay 2>/dev/null
      eww open --toggle clock-popup
    '';
  };

  home.file.".local/bin/eww-toggle-dashboard" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      eww close volume-popup brightness-popup clock-popup 2>/dev/null
      eww open --toggle dashboard-overlay
    '';
  };

  home.file.".local/bin/eww-close-all" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      eww close volume-popup brightness-popup clock-popup dashboard-overlay 2>/dev/null
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

    mainbox {
      background-color: transparent;
      children: [inputbar, listview];
      spacing: 8px;
    }

    inputbar {
      background-color: @bg-alt;
      border-radius: 8px;
      padding: 8px 12px;
      spacing: 8px;
      children: [prompt, entry];
    }

    prompt {
      text-color: @accent;
      font: "JetBrainsMono Nerd Font 13";
    }

    entry {
      text-color: @fg;
      placeholder: "Search...";
      placeholder-color: @fg-alt;
    }

    listview {
      background-color: transparent;
      columns: 1;
      lines: 8;
      scrollbar: false;
      spacing: 4px;
    }

    element {
      background-color: transparent;
      border-radius: 8px;
      padding: 8px 12px;
      spacing: 8px;
      orientation: horizontal;
      children: [element-icon, element-text];
    }

    element selected {
      background-color: rgba(122, 162, 247, 15%);
      text-color: @accent;
    }

    element-icon {
      size: 24px;
    }

    element-text {
      text-color: inherit;
      vertical-align: 0.5;
    }
  '';

  # ── Eww config ────────────────────────────────────────────────────────
  # eww.yuck and eww.scss are managed as separate files below.
  # They are written out verbatim; paste the contents of the two
  # generated files (eww.yuck / eww.scss) into these strings.

  home.file.".config/eww/eww.yuck".source = ./eww.yuck;
  home.file.".config/eww/eww.scss".source = ./eww.scss;

  # ── Waybar ────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        # Left  : workspaces + active window title
        # Center: clock (opens clock popup)
        # Right : brightness dot · pulseaudio · network · battery · tray · dashboard dot
        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [
          "custom/brightness"
          "pulseaudio"
          "network"
          "battery"
          "tray"
          "custom/dashboard"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰲡";
            "2" = "󰲣";
            "3" = "󰲥";
            "4" = "󰲧";
            "5" = "󰲩";
            default = "○";
            active  = "●";
          };
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 40;
          separate-outputs = true;
        };

        # ── CENTER: Clock — opens clock popup ──────────────────────────
        clock = {
          format   = "󰥔  {:%H:%M   󰃭  %d %b}";
          tooltip  = false;
          on-click = "bash $HOME/.local/bin/eww-toggle-clock";
        };

        # ── RIGHT: Brightness dot (first dot) ──────────────────────────
        "custom/brightness" = {
          format   = "󰃟";
          tooltip  = false;
          on-click = "bash $HOME/.local/bin/eww-toggle-brightness";
        };

        # ── RIGHT: Volume — opens volume popup ─────────────────────────
        pulseaudio = {
          format        = "{icon}  {volume}%";
          format-muted  = "󰝟  Muted";
          format-icons  = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click      = "bash $HOME/.local/bin/eww-toggle-volume";
          on-scroll-up   = "swayosd-client --output-volume raise";
          on-scroll-down = "swayosd-client --output-volume lower";
        };

        network = {
          format-wifi        = "󰤨  {essid}";
          format-ethernet    = "󰈀  Connected";
          format-disconnected = "󰤭  No Network";
          tooltip-format     = "{ipAddr}";
          on-click           = "bash $HOME/.local/bin/rofi-wifi &";
        };

        battery = {
          states        = { warning = 30; critical = 15; };
          format        = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-icons  = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip       = false;
        };

        tray = { spacing = 8; };

        # ── RIGHT: Dashboard dot (last icon) — opens full overlay ───────
        "custom/dashboard" = {
          format   = "󰹯";
          tooltip  = false;
          on-click = "bash $HOME/.local/bin/eww-toggle-dashboard";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(26, 27, 46, 0.92);
        border-bottom: 1px solid rgba(122, 162, 247, 0.15);
        color: #c0caf5;
      }

      #workspaces button {
        padding: 0 8px;
        color: #565f89;
        background: transparent;
        border-bottom: 2px solid transparent;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: #7aa2f7;
        border-bottom: 2px solid #7aa2f7;
      }

      #workspaces button:hover {
        color: #bb9af7;
        border-bottom: 2px solid #bb9af7;
      }

      #window { color: #565f89; padding: 0 8px; }

      #clock {
        color: #7dcfff;
        padding: 0 16px;
        font-weight: bold;
        transition: all 0.2s ease;
      }

      #clock:hover { color: #7aa2f7; }

      tooltip {
        background: rgba(26, 27, 46, 0.97);
        border: 1px solid rgba(122, 162, 247, 0.3);
        border-radius: 10px;
        color: #c0caf5;
        padding: 8px;
      }

      #battery        { color: #9ece6a;  padding: 0 12px; }
      #battery.warning  { color: #e0af68; }
      #battery.critical { color: #f7768e; }

      #network    { color: #7aa2f7;  padding: 0 12px; }
      #pulseaudio { color: #bb9af7;  padding: 0 12px; }
      #pulseaudio.muted { color: #565f89; }

      #tray { padding: 0 8px; }

      /* Brightness dot */
      #custom-brightness {
        color: #e0af68;
        padding: 0 10px;
        font-size: 16px;
        transition: all 0.2s ease;
      }
      #custom-brightness:hover { color: #ff9e64; }

      /* Dashboard dot */
      #custom-dashboard {
        color: #565f89;
        padding: 0 12px;
        font-size: 15px;
        transition: all 0.2s ease;
      }
      #custom-dashboard:hover { color: #7aa2f7; }
    '';
  };

  # ── Mako ──────────────────────────────────────────────────────────────
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1a1b2e";
      text-color       = "#c0caf5";
      border-color     = "#7aa2f7";
      border-radius    = 8;
      border-size      = 1;
      padding          = "12,16";
      margin           = "8";
      font             = "JetBrainsMono Nerd Font 11";
      width            = 320;
      height           = 100;
      default-timeout  = 5000;
    };
  };

  # ── Kitty ─────────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_family         = "JetBrainsMono Nerd Font";
      font_size           = 13;
      background          = "#1a1b2e";
      foreground          = "#c0caf5";
      background_opacity  = "0.92";
      cursor              = "#c0caf5";
      cursor_shape        = "beam";
      color0  = "#15161e"; color1  = "#f7768e";
      color2  = "#9ece6a"; color3  = "#e0af68";
      color4  = "#7aa2f7"; color5  = "#bb9af7";
      color6  = "#7dcfff"; color7  = "#a9b1d6";
      color8  = "#414868"; color9  = "#f7768e";
      color10 = "#9ece6a"; color11 = "#e0af68";
      color12 = "#7aa2f7"; color13 = "#bb9af7";
      color14 = "#7dcfff"; color15 = "#c0caf5";
      window_padding_width    = 12;
      confirm_os_window_close = 0;
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      exec-once = [
        "swww-daemon"
        "bash -c 'sleep 1 && swww img /home/mukund/Pictures/wallpaper.png'"
        "waybar"
        "nm-applet --indicator"
        "mako"
        "swayosd-server"
      ];

      "$mod" = "SUPER";

      bindm = [
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioRaiseVolume,   exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume,   exec, swayosd-client --output-volume lower"
        ", XF86AudioMute,          exec, swayosd-client --output-volume mute-toggle"
        ", XF86MonBrightnessUp,    exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown,  exec, swayosd-client --brightness lower"
      ];

      bind = [
        # Close all eww popups with Escape
        ", escape, exec, bash $HOME/.local/bin/eww-close-all"

        "$mod, N,      exec, nm-connection-editor"
        "$mod, Return, exec, kitty"
        "$mod, Space,  exec, rofi -show drun"
        "$mod, B,      exec, firefox"
        "$mod, Q,      killactive,"
        "$mod, F,      fullscreen,"
        "$mod, V,      togglefloating,"
        "$mod, P,      pseudo,"

        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        "$mod ALT, right, resizeactive,  50 0"
        "$mod ALT, left,  resizeactive, -50 0"
        "$mod ALT, up,    resizeactive,  0 -50"
        "$mod ALT, down,  resizeactive,  0  50"

        "$mod, S,       exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        "$mod SHIFT, S, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        "ALT, F4, exec, systemctl poweroff"
        "$mod, L, exit,"
      ];

      general = {
        gaps_in  = 6;
        gaps_out = 12;
        border_size = 1;
        "col.active_border"   = "rgba(7aa2f7cc)";
        "col.inactive_border" = "rgba(1a1b2ecc)";
        layout = "dwindle";
        resize_on_border = true;
      };

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled           = true;
          size              = 8;
          passes            = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range   = 20;
          color   = "rgba(7aa2f722)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOut, 0.16, 1, 0.3, 1"
          "easeIn,  0.7, 0, 0.84, 0"
        ];
        animation = [
          "windows,    1, 4, easeOut, popin 80%"
          "windowsOut, 1, 3, easeIn,  popin 80%"
          "fade,       1, 4, easeOut"
          "workspaces, 1, 4, easeOut, slide"
        ];
      };

      input = {
        kb_layout    = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      misc = {
        disable_hyprland_logo    = true;
        disable_splash_rendering = true;
        animate_manual_resizes   = true;
      };
    };
  };

  home.stateVersion = "25.11";
}
