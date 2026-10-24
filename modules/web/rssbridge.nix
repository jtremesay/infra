{
  config,
  lib,
  nixpkgs-master,
  ...
}:
let
  cfg = config.slaanesh.rssbridge;
in
{
  options.slaanesh.rssbridge = {
    localAddress = lib.mkOption {
      type = lib.types.str;
      description = "Local IP address for the rssbridge container";
    };

    host = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the rssbridge service";
      default = "rssbridge.jtremesay.eu";
    };
  };

  config = {
    containers.rssbridge = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = cfg.localAddress;

      specialArgs = { inherit nixpkgs-master; };

      config =
        { pkgs, lib, ... }:
        {
          imports = [ ../dns/resolved.nix ];

          nixpkgs.overlays = [
            (final: prev: {
              inherit (nixpkgs-master.legacyPackages.${prev.system})
                php
                php83
                php84
                php85
                ;
            })
          ];

          services.rss-bridge = {
            enable = true;
            config = {
              system.enabled_bridges = [ "*" ];
              error = {
                output = "http";
                report_limit = 5;
              };
              FileCache = {
                enable_purge = true;
              };
            };
          };

          networking = {
            useHostResolvConf = lib.mkForce false;
            firewall.allowedTCPPorts = [
              80
            ];
          };

          system.stateVersion = "25.05";
        };
    };

    #slaanesh.caddy.reverseProxies."${cfg.host}" = "${config.containers.rssbridge.localAddress}:80";
  };
}
