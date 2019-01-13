# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    consoleLogLevel = 3; # if this is left on the default '4', the cdc_ether module spams a message about 'kevent 12 may have been dropped'
  };

  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        // add rule to allow users to suspend the laptop
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.login1.suspend" && subject.isInGroup("users")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };

  networking = {
    hostName = "argent"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    networkmanager
    # tmux
    git
    w3m

    cryptsetup

    firefox
    weechat

    gcs
  ];
  # after reflection, I think wpa_supplicant may not be necessary.  E:  it is not

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services = {
    ntp = {
      enable = true;
    };
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      layout = "us";

      # Enable touchpad support.
      libinput.enable = true;

      # Enable the KDE Desktop Environment.
      displayManager = {
        sddm.enable = true;
      };      
      desktopManager = {
        xterm.enable = false;
        plasma5.enable = true;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };
  users = {
    mutableUsers = false;
    users.rob = {
      isNormalUser = true;
      home = "/home/rob";
      extraGroups = [ "wheel" "networkmanager" ];
      uid = 1000;
      hashedPassword = "$6$q6FCTMCmZxPuo$7Q9k30H8e.VtwahG6FUbG9QhCy.uV90DfhYosMRBiOychFqGoHCDpIJszqQfMU3.xvztuPCrGHlZ5tvfxD3ph1";
      createHome = true;
    };
  };

  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      newSession = true;
      secureSocket = true;
      extraTmuxConf = ''
        set -g renumber-windows on
        set -g status-position top
        set -g status-fg white
        set -g status-bg black
        set -g status-attr dim
        set -g status-left '#{?client_prefix,^, } '
        # there was a #(get-power-info) in here to show whether or not it's on
        # battery, charge, etc.  but that is a separate script, and I'm not sure
        # how to incorporate that into this configuration file.
        set -g status-right '%H:%M %d-%b-%y @#{host}'
        set -g window-status-current-attr bold
        bind -n M-Tab last-window
      '';
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
