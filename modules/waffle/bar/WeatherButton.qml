import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.waffle.looks

BarButton {
    id: root

    leftInset: 8
    rightInset: 8
    implicitWidth: contentRow.implicitWidth + leftInset + rightInset + 8

    onClicked: {
        Weather.getData()
        GlobalStates.waffleWidgetsOpen = !GlobalStates.waffleWidgetsOpen
    }

    contentItem: RowLayout {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent

        MaterialSymbol {
            text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
            iconSize: 20
            color: Looks.colors.fg
            Layout.alignment: Qt.AlignVCenter
        }

        Column {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            WText {
                text: Weather.data?.temp ?? "--°"
                font.pixelSize: Looks.font.pixelSize.normal
                font.weight: Font.Medium
                color: Looks.colors.fg
            }

            WText {
                text: root.weatherDescription
                font.pixelSize: Looks.font.pixelSize.tiny
                color: Looks.colors.subfg
            }
        }
    }

    // Weather description based on code
    readonly property string weatherDescription: {
        const code = Weather.data?.wCode ?? "113"
        const descriptions = {
            "113": Translation.tr("Sunny"),
            "116": Translation.tr("Partly cloudy"),
            "119": Translation.tr("Cloudy"),
            "122": Translation.tr("Overcast"),
            "143": Translation.tr("Mist"),
            "176": Translation.tr("Light rain"),
            "179": Translation.tr("Light sleet"),
            "182": Translation.tr("Light sleet"),
            "185": Translation.tr("Light sleet"),
            "200": Translation.tr("Thunderstorm"),
            "227": Translation.tr("Light snow"),
            "230": Translation.tr("Heavy snow"),
            "248": Translation.tr("Fog"),
            "260": Translation.tr("Fog"),
            "263": Translation.tr("Light drizzle"),
            "266": Translation.tr("Light drizzle"),
            "281": Translation.tr("Freezing drizzle"),
            "284": Translation.tr("Freezing drizzle"),
            "293": Translation.tr("Light rain"),
            "296": Translation.tr("Light rain"),
            "299": Translation.tr("Moderate rain"),
            "302": Translation.tr("Heavy rain"),
            "305": Translation.tr("Heavy rain"),
            "308": Translation.tr("Heavy rain"),
            "311": Translation.tr("Freezing rain"),
            "314": Translation.tr("Freezing rain"),
            "317": Translation.tr("Sleet"),
            "320": Translation.tr("Light snow"),
            "323": Translation.tr("Light snow"),
            "326": Translation.tr("Light snow"),
            "329": Translation.tr("Moderate snow"),
            "332": Translation.tr("Moderate snow"),
            "335": Translation.tr("Heavy snow"),
            "338": Translation.tr("Heavy snow"),
            "350": Translation.tr("Ice pellets"),
            "353": Translation.tr("Light showers"),
            "356": Translation.tr("Moderate showers"),
            "359": Translation.tr("Heavy showers"),
            "362": Translation.tr("Sleet showers"),
            "365": Translation.tr("Sleet showers"),
            "368": Translation.tr("Snow showers"),
            "371": Translation.tr("Snow showers"),
            "374": Translation.tr("Ice pellets"),
            "377": Translation.tr("Ice pellets"),
            "386": Translation.tr("Thunderstorm"),
            "389": Translation.tr("Thunderstorm"),
            "392": Translation.tr("Thunderstorm"),
            "395": Translation.tr("Snow storm")
        }
        return descriptions[code] ?? Translation.tr("Unknown")
    }

    BarToolTip {
        extraVisibleCondition: root.shouldShowTooltip
        text: Weather.data?.city ?? Translation.tr("Unknown location")
    }
}
