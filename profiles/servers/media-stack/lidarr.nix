{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.lidarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
      scriptInterval = "15m";
      enableAudioScript = "true";
      enableVideoScript = "false";
      # enableVideoScript = "true";
      # videoDownloadTag = "video";
      configureLidarrWithOptimalSettings = "true";
      searchSort = "date";
      audioFormat = "native";
      audioBitrate = "lossless";
      requireQuality = "true";
      enableReplaygainTags = "true";
      audioLyricType = "both";
      # dlClientSource = "both";
      dlClientSource = "tidal";
      # arlToken = "Token_Goes_Here";
      tidalCountryCode = "AR";
      addDeezerTopArtists = "false";
      addDeezerTopAlbumArtists = "false";
      addDeezerTopTrackArtists = "false";
      topLimit = "10";
      addRelatedArtists = "false";
      numberOfRelatedArtistsToAddPerArtist = "5";
      lidarrSearchForMissing = "true";
      addFeaturedVideoArtists = "false";
      youtubeSubtitleLanguage = "en,ru";
      # webHook = "";
      enableQueueCleaner = "true";
      matchDistance = "5";
      enableBeetsTagging = "true";
      beetsMatchPercentage = "90";
      retryNotFound = "90";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "docker.io/randomninjaatk/lidarr-extended:latest";
    volumes = [
      "${nas-path}/configs/lidarr:/config"
      "${nas-path}/torrents/music:/downloads"
      "${nas-path}/torrents/lidarr-extended-downloads:/downloads-lidarr-extended"
      "${nas-path}/media/music:/music"
      "${nas-path}/media/music-videos:/music-videos"
    ];
  };
}
