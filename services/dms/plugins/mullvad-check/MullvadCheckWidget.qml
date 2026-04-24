import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Io

PluginComponent {
    id: root

    property int refreshInterval: pluginData.refreshInterval || 60
    property bool checkIpv6: pluginData.checkIpv6 !== undefined ? pluginData.checkIpv6 : true
    property bool paranoidMode: pluginData.paranoidMode || false

    property string status: "checking"
    property string exitHostname: ""
    property string serverType: ""
    property string country: ""
    property string city: ""
    property string publicIp: ""
    property string leakingIpv6: ""

    property var _ipv4Data: null
    property var _ipv6Data: null
    property bool _ipv4Done: false
    property bool _ipv6Done: false

    function _computeStatus() {
        if (!_ipv4Done) return;
        if (checkIpv6 && !_ipv6Done) return;

        if (_ipv4Data === null) {
            root.status = "offline";
            return;
        }

        if (_ipv4Data.mullvad_exit_ip !== true) {
            root.status = "exposed";
            root.publicIp = _ipv4Data.ip || "";
            root.exitHostname = "";
            root.serverType = "";
            root.country = _ipv4Data.country || "";
            root.city = _ipv4Data.city || "";
            root.leakingIpv6 = "";
            return;
        }

        root.exitHostname = _ipv4Data.mullvad_exit_ip_hostname || "";
        root.serverType = _ipv4Data.mullvad_server_type || "";
        root.country = _ipv4Data.country || "";
        root.city = _ipv4Data.city || "";
        root.publicIp = _ipv4Data.ip || "";

        if (!checkIpv6 || _ipv6Data === null) {
            root.status = "secure";
            root.leakingIpv6 = "";
            return;
        }

        if (_ipv6Data.mullvad_exit_ip !== true) {
            root.status = "leaking";
            root.leakingIpv6 = _ipv6Data.ip || "";
        } else {
            root.status = "secure";
            root.leakingIpv6 = "";
        }
    }

    function runChecks() {
        root._ipv4Done = false;
        root._ipv6Done = false;
        root._ipv4Data = null;
        root._ipv6Data = null;
        ipv4Check.running = true;
    }

    Component.onCompleted: runChecks()

    Timer {
        interval: root.refreshInterval * 1000
        running: true
        repeat: true
        onTriggered: runChecks()
    }

    Process {
        id: ipv4Check
        command: ["curl", "-4", "-s", "--max-time", "5", "https://am.i.mullvad.net/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._ipv4Data = JSON.parse(this.text);
                } catch (e) {
                    root._ipv4Data = null;
                }
                root._ipv4Done = true;

                // Only check IPv6 if v4 is actually behind Mullvad — otherwise
                // v6 result can't change the outcome.
                const shouldCheckIpv6 = root.checkIpv6
                    && root._ipv4Data !== null
                    && root._ipv4Data.mullvad_exit_ip === true;

                if (shouldCheckIpv6) {
                    ipv6Check.running = true;
                } else {
                    root._ipv6Done = true;
                    root._computeStatus();
                }
            }
        }
    }

    Process {
        id: ipv6Check
        command: ["curl", "-6", "-s", "--max-time", "5", "https://ipv6.am.i.mullvad.net/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._ipv6Data = JSON.parse(this.text);
                } catch (e) {
                    root._ipv6Data = null;
                }
                root._ipv6Done = true;
                root._computeStatus();
            }
        }
    }

    function iconName() {
        switch (root.status) {
            case "secure": return "gpp_good";
            case "leaking": return "warning";
            case "exposed": return "gpp_bad";
            case "offline": return "cloud_off";
            default: return "sync";
        }
    }

    function iconColor() {
        switch (root.status) {
            case "secure": return Theme.primary;
            case "leaking": return Theme.warning;
            case "exposed": return Theme.error;
            case "offline": return Theme.surfaceVariantText;
            default: return Theme.surfaceVariantText;
        }
    }

    function detailText() {
        switch (root.status) {
            case "secure":
                return root.city || root.exitHostname || "Secure";
            case "leaking":
                return root.exitHostname
                    ? root.exitHostname + " · IPv6 leak"
                    : "IPv6 leak";
            case "exposed":
                return root.country || root.city || "Exposed";
            case "offline":
                return "Offline";
            default:
                return "Checking…";
        }
    }

    horizontalBarPill: Component {
        MouseArea {
            implicitWidth: hRow.implicitWidth
            implicitHeight: hRow.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: root.runChecks()

            Row {
                id: hRow
                spacing: Theme.spacingS
                anchors.verticalCenter: parent.verticalCenter

                DankIcon {
                    name: root.iconName()
                    size: Theme.iconSize - 6
                    color: root.iconColor()
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        running: root.paranoidMode && root.status === "exposed"
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.35; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }

                StyledText {
                    text: root.detailText()
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            implicitWidth: vCol.implicitWidth
            implicitHeight: vCol.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: root.runChecks()

            Column {
                id: vCol
                spacing: Theme.spacingXS
                anchors.horizontalCenter: parent.horizontalCenter

                DankIcon {
                    name: root.iconName()
                    size: Theme.iconSize - 6
                    color: root.iconColor()
                    anchors.horizontalCenter: parent.horizontalCenter

                    SequentialAnimation on opacity {
                        running: root.paranoidMode && root.status === "exposed"
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.35; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }
            }
        }
    }
}
