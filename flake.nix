{
  inputs = {
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      deploy-rs,
      home-manager,
      nixpkgs,
      sops-nix,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      commonModules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          deploy-rs.packages.${system}.deploy-rs
          fish
          nixfmt
          sops
          ssh-to-age
        ];
        shellHook = ''
          exec ${pkgs.fish}/bin/fish
        '';
      };

      nixosConfigurations = {
        # harvest = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = commonModules ++ [ ./machines/harvest/configuration.nix ];
        # };

        hiraeth = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./machines/hiraeth/configuration.nix ];
        };

        music = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./machines/music/configuration.nix ];
        };
      };

      deploy.nodes = {
        # harvest = {
        #   hostname = "harvest";
        #   hostname = "192.168.1.165";
        #   sshUser = "deployrs";
        #   sshUser = "root";
        #   profiles.system = {
        #     user = "root";
        #     path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.harvest;
        #   };
        # };

        hiraeth = {
          hostname = "hiraeth";
          #hostname = "hiraeth.jtremesay.org";
          sshUser = "deployrs";
          groups = [
            "hiraeth"
            "prod"
          ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hiraeth;
          };

        };

        music = {
          hostname = "music";
          #hostname = "192.168.1.79";
          sshUser = "deployrs";
          groups = [
            "music"
            "dev"
          ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.music;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
