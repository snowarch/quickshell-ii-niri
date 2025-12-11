import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

BarButton {
    id: root

    rightInset: 6
    leftPadding: 12
    rightPadding: 12

    checked: GlobalStates.waffleNotificationCenterOpen
    onClicked: {
        GlobalStates.waffleNotificationCenterOpen = !GlobalStates.waffleNotificationCenterOpen;
    }

    contentItem: Item {
        implicitHeight: contentLayout.implicitHeight
        implicitWidth: contentLayout.implicitWidth
        Row {
            id: contentLayout
            anchors.centerIn: parent
            spacing: 7
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                WText {
                    anchors.right: parent.right
                    text: DateTime.time
                }
                WText {
                    anchors.right: parent.right
                    text: DateTime.date
                }
            }

            // Notification badge - Windows 11 style with pop animation
            Rectangle {
                id: notifBadge
                readonly property int count: Notifications.list.length
                readonly property bool showCount: Config.options?.waffles?.bar?.notifications?.showUnreadCount ?? true
                readonly property bool shouldShow: count > 0 && !Notifications.silent && showCount
                visible: shouldShow || scale > 0
                anchors.verticalCenter: parent.verticalCenter
                width: count > 9 ? 18 : (count > 0 ? 16 : 0)
                height: 16
                radius: 8
                color: Looks.colors.accent
                scale: shouldShow ? 1 : 0
                opacity: shouldShow ? 1 : 0

                Behavior on scale {
                    NumberAnimation {
                        duration: Looks.transition.enabled ? Looks.transition.duration.medium : 0
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Looks.transition.easing.bezierCurve.spring
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Looks.transition.enabled ? Looks.transition.duration.normal : 0
                        easing.type: Easing.OutQuad
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: Looks.transition.enabled ? Looks.transition.duration.fast : 0
                        easing.type: Easing.OutQuad
                    }
                }

                WText {
                    anchors.centerIn: parent
                    text: notifBadge.count > 9 ? "9+" : String(notifBadge.count)
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: Looks.colors.accentFg
                }
            }

            // Silent mode indicator
            FluentIcon {
                visible: Notifications.silent
                anchors.verticalCenter: parent.verticalCenter
                icon: "alert-snooze"
                implicitSize: 16
                monochrome: true
                color: Looks.colors.subfg
            }
        }
    }

    BarToolTip {
        id: tooltip
        extraVisibleCondition: root.shouldShowTooltip
        text: {
            const dateStr = Qt.locale().toString(DateTime.clock.date, "dddd, MMMM d, yyyy")
            const timeStr = Qt.locale().toString(DateTime.clock.date, "ddd hh:mm AP")
            const notifStr = Notifications.list.length > 0 
                ? "\n" + Translation.tr("%1 notification(s)").arg(Notifications.list.length)
                : ""
            return dateStr + "\n\n" + timeStr + notifStr
        }
    }
}
