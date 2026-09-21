inputs: final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
  unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
    };
    localSystem = { inherit system; };
  };

  # versionWarning = x: prev.lib.warn "warn: package ${x.name} updated upstream. Remove override!" x;
in
{
  ### Pull from unstable channel ###
  amnezia-vpn = unstable.amnezia-vpn;
  amneziawg-tools = unstable.amneziawg-tools;
  atuin = unstable.atuin;
  devenv = unstable.devenv;
  faugus-launcher = unstable.faugus-launcher;
  feishin = unstable.feishin;
  fluffychat = unstable.fluffychat;
  handbrake = unstable.handbrake;
  hyprlandUnstable = unstable.hyprland;
  hyprlandPortalUnstable = unstable.xdg-desktop-portal-hyprland;
  matrix-tuwunel = unstable.matrix-tuwunel;
  nh = unstable.nh;
  nix-index = unstable.nix-index;
  nixd = unstable.nixd;
  nixfmt = unstable.nixfmt;
  osu-lazer = unstable.osu-lazer;
  osu-lazer-bin = unstable.osu-lazer-bin;
  pi-coding-agent = unstable.pi-coding-agent;
  proton-ge-bin = unstable.proton-ge-bin;
  quickshell = unstable.quickshell;
  rustic = unstable.rustic;
  shaderbg = unstable.shaderbg;
  stremio-linux-shell = unstable.stremio-linux-shell;
  supersonic = unstable.supersonic;
  technitium-dns-server = unstable.technitium-dns-server;
  umu-launcher = unstable.umu-launcher;
  vcmi = unstable.vcmi;
  vscode = unstable.vscode;
  vscode-fhs = unstable.vscode-fhs;
  vscode-with-extensions = unstable.vscode-with-extensions;
  winboat = unstable.winboat;
  winbox4 = unstable.winbox4;
  xray = unstable.xray;
  yt-dlp = unstable.yt-dlp;
  zed-editor = unstable.zed-editor;
  # ai
  llama-cpp = unstable.llama-cpp-vulkan;
  llama-cpp-rocm = unstable.llama-cpp-rocm;
  llama-cpp-vulkan = unstable.llama-cpp-vulkan;
  mcp-nixos = unstable.mcp-nixos;
  mcp-server-fetch = unstable.mcp-server-fetch;
  mcp-server-git = unstable.mcp-server-git;
  mcp-server-time = unstable.mcp-server-time;
  opencode = unstable.opencode;
  opencode-desktop = unstable.opencode-desktop;
  rtk = unstable.rtk;
  # shell
  nushell = unstable.nushell;
  nushellPlugins = unstable.nushellPlugins;
  carapace = unstable.carapace;
  carapace-bridge = unstable.carapace-bridge;
  starship = unstable.starship;
  ### Custom names ###
  mesaUnstable = unstable.mesa;
  mesaUnstablei686 = unstable.driversi686Linux.mesa;
  nix-graph = inputs.nix-graph.packages.${system}.nix-graph;
  sing-box = inputs.ataraxiasjel-nur.packages.${system}.sing-box-extended;
  wine = prev.wineWow64Packages.stagingFull;
  zen-browser = inputs.zen-browser.packages.${system}.default;
  zfs-dedup = inputs.zfs-dedup.packages.${system}.default;
  ### Overrides ###
  arkivist = inputs.arkivist.packages.${system}.arkivist.override {
    jdks = [
      final.temurin-jre-bin-25
      final.temurin-jre-bin-21
      final.temurin-jre-bin-17
    ];
  };
  freesmlauncher = inputs.freesmlauncher.packages.${system}.freesmlauncher.override {
    jdks = [
      final.temurin-jre-bin-25
      final.temurin-jre-bin-21
      final.temurin-jre-bin-17
    ];
  };
  nix-index-unwrapped = inputs.nix-index.packages.${system}.default;
  intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };

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
