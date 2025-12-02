import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

AppButton {
    id: root

    iconName: (down && !checked) ? "task-view-pressed" : "task-view"
    pressedScale: checked ? 5/6 : 1
    separateLightDark: true

    checked: CompositorService.isNiri ? NiriService.inOverview : GlobalStates.overviewOpen
    onClicked: {
        if (CompositorService.isNiri) {
            NiriService.toggleOverview()
        } else {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
    }

    BarToolTip {
        extraVisibleCondition: root.shouldShowTooltip
        text: Translation.tr("Task View")
    }
}
