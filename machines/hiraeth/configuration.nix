{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ../../modules/base.nix
    ../../modules/boot.nix
    ../../modules/deployrs.nix
    ../../modules/dns/resolved.nix
    ../../modules/network/tailscale.nix
    ../../users
    ./modules/borgmatic.nix
    ./modules/caddy.nix
    ./modules/headscale.nix
  ];

  slaanesh = {
    caddy = {
      localAddress = "192.168.100.2";
      localAddress6 = "fd00:100::2";

      wildcardDomains = [
        "jtremesay.eu"
        # TODO: migrate domain from bookmyname to ovh
        #"jtremesay.org"
      ];

      virtualHosts = {
        # TODO: remove placeholder and use the website container image
        "jtremesay.eu" = {
          extraConfig = ''
            respond "Hello from Caddy!"
          '';
        };
      };
    };

    headscale = {
      localAddress = "192.168.100.3";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
