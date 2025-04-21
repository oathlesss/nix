{
  description = "Ruben nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, ... }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
	        pkgs.neovim
          pkgs.aerospace
          pkgs.tmux
          pkgs.docker
          pkgs.docker-compose
          pkgs.colima
          pkgs.firefox
          pkgs.stow
          pkgs.ripgrep
          pkgs.ast-grep
          pkgs.fzf
          pkgs.luarocks
          pkgs.fd
          pkgs.bc
          pkgs.jq
          pkgs.nowplaying-cli
          pkgs.sketchybar
          pkgs.lua
          pkgs.tldr
          pkgs.aldente
          pkgs.slack
          pkgs.uv
          pkgs.python3
          pkgs.imagemagick # Rendering images in neovim
          pkgs.mkalias # This is for making aliasses instead of symlinks to the application folder.
      ];

      services = {
          sketchybar = {
              enable = false;
            };
        };
      users.users.rubenhesselink = {
          name = "rubenhesselink";
          home = "/Users/rubenhesselink";
      };

      security.pam.services.sudo_local.touchIdAuth = true;

      homebrew = {
        enable = true;
        casks = [
          "1password"
          "iina"
          "font-noto-sans-mono"
          "font-iosevka"
          "the-unarchiver"
          "ghostty"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate= true;
        onActivation.upgrade= true;
      };

      system.defaults = {
        dock.autohide = true;
        dock.launchanim = false;
        dock.mru-spaces = false;
        dock.tilesize = 16;
        controlcenter.BatteryShowPercentage = true;
        controlcenter.Bluetooth = true;
        controlcenter.NowPlaying = false;
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.CreateDesktop = false;
        finder.FXPreferredViewStyle = "clmv";
        finder.ShowExternalHardDrivesOnDesktop = false;
        finder.ShowHardDrivesOnDesktop = false;
        finder.ShowMountedServersOnDesktop = false;
        finder.ShowRemovableMediaOnDesktop = false;
        finder.ShowPathbar = true;
        menuExtraClock.Show24Hour = true;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.InitialKeyRepeat = 8;
        NSGlobalDomain.KeyRepeat = 1;
      };


      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook-ruben" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        mac-app-util.darwinModules.default
        {
          nix-homebrew = {
            enable=true;
            enableRosetta=true;
            user="rubenhesselink";
          };
        }
      ];
    };
  };
}
