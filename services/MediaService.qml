pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property MprisPlayer manualPlayer: null
    property real lastVolume: 0.5

    readonly property var sourceIcons: [
        { match: "spotify", icon: "󰓇" },
        { match: "firefox", icon: "󰈹" },
        { match: "librewolf", icon: "󰈹" },
        { match: "chrom", icon: "󰊯" },
        { match: "brave", icon: "󰊯" },
        { match: "edge", icon: "󰇩" },
        { match: "vlc", icon: "󰕼" },
        { match: "youtube", icon: "󰗃" },
        { match: "helium", icon: "󰊯" }
    ]

    readonly property var sourceEntry: {
        if (!player)
            return null;

        const byId = player.desktopEntry ? DesktopEntries.byId(player.desktopEntry) : null;
        return byId || DesktopEntries.heuristicLookup(player.identity) || null;
    }
    readonly property string sourceIconPath: {
        const name = sourceEntry ? sourceEntry.icon : (player ? player.identity.toLowerCase() : "");
        return name ? Quickshell.iconPath(name, true) : "";
    }

    readonly property var allowedSources: ["spotify", "helium", "chrom", "firefox", "librewolf", "brave", "zen"]

    function isAllowed(p) {
        const hasMedia = p.isPlaying || (p.playbackState !== MprisPlaybackState.Stopped && (p.trackTitle || "") !== "");
        if (!hasMedia)
            return false;

        const key = ((p.desktopEntry || "") + " " + (p.identity || "")).toLowerCase();
        return allowedSources.some(s => key.includes(s));
    }

    readonly property var players: Mpris.players.values.filter(p => isAllowed(p))
    readonly property MprisPlayer player: {
        if (manualPlayer && players.includes(manualPlayer))
            return manualPlayer;

        return players.find(p => p.isPlaying) || players[0] || null;
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player ? player.isPlaying : false
    readonly property string title: player && player.trackTitle ? player.trackTitle : "Unknown title"
    readonly property string artist: player && player.trackArtist ? player.trackArtist : "Unknown artist"
    readonly property string album: player && player.trackAlbum ? player.trackAlbum : ""
    readonly property string artUrl: player && player.trackArtUrl ? player.trackArtUrl : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0
    readonly property bool canSeek: player ? player.canSeek && player.positionSupported && player.lengthSupported : false

    readonly property string sourceKey: player ? ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase() : ""
    readonly property string sourceIcon: {
        const found = sourceIcons.find(entry => sourceKey.includes(entry.match));
        return found ? found.icon : "󰝚";
    }

    readonly property bool volumeSupported: player ? player.volumeSupported : false
    readonly property real volume: volumeSupported ? player.volume : 0
    readonly property bool shuffleSupported: player ? player.shuffleSupported : false
    readonly property bool shuffle: shuffleSupported ? player.shuffle : false
    readonly property bool loopSupported: player ? player.loopSupported : false
    readonly property string loopMode: {
        if (!loopSupported)
            return "none";

        switch (player.loopState) {
        case MprisLoopState.Track:
            return "track";
        case MprisLoopState.Playlist:
            return "playlist";
        default:
            return "none";
        }
    }

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }

    function seek(seconds) {
        if (canSeek)
            player.position = seconds;
    }

    function setVolume(value) {
        if (volumeSupported)
            player.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (!volumeSupported)
            return;

        if (volume > 0) {
            lastVolume = volume;
            setVolume(0);
        } else {
            setVolume(lastVolume > 0 ? lastVolume : 0.5);
        }
    }

    function toggleShuffle() {
        if (shuffleSupported)
            player.shuffle = !player.shuffle;
    }

    function cycleLoop() {
        if (!loopSupported)
            return;

        switch (player.loopState) {
        case MprisLoopState.None:
            player.loopState = MprisLoopState.Playlist;
            break;
        case MprisLoopState.Playlist:
            player.loopState = MprisLoopState.Track;
            break;
        default:
            player.loopState = MprisLoopState.None;
        }
    }

    function cycle() {
        if (players.length < 2)
            return;

        const index = players.indexOf(player);
        manualPlayer = players[(index + 1) % players.length];
    }
}