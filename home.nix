{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "kylix";
  home.homeDirectory = "/home/kylix";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs;
  [
    brightnessctl
    nitrogen
    discord
    firefox
    zoom-us
    bspwm
    sxhkd
    git
    evince
    libreoffice
    manpages
    gimp
  ];
  xsession = {
    enable = true;
    windowManager = { command = "${pkgs.bspwm}/bin/bspwm"; };
  };
  home.file.".xinitrc".text = let
    bspwmrc = pkgs.writeText "bspwmrc" ''
      #!/bin/sh
      if [[ $(xrandr -q | grep 'HDMI-A-0 connected') ]]; then
        xrandr --output eDP --off
        xrandr --output HDMI\-A\-0 --primary --mode 1920x1080 --rotate normal 
      fi
      bspc monitor -d I II III IV V VI VII VIII IX X
      bspc config border_width		0 
      bspc config window_gap		20
      bspc config split_ratio		0.52
      bspc config borderless_monocle	true
      nitrogen --restore
      xsetroot -cursor_name left_ptr &
      setxkbmap -layout "us,pt" -option "grp:alt_shift_toggle"
    '';
  in ''
      # more things omitted here
      ${pkgs.sxhkd}/bin/sxhkd &
      sleep 1 && sh ${bspwmrc} &
      exec ${pkgs.bspwm}/bin/bspwm
  '';
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Return" = "${pkgs.kitty}/bin/kitty";
      "super + f" = "${pkgs.firefox}/bin/firefox";
      "super + space" = "${pkgs.rofi}/bin/rofi -show run";
      "super + Escape" = "pkill --signal SIGUSR1 -x sxhkd";
      "super + alt + {q,r}" = "bspc {quit,wm -r}";
      "super + m" = "bspc desktop -l next";
      "super + Tab" = "bspc desktop -f last";
      "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";
      "super + c" = "bspc node -f next.local.!hidden.window";
      "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local";
      "super + {1-9,0}" = "bspc {desktop -f '^{1-9,10}'}";
      "super + alt + {Left,Down,Up,Right}" = "bspc node -z {left -20 0, bottom 0 20, top 0 -20, right 20 0}";
      "super + w" = "bspc node -c";
    };
  };
  programs.vim = {
    enable = true;
    extraConfig = ''
      colo  default
      set number
      set tabstop=2
      set shiftwidth=2
    '';
  };
  programs.kitty = {
    enable = true;
    extraConfig = ''
      font_family hack
      window_padding_width 5 20
      background #2c2b34
      enable_audio_bell no
    '';
  };
}
