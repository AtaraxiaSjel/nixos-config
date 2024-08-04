{ config, lib, pkgs, inputs, self-nixpkgs, ... }: {
  nix = {
    package = pkgs.lix;
    nixPath = [ "self=/etc/self" "nixpkgs=/etc/nixpkgs" ];

    registry.nixpkgs.flake = self-nixpkgs;
    registry.self.flake = inputs.self;

    optimise.automatic = lib.mkDefault true;

    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes

      keep-outputs = true
      keep-derivations = true

      # Prevent Nix from fetching the registry every time
      flake-registry = ${inputs.flake-registry}/flake-registry.json
    '';
    settings = {
      auto-optimise-store = false;
      require-sigs = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://hyprland.cachix.org"
        "https://ataraxiadev-foss.cachix.org"
        # "https://cache.ataraxiadev.com/ataraxiadev"
        "https://numtide.cachix.org"
        "https://devenv.cachix.org"
        "https://ezkea.cachix.org"
        "https://nyx.chaotic.cx"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
        # "ataraxiadev:/V5bNjSzHVGx6r2XA2fjkgUYgqoz9VnrAHq45+2FJAs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      ];
      trusted-users = [ "root" config.mainuser "deploy" "@wheel" ];
      use-xdg-base-directories = true;
    };
  };

  environment.etc.nixpkgs.source = self-nixpkgs;
  environment.etc.self.source = inputs.self;

  environment.systemPackages = let
  repl-home = "/home/${config.mainuser}/nixos-config/repl.nix";
    repl = pkgs.writeShellScriptBin "repl" ''
      # source /etc/set-environment
      if [ -f "${repl-home}" ]; then
        echo "use home flake"
        nix repl "${repl-home}" "$@"
      else
        echo "use system flake"
        nix repl "/etc/self/repl.nix" "$@"
      fi
    '';
  in [ repl ];

  persist.state.homeDirectories = [ ".local/share/nix" ];
}
