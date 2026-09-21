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
    ../../modules/network/firewall.nix
    ../../modules/network/headscale.nix
    ../../modules/network/nat.nix
    ../../modules/network/tailscale.nix
    ../../modules/mirrors
    ../../modules/services/borgmatic.nix
    ../../modules/services/docker.nix
    ../../modules/services/github_ci.nix
    ../../modules/web/caddy.nix
    ../../modules/web/freshrss.nix
    ../../modules/web/mattermost.nix
    #../../modules/web/matrix.nix
    ../../modules/web/nextcloud.nix
    ../../modules/web/public_html.nix
    ../../modules/web/rssbridge.nix
    ../../modules/web/vaultwarden.nix
    ../../users
  ];

  networking = {
    hostName = "hiraeth";
    nat.externalInterface = "eno1";
  };

  slaanesh = {
    freshrss.localAddress = "192.168.100.10";
    rssbridge.localAddress = "192.168.100.11";
    vaultwarden.localAddress = "192.168.100.12";
    nextcloud.localAddress = "192.168.100.13";
    mattermost.localAddress = "192.168.100.14";
    headscale.localAddress = "192.168.100.15";
    #matrix.localAddress = "192.168.100.16";

    caddy.reverseProxies = {
      # Docker swarm services
      "jtremesay.eu" = "http://localhost:8000";
      "alix.jtremesay.eu" = "http://localhost:8000";
      "traefik.jtremesay.eu" = "http://localhost:8000";

      # Homelabs
      #"harvest.jtremesay.eu" = "http://harvest.vpn.jtremesay.eu";
      #"music.jtremesay.eu" = "http://music.vpn.jtremesay.eu";
    };
    caddy.redirs = {
      # Docker
      "jtremesay.org" = "jtremesay.eu";
      "alix.jtremesay.org" = "alix.jtremesay.eu";
      "traefik.jtremesay.org" = "traefik.jtremesay.eu";
      "users.jtremesay.org" = "users.jtremesay.eu";

      # Non docker services
      "cloud.jtremesay.org" = "cloud.jtremesay.eu";
      "headscale.jtremesay.org" = "headscale.jtremesay.eu";
      "mattermost.jtremesay.org" = "mattermost.jtremesay.eu";
      # "matrix.jtremesay.org" = "matrix.jtremesay.eu";
      "mirrors.jtremesay.org" = "mirrors.jtremesay.eu";
      "rss.jtremesay.org" = "rss.jtremesay.eu";
      "rssbridge.jtremesay.org" = "rssbridge.jtremesay.eu";
      "vault.jtremesay.org" = "vault.jtremesay.eu";
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
