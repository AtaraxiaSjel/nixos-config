inputs: final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
  unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
    };
    localSystem = { inherit system; };
  };
in
{
  ### Pull from unstable channel ###
  amnezia-vpn = unstable.amnezia-vpn;
  devenv = unstable.devenv;
  feishin = unstable.feishin;
  fluffychat = unstable.fluffychat;
  hyprlandUnstable = unstable.hyprland;
  hyprlandPortalUnstable = unstable.xdg-desktop-portal-hyprland;
  nh = unstable.nh;
  nix-index = unstable.nix-index;
  nixd = unstable.nixd;
  nixfmt = unstable.nixfmt;
  osu-lazer = unstable.osu-lazer;
  osu-lazer-bin = unstable.osu-lazer-bin;
  proton-ge-bin = unstable.proton-ge-bin;
  quickshell = unstable.quickshell;
  rustic = unstable.rustic;
  shaderbg = unstable.shaderbg;
  supersonic = unstable.supersonic;
  supersonic-wayland = unstable.supersonic-wayland;
  technitium-dns-server = unstable.technitium-dns-server;
  xray = unstable.xray;
  yt-dlp = unstable.yt-dlp;
  zed-editor = unstable.zed-editor;
  # shell
  nushell = unstable.nushell;
  nushellPlugins = unstable.nushellPlugins;
  carapace = unstable.carapace;
  carapace-bridge = unstable.carapace-bridge;
  starship = unstable.starship;
  ### Custom names ###
  mesaUnstable = unstable.mesa;
  mesaUnstablei686 = unstable.driversi686Linux.mesa;
  sing-box = final.sing-box-extended;
  wine = prev.wineWow64Packages.stagingFull;
  zen-browser = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.default;
  ### Overrides ###
  freesmlauncher = inputs.freesmlauncher.packages.${system}.freesmlauncher.override {
    jdks = [
      final.temurin-jre-bin-21
      final.temurin-jre-bin-17
    ];
  };
  nix-index-unwrapped = inputs.nix-index.packages.${system}.default;
  intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };
  llama-cpp = unstable.llama-cpp-vulkan;
  # Move modprobed config to subdir. Easier to use with impermanence
  modprobed-db = prev.modprobed-db.overrideAttrs (oa: {
    nativeBuildInputs = [ prev.makeWrapper ] ++ oa.nativeBuildInputs or [ ];
    postPatch = (oa.postPatch or "") + ''
      substituteInPlace ./common/modprobed-db.in \
        --replace-fail "/modprobed-db.conf" "/modprobed-db/modprobed-db.conf"
      substituteInPlace ./common/modprobed-db.skel \
        --replace-fail "/.config" "/.config/modprobed-db"
    '';
    postInstall = (oa.postInstall or "") + ''
      wrapProgram $out/bin/modprobed-db \
      --set PATH ${
        with final;
        lib.makeBinPath [
          gawk
          getent
          coreutils
          gnugrep
          gnused
          kmod
        ]
      }
    '';
  });
  pass-secret-service = prev.pass-secret-service.overrideAttrs (_: {
    installCheckPhase = null;
    postInstall = ''
      mkdir -p $out/share/{dbus-1/services,xdg-desktop-portal/portals}
      cat > $out/share/dbus-1/services/org.freedesktop.secrets.service << EOF
      [D-BUS Service]
      Name=org.freedesktop.secrets
      Exec=/run/current-system/sw/bin/systemctl --user start pass-secret-service
      EOF
      cp $out/share/dbus-1/services/{org.freedesktop.secrets.service,org.freedesktop.impl.portal.Secret.service}
      cat > $out/share/xdg-desktop-portal/portals/pass-secret-service.portal << EOF
      [portal]
      DBusName=org.freedesktop.secrets
      Interfaces=org.freedesktop.impl.portal.Secrets
      UseIn=gnome
      EOF
    '';
  });
}
