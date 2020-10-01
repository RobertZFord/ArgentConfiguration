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
    # for some reason, when using the touchpad, the kernel cpu usage
    # spike to between 50-100%.  this module stood out in operf (from
    # oprofile) during profiling.  blacklisting it does not appear to
    # negatively affect the system.  the touchpad still works perfectly
    # fine, and now the kernel cpu usage is almost non-existent.
    blacklistedKernelModules = [ "gpio_lynxpoint" ];
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
    useDHCP = false;
    interfaces = {
        #eth0.useDHCP = true;
        wlan0.useDHCP = true;
    };
    hostName = "argent"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget       # downloads stuff
    vim        # edits text
    emacs      # also edits text
    networkmanager # manage wireless network connections
    tmux       # terminal multiplexer
    git        # source control
    w3m        # text web browser
    parted     # partition editor

    cryptsetup # LUKS for dm-crypt
    usbutils   # enumerates usb properties
    pciutils   # same with onboard components
    lsof       # show file handles
    htop       # text based resource usage display
    oprofile   # profiles system calls
    glxinfo    # displays GL info and provides simple GL test application

    sxhkd      # simple X hotkey daemon
    nitrogen   # sets background pictures
    polybar    # provides a bar for statuses
    rofi       # app launcher
    picom      # compositor
    alacritty  # terminal

    unzip      # simple .zip support
    p7zip      # provides .7z support

    firefox    # INTERNET!
    weechat    # how neckbeards talk to each other
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
        #plasma5.enable = true;
        xfce.enable = true;
      };
      windowManager = {
          bspwm.enable = true;
      };
    };
    udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05c8", ATTR{idProduct}=="036e", ATTR{authorized}="0"
    SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", ATTR{idProduct}=="1570", ATTR{authorized}="0"
    SUBSYSTEM=="net", ATTR{address}=="02:2c:80:13:92:63", NAME="eth0"
    SUBSYSTEM=="net", ATTR{address}=="9c:d2:1e:60:31:e9", NAME="wlan0"
    '';
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
      extraConfig = ''
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
  system.stateVersion = "20.03"; # Did you read the comment?  ...I did not.  -RF 2020-09-29 22:15:05 -04:00

}
