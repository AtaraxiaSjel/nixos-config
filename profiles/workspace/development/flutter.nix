{ config, lib, pkgs, inputs, ... }: {
  home-manager.users.alukard = rec {
    imports = [ inputs.android-nixpkgs.hmModule ];

    android-sdk = {
      enable = true;
      path = "${config.home-manager.users.alukard.home.homeDirectory}/.android/sdk";
      packages = sdk: with sdk; [
        build-tools-31-0-0
        build-tools-29-0-2
        cmdline-tools-latest
        patcher-v4
        platform-tools
        platforms-android-30


        emulator
        system-images-android-30-google-apis-x86-64
      ];
    };

    home.sessionVariables = {
      ANDROID_HOME = android-sdk.path;
      ANDROID_SDK_ROOT = android-sdk.path;
      JAVA_HOME = pkgs.jdk11.home;
    };

    home.packages = let
      android-emulator = pkgs.android-emulator.override {
        name = "flutter-emulator";
        avdHomeDir = config.home-manager.users.alukard.home.homeDirectory;
        sdk = android-sdk.path;
        platformVersion = "30";
        systemImageType = "google_apis";
        abiVersion = "x86_64";
        deviceType = "pixel";
        # enableGPU = true;
      };
    in [
      pkgs.flutter
      android-emulator
      # jdk11
    ];
  };

  environment.sessionVariables = {
    ANDROID_HOME = config.home-manager.users.alukard.android-sdk.path;
    ANDROID_SDK_ROOT = config.home-manager.users.alukard.android-sdk.path;
    JAVA_HOME = pkgs.jdk11.home;
  };
}