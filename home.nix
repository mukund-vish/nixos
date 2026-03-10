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
    kitty
    waybar
    wofi
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
    swayosd
    pamixer
    eww
    playerctl
  ];

  # ── Wofi WiFi picker script ───────────────────────────────────────────
  home.file.".local/bin/wofi-wifi" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Scan for networks
      nmcli dev wifi rescan 2>/dev/null
      sleep 1

      # Get list of available networks
      networks=$(nmcli -t -f ssid,signal,security dev wifi list 2>/dev/null \
        | sort -t: -k2 -rn \
        | awk -F: '!seen[$1]++ && $1!="" {
            icon = ($3 ~ /WPA|WEP/) ? "󰤪 " : "󰤨 "
            printf "%s%s (%s%%)\n", icon, $1, $2
          }')

      chosen=$(echo "$networks" | wofi --dmenu --prompt "WiFi" --insensitive)
      [ -z "$chosen" ] && exit

      # Extract SSID (strip leading icon+space and trailing signal)
      ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ ([0-9]*%)$//')

      # Check if already saved
      saved=$(nmcli -t -f name con show | grep -Fx "$ssid")

      if [ -n "$saved" ]; then
        nmcli con up "$ssid"
      else
        # Ask for password via wofi
        password=$(wofi --dmenu --prompt "Password for $ssid" --password)
        if [ -z "$password" ]; then
          nmcli dev wifi connect "$ssid"
        else
          nmcli dev wifi connect "$ssid" password "$password"
        fi
      fi
    '';
  };

  # ── Eww bottom dashboard ──────────────────────────────────────────────
  home.file.".config/eww/eww.yuck".text = ''
    (defvar dashboard-visible false)

    (defpoll clock-time :interval "1s"
      "date \"+%H:%M:%S\"")

    (defpoll clock-date :interval "60s"
      "date \"+%A, %d %B %Y\"")

    (defpoll volume :interval "1s"
      "pamixer --get-volume 2>/dev/null || echo 0")

    (defpoll muted :interval "1s"
      "pamixer --get-mute 2>/dev/null || echo false")

    (defpoll brightness :interval "2s"
      "brightnessctl get 2>/dev/null | awk -v max=$(brightnessctl max 2>/dev/null) \"{printf \\\"%d\\\", ($1/max)*100}\"")

    (defpoll network-ssid :interval "5s"
      "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || echo \"No Network\"")

    (defpoll network-strength :interval "5s"
      "awk 'NR==3{gsub(/ /,\"\"); split($0,a,\":\"); printf \"%d\", (a[2]/70)*100}' /proc/net/wireless 2>/dev/null || echo 0")

    (defpoll battery-level :interval "30s"
      "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0")

    (defpoll battery-status :interval "30s"
      "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo \"Unknown\"")

    (defpoll media-title :interval "2s"
      "playerctl metadata title 2>/dev/null || echo \"Nothing playing\"")

    (defpoll media-artist :interval "2s"
      "playerctl metadata artist 2>/dev/null || echo \"\"")

    (defpoll media-status :interval "2s"
      "playerctl status 2>/dev/null || echo \"Stopped\"")

    (defwidget clock-widget []
      (box :class "dash-card"
           :orientation "v"
           :space-evenly false
           :spacing 4
        (label :class "clock-time" :text clock-time)
        (label :class "clock-date" :text clock-date)))

    (defwidget calendar-widget []
      (box :class "dash-card"
           :orientation "v"
           :space-evenly false
        (calendar :class "calendar"
                  :show-heading true
                  :show-day-names true
                  :show-surrounding-days true)))

    (defwidget volume-widget []
      (box :class "dash-card"
           :orientation "v"
           :space-evenly false
           :spacing 8
        (box :orientation "h" :space-evenly false :spacing 8
          (label :class "card-icon" :text {muted == "true" ? "󰝟" : "󰕾"})
          (label :class "card-label" :text "Volume")
          (label :class "card-value" :halign "end" :hexpand true
                 :text {muted == "true" ? "Muted" : "''${volume}%"}))
        (scale :class "slider vol-slider"
               :min 0 :max 100 :value volume
               :onchange "pamixer --set-volume {}")))

    (defwidget brightness-widget []
      (box :class "dash-card"
           :orientation "v"
           :space-evenly false
           :spacing 8
        (box :orientation "h" :space-evenly false :spacing 8
          (label :class "card-icon" :text "󰃞")
          (label :class "card-label" :text "Brightness")
          (label :class "card-value" :halign "end" :hexpand true
                 :text "''${brightness}%"))
        (scale :class "slider bright-slider"
               :min 1 :max 100 :value brightness
               :onchange "brightnessctl set {}%")))

    (defwidget network-widget []
      (box :class "dash-card"
           :orientation "h"
           :space-evenly false
           :spacing 12
           :onclick "bash $HOME/.local/bin/wofi-wifi &"
        (label :class "card-icon" :text "󰤨")
        (box :orientation "v" :space-evenly false :spacing 2
          (label :class "card-label" :halign "start" :text network-ssid)
          (label :class "card-subtext" :halign "start"
                 :text "''${network-strength}% signal"))))

    (defwidget battery-widget []
      (box :class "dash-card"
           :orientation "h"
           :space-evenly false
           :spacing 12
        (label :class "card-icon"
               :text {battery-status == "Charging" ? "󰂄" :
                      battery-level > 80 ? "󰁹" :
                      battery-level > 60 ? "󰂂" :
                      battery-level > 40 ? "󰂀" :
                      battery-level > 20 ? "󰁾" : "󰁺"})
        (box :orientation "v" :space-evenly false :spacing 2
          (label :class "card-label" :halign "start" :text "''${battery-level}%")
          (label :class "card-subtext" :halign "start" :text battery-status))))

    (defwidget media-widget []
      (box :class "dash-card"
           :orientation "h"
           :space-evenly false
           :spacing 16
        (box :orientation "v" :space-evenly false :hexpand true :spacing 2
          (label :class "card-icon" :halign "start" :text "󰎇")
          (label :class "media-title" :halign "start" :truncate true :text media-title)
          (label :class "media-artist" :halign "start" :truncate true :text media-artist))
        (box :orientation "h" :valign "center" :spacing 16
          (button :class "media-btn" :onclick "playerctl previous" "󰒮")
          (button :class "media-btn media-play-btn" :onclick "playerctl play-pause"
            {media-status == "Playing" ? "󰏤" : "󰐊"})
          (button :class "media-btn" :onclick "playerctl next" "󰒭"))))

    (defwidget dashboard []
      (box :class "dashboard"
           :orientation "h"
           :space-evenly false
           :spacing 12
        (box :orientation "v" :space-evenly false :spacing 12
          (clock-widget)
          (calendar-widget))
        (box :orientation "v" :space-evenly false :spacing 12 :hexpand true
          (volume-widget)
          (brightness-widget)
          (box :orientation "h" :space-evenly true :spacing 12
            (network-widget)
            (battery-widget))
          (media-widget))))

    (defwindow dashboard-panel
      :monitor 0
      :geometry (geometry
        :x "0px"
        :y "0px"
        :width "100%"
        :height "360px"
        :anchor "bottom center")
      :stacking "overlay"
      :exclusive false
      :visible dashboard-visible
      (dashboard))
  '';

  home.file.".config/eww/eww.scss".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
    }

    .dashboard {
      background: rgba(13, 14, 26, 0.97);
      border-top: 1px solid rgba(122, 162, 247, 0.25);
      padding: 16px 20px;
    }

    .dash-card {
      background: rgba(26, 27, 46, 0.8);
      border-radius: 12px;
      padding: 12px 14px;
      border: 1px solid rgba(122, 162, 247, 0.08);
      min-width: 0;
    }

    .clock-time {
      font-size: 42px;
      font-weight: bold;
      color: #7aa2f7;
      letter-spacing: 2px;
    }

    .clock-date {
      font-size: 12px;
      color: #565f89;
    }

    calendar {
      background: transparent;
      color: #c0caf5;
      font-size: 12px;
    }

    calendar:indeterminate { color: #3b3f5e; }

    calendar:selected {
      background: #7aa2f7;
      border-radius: 6px;
      color: #1a1b2e;
      font-weight: bold;
    }

    calendar.highlight {
      color: #f7768e;
      font-weight: bold;
    }

    calendar header button {
      color: #7dcfff;
      background: transparent;
      border: none;
      padding: 2px 6px;
    }

    calendar header button:hover {
      background: rgba(122, 162, 247, 0.15);
      border-radius: 6px;
    }

    calendar header label {
      color: #7dcfff;
      font-weight: bold;
    }

    .card-icon {
      font-size: 18px;
      color: #7aa2f7;
      min-width: 22px;
    }

    .card-label {
      color: #c0caf5;
      font-weight: bold;
    }

    .card-value { color: #565f89; }

    .card-subtext {
      font-size: 11px;
      color: #414868;
    }

    scale { margin-top: 4px; }

    scale trough {
      background: rgba(86, 95, 137, 0.3);
      border-radius: 99px;
      min-height: 6px;
    }

    scale highlight { border-radius: 99px; }

    .vol-slider highlight {
      background: linear-gradient(to right, #7aa2f7, #bb9af7);
    }

    .bright-slider highlight {
      background: linear-gradient(to right, #e0af68, #ff9e64);
    }

    scale slider {
      background: #c0caf5;
      border-radius: 99px;
      min-width: 14px;
      min-height: 14px;
      border: none;
      box-shadow: none;
    }

    scale slider:hover { background: #ffffff; }

    .media-title {
      color: #c0caf5;
      font-weight: bold;
    }

    .media-artist {
      font-size: 11px;
      color: #565f89;
    }

    .media-btn {
      font-size: 20px;
      color: #565f89;
      background: transparent;
      border: none;
      padding: 6px 10px;
      border-radius: 8px;
    }

    .media-btn:hover {
      color: #c0caf5;
      background: rgba(122, 162, 247, 0.1);
    }

    .media-play-btn {
      font-size: 28px;
      color: #7aa2f7;
    }

    .media-play-btn:hover {
      color: #ffffff;
      background: rgba(122, 162, 247, 0.2);
    }
  '';

  # ── Waybar ────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" "custom/dashboard" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰲡";
            "2" = "󰲣";
            "3" = "󰲥";
            "4" = "󰲧";
            "5" = "󰲩";
            default = "○";
            active = "●";
          };
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 40;
          separate-outputs = true;
        };

        clock = {
          format = "󰥔  {:%H:%M   󰃭  %d %b}";
          tooltip = false;
          on-click = "eww open --toggle dashboard-panel";
        };

        battery = {
          states = { warning = 30; critical = 15; };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          on-click = "eww open --toggle dashboard-panel";
        };

        network = {
          format-wifi = "󰤨  {essid}";
          format-ethernet = "󰈀  Connected";
          format-disconnected = "󰤭  No Network";
          tooltip-format = "{ipAddr}";
          on-click = "eww open --toggle dashboard-panel";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";
          format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click = "eww open --toggle dashboard-panel";
          on-scroll-up = "swayosd-client --output-volume raise";
          on-scroll-down = "swayosd-client --output-volume lower";
        };

        "custom/dashboard" = {
          format = "󰹯";
          tooltip = false;
          on-click = "eww open --toggle dashboard-panel";
        };

        tray = { spacing = 8; };
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

      #battery { color: #9ece6a; padding: 0 12px; }
      #battery.warning { color: #e0af68; }
      #battery.critical { color: #f7768e; }
      #network { color: #7aa2f7; padding: 0 12px; }
      #pulseaudio { color: #bb9af7; padding: 0 12px; }
      #pulseaudio.muted { color: #565f89; }
      #tray { padding: 0 8px; }

      #custom-dashboard {
        color: #565f89;
        padding: 0 12px;
        font-size: 15px;
        transition: all 0.2s ease;
      }

      #custom-dashboard:hover { color: #7aa2f7; }
    '';
  };

  # ── Wofi ──────────────────────────────────────────────────────────────
  home.file.".config/wofi/style.css".text = ''
    window {
      background: rgba(26, 27, 46, 0.97);
      border: 1px solid rgba(122, 162, 247, 0.3);
      border-radius: 12px;
      font-family: "JetBrainsMono Nerd Font";
    }

    #input {
      background: rgba(22, 33, 62, 0.8);
      border: 1px solid rgba(122, 162, 247, 0.2);
      border-radius: 8px;
      color: #c0caf5;
      padding: 8px 12px;
      margin: 8px;
      font-size: 14px;
    }

    #input:focus {
      border-color: rgba(122, 162, 247, 0.6);
      outline: none;
    }

    #entry {
      padding: 6px 12px;
      border-radius: 6px;
      color: #a9b1d6;
      margin: 2px 6px;
    }

    #entry:selected {
      background: rgba(122, 162, 247, 0.15);
      color: #7aa2f7;
    }

    #text { font-size: 13px; }
  '';

  # ── Mako ──────────────────────────────────────────────────────────────
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1a1b2e";
      text-color = "#c0caf5";
      border-color = "#7aa2f7";
      border-radius = 8;
      border-size = 1;
      padding = "12,16";
      margin = "8";
      font = "JetBrainsMono Nerd Font 11";
      width = 320;
      height = 100;
      default-timeout = 5000;
    };
  };

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
      color0  = "#15161e";
      color1  = "#f7768e";
      color2  = "#9ece6a";
      color3  = "#e0af68";
      color4  = "#7aa2f7";
      color5  = "#bb9af7";
      color6  = "#7dcfff";
      color7  = "#a9b1d6";
      color8  = "#414868";
      color9  = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
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
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      bind = [
      ", escape, exec, eww close dashboard-panel"
      "$mod, N, exec, nm-connection-editor"
        "$mod, Return, exec, kitty"
        "$mod, Space, exec, wofi --show drun"
        "$mod, B, exec, firefox"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
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
        "$mod, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
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
        gaps_in = 6;
        gaps_out = 12;
        border_size = 1;
        "col.active_border" = "rgba(7aa2f7cc)";
        "col.inactive_border" = "rgba(1a1b2ecc)";
        layout = "dwindle";
        resize_on_border = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 20;
          color = "rgba(7aa2f722)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOut, 0.16, 1, 0.3, 1"
          "easeIn, 0.7, 0, 0.84, 0"
        ];
        animation = [
          "windows, 1, 4, easeOut, popin 80%"
          "windowsOut, 1, 3, easeIn, popin 80%"
          "fade, 1, 4, easeOut"
          "workspaces, 1, 4, easeOut, slide"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
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
