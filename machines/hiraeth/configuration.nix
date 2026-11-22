{
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
    ./modules/alix.nix
    ./modules/borgmatic.nix
    ./modules/caddy.nix
    ./modules/freshrss.nix
    ./modules/headscale.nix
    ./modules/mirrors
    ./modules/mattermost.nix
    ./modules/nextcloud.nix
    ./modules/rssbridge.nix
    ./modules/vaultwarden.nix
  ];

  slaanesh = {
    alix = {
      localAddress = "192.168.100.10";
      localAddress6 = "fd00:100::10";
      sshPort = 2210;
    };

    caddy = {
      localAddress = "192.168.100.2";
      localAddress6 = "fd00:100::2";

      wildcardDomains = [
        "jtremesay.eu"
        "jtremesay.org"
      ];

      virtualHosts = {
        # TODO: remove placeholder and use the website container image
        "jtremesay.eu" = {
          extraConfig = ''
            respond "jtremesay.eu"
          '';
        };
      };

      redirects = {
        "mirrors.jtremesay.org" = "https://mirrors.jtremesay.eu";
      };
    };

    freshrss = {
      localAddress = "192.168.100.5";
    };

    headscale = {
      localAddress = "192.168.100.3";
    };

    mattermost = {
      localAddress = "192.168.100.6";
    };

    nextcloud = {
      localAddress = "192.168.100.7";
    };

    mirrors = {
      localAddress = "192.168.100.4";
    };

    rssbridge = {
      localAddress = "192.168.100.9";
    };

    vaultwarden = {
      localAddress = "192.168.100.8";
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
