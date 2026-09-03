{
  config,
  lib,
  pkgs,
  ...
}:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGm5JRotZU5S8CIeY6UBRc6sVVw22lHHEHRHdwUXBJa jtremesay@nemo";
in

{
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "nixoes";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #font = "Lat2-Terminus16";
    keyMap = "fr-bepo-latin9";
    earlySetup = true;
  };

  users.groups = {
    deployrs = {
    };
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        sshPubKey
      ];
    };

    deployrs = {
      isNormalUser = true;
      group = config.users.groups.deployrs.name;
      openssh.authorizedKeys.keys = [
        sshPubKey
      ];
    };
  };

  security.sudo.extraRules = [
    {
      groups = [ config.users.groups.deployrs.name ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.openssh.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
