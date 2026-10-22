//@ pragma AppId serpantinum-settings
//@ pragma Env SERPANTINUM_STANDALONE=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "."
import "guide"

ShellRoot {
    id: app

    readonly property real uiScale: {
        let general = Config.getSetting("general", {});
        let v = general ? Number(general.uiScale) : NaN;
        return (isNaN(v) || v <= 0) ? 1.0 : v;
    }

    property bool shown: Quickshell.env("SERPANTINUM_SETTINGS_HIDDEN") !== "1"

    readonly property int toplevelCount: ToplevelManager.toplevels.values.length

    Connections {
        target: Quickshell
        function onReloadCompleted() { Quickshell.inhibitReloadPopup() }
        function onReloadFailed(errorString) { Quickshell.inhibitReloadPopup() }
    }

    IpcHandler {
        target: "settings"

        function goto(tab: string, subtab: string): void {
            popup.gotoTab(tab, subtab);
        }

        function close(): void {
            popup.closePopup();
        }

        function focus(): void {
            let list = ToplevelManager.toplevels.values;
            for (let i = 0; i < list.length; i++) {
                if (list[i].appId === "serpantinum-settings") {
                    list[i].activate();
                    return;
                }
            }
        }

        function show(tab: string, subtab: string): void {
            app.shown = true;
            if (tab !== "") popup.gotoTab(tab, subtab);
        }

        function isShown(): string {
            return app.shown ? "yes" : "no";
        }

        function ping(): string {
            return "ok";
        }
    }

    PanelWindow {
        id: window

        color: "transparent"
        implicitWidth: Math.round(1200 * app.uiScale)
        implicitHeight: Math.round(750 * app.uiScale)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "serpantinum-settings"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        visible: app.shown

        GuidePopup {
            id: popup
            anchors.fill: parent
            standalone: true
            visible: window.visible
            onExitRequested: app.shown = false
        }
    }
}
