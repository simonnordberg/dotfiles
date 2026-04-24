import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "mullvadCheck"

    StyledText {
        width: parent.width
        text: "Mullvad Check"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Verifies against am.i.mullvad.net — ground truth from outside the tunnel, not just what the daemon reports. Click the widget to force a re-check."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    SliderSetting {
        settingKey: "refreshInterval"
        label: "Refresh interval"
        description: "How often to poll am.i.mullvad.net. IPv6 check only fires when IPv4 is behind Mullvad."
        defaultValue: 60
        minimum: 10
        maximum: 600
        unit: "sec"
        leftIcon: "schedule"
    }

    ToggleSetting {
        settingKey: "checkIpv6"
        label: "Check IPv6 leak"
        description: "Also query ipv6.am.i.mullvad.net to detect IPv6 bypassing the tunnel. Turn off if your network has no IPv6."
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "paranoidMode"
        label: "Paranoid mode"
        description: "Pulse the icon while exposed so it's harder to ignore."
        defaultValue: false
    }
}
