import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

AppButton {
    id: root

    readonly property bool expandedForm: Config.options.waffles.bar.leftAlignApps
    leftInset: expandedForm ? 0 : 12
    implicitWidth: expandedForm ? 148 : (height - topInset - bottomInset + leftInset + rightInset)
    iconName: "widgets"

    checked: GlobalStates.waffleWidgetsOpen
    onClicked: GlobalStates.waffleWidgetsOpen = !GlobalStates.waffleWidgetsOpen

    BarToolTip {
        extraVisibleCondition: root.shouldShowTooltip
        text: Translation.tr("Widgets")
    }
}
