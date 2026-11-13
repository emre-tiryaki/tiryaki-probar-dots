import "../../common"
import QtQuick

Item {
    /*
     * --------------------------------------------------------
     * Calendar data
     * --------------------------------------------------------
     */
    /*
     * --------------------------------------------------------
     * Navigation
     * --------------------------------------------------------
     */
    /*
     * --------------------------------------------------------
     * Root background
     * --------------------------------------------------------
     */
    /*
     * --------------------------------------------------------
     * CALENDAR
     * --------------------------------------------------------
     */
    /*
    * --------------------------------------------------------
    * MONTH SELECTION
    * --------------------------------------------------------
    */
    /*
     * --------------------------------------------------------
     * YEAR SELECTION
     * --------------------------------------------------------
     *
     * 3 columns × 4 rows.
     *
     * One ListView item contains exactly 12 years.
     * Scrolling snaps one complete 12-year page at a time.
     */
    /*
     * --------------------------------------------------------
     * YEAR GROUP MANAGEMENT
     * --------------------------------------------------------
     *
     * The selected year is always inside the center
     * group (index 20).
     */

    id: root

    /*
     * calendar
     * months
     * years
     */
    property string selectorMode: "calendar"
    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth()
    /*
     * Calendar viewport.
     *
     * One month consists of:
     * 6 calendar rows × 38px.
     */
    readonly property int monthHeight: 228
    readonly property int dayHeight: 38
    property int firstMonthOffset: -12
    property int lastMonthOffset: 24

    signal backRequested()

    function monthDate(offset) {
        return new Date(selectedYear, selectedMonth + offset, 1);
    }

    function monthName(month) {
        return Qt.locale().standaloneMonthName(month, Locale.LongFormat);
    }

    function monthShortName(month) {
        return Qt.locale().standaloneMonthName(month, Locale.ShortFormat);
    }

    function populateMonths() {
        monthModel.clear();
        for (let offset = firstMonthOffset; offset <= lastMonthOffset; ++offset) {
            const date = monthDate(offset);
            monthModel.append({
                "year": date.getFullYear(),
                "month": date.getMonth()
            });
        }
        Qt.callLater(function() {
            const initialIndex = Math.abs(firstMonthOffset);
            monthList.positionViewAtIndex(initialIndex, ListView.Beginning);
        });
    }

    function ensureMonthRange() {
        if (monthList.currentIndex <= 2) {
            const oldCount = monthModel.count;
            for (let i = 0; i < 12; ++i) {
                const first = monthModel.get(0);
                const date = new Date(first.year, first.month - 1, 1);
                monthModel.insert(0, {
                    "year": date.getFullYear(),
                    "month": date.getMonth()
                });
            }
            monthList.positionViewAtIndex(monthList.currentIndex + 12, ListView.Beginning);
            firstMonthOffset -= 12;
        }
        if (monthList.currentIndex > monthModel.count - 3) {
            for (let i = 0; i < 12; ++i) {
                const last = monthModel.get(monthModel.count - 1);
                const date = new Date(last.year, last.month + 1, 1);
                monthModel.append({
                    "year": date.getFullYear(),
                    "month": date.getMonth()
                });
            }
            lastMonthOffset += 12;
        }
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstWeekday(year, month) {
        /*
         * Monday = 0
         * Sunday = 6
         */
        const weekday = new Date(year, month, 1).getDay();
        return (weekday + 6) % 7;
    }

    function dayForIndex(year, month, index) {
        const first = firstWeekday(year, month);
        return index - first + 1;
    }

    function isCurrentDay(year, month, day) {
        const now = new Date();
        return (now.getFullYear() === year && now.getMonth() === month && now.getDate() === day);
    }

    function isValidDay(year, month, day) {
        return (day >= 1 && day <= daysInMonth(year, month));
    }

    function goToMonth(year, month) {
        selectedYear = year;
        selectedMonth = month;
        selectorMode = "calendar";
        Qt.callLater(function() {
            for (let i = 0; i < monthModel.count; ++i) {
                const item = monthModel.get(i);
                if (item.year === year && item.month === month) {
                    monthList.positionViewAtIndex(i, ListView.Beginning);
                    break;
                }
            }
        });
    }

    function openMonths() {
        selectorMode = "months";
    }

    function openYears() {
        selectorMode = "years";
        Qt.callLater(function() {
            rebuildYearGroups();
            yearGroupList.positionViewAtIndex(20, ListView.Beginning);
        });
    }

    function selectMonth(month) {
        goToMonth(selectedYear, month);
    }

    function selectYear(year) {
        goToMonth(year, selectedMonth);
    }

    function goBack() {
        if (selectorMode === "months" || selectorMode === "years") {
            selectorMode = "calendar";
            return ;
        }
        root.backRequested();
    }

    function rebuildYearGroups() {
        yearGroupModel.clear();
        const selectedGroupStart = Math.floor(root.selectedYear / 12) * 12;
        for (let group = -20; group <= 20; ++group) {
            yearGroupModel.append({
                "startYear": selectedGroupStart + group * 12
            });
        }
    }

    implicitWidth: 380
    implicitHeight: selectorMode === "calendar" ? content.y + content.height + 12 : selectorMode === "months" ? monthsContent.y + monthsContent.height + 12 : yearsContent.y + yearsContent.height + 12
    Component.onCompleted: {
        populateMonths();
        rebuildYearGroups();
    }
    onSelectorModeChanged: {
        if (selectorMode === "years") {
            rebuildYearGroups();
            Qt.callLater(function() {
                yearGroupList.positionViewAtIndex(20, ListView.Beginning);
            });
        }
    }

    ListModel {
        id: monthModel
    }


    Column {
        id: content

        visible: root.selectorMode === "calendar"
        y: 12
        spacing: 10

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: 356
            height: 48
            title: "Calendar"
            subtitle: "View your calendar"
            onBackClicked: root.backRequested()
        }

        /*
         * Month / year selector
         */
        Rectangle {
            id: selector

            width: 356
            height: 42
            radius: 13
            color: ThemeColors.surface
            border.width: 1
            border.color: ThemeColors.border

            Row {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    width: parent.width * 0.58
                    height: parent.height
                    color: "transparent"
                    radius: 13
                    scale: monthHover.hovered ? 1.01 : 1

                    Text {
                        anchors.centerIn: parent
                        text: root.monthName(root.selectedMonth)
                        color: ThemeColors.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    HoverHandler {
                        id: monthHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.openMonths()
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }

                    }

                }

                Rectangle {
                    width: parent.width * 0.42
                    height: parent.height
                    color: "transparent"
                    radius: 13
                    scale: yearHover.hovered ? 1.01 : 1

                    Text {
                        anchors.centerIn: parent
                        text: String(root.selectedYear)
                        color: ThemeColors.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    HoverHandler {
                        id: yearHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.openYears()
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }

                    }

                }

            }

        }

        /*
         * Weekday header
         */
        Row {
            width: 356
            height: 22
            spacing: 0

            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                delegate: Text {
                    required property string modelData

                    width: 356 / 7
                    height: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: ThemeColors.textMuted
                    font.pixelSize: 9
                    font.weight: Font.Medium
                }

            }

        }

        /*
         * Calendar viewport.
         */
        Item {
            width: 356
            height: root.monthHeight
            clip: true

            ListView {
                id: monthList

                anchors.fill: parent
                orientation: ListView.Vertical
                model: monthModel
                clip: true
                spacing: 0
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                maximumFlickVelocity: 1400
                onMovementEnded: {
                    const index = Math.round(contentY / root.monthHeight);
                    positionViewAtIndex(index, ListView.SnapPosition);
                    if (index >= 0 && index < count) {
                        const item = model.get(index);
                        root.selectedYear = item.year;
                        root.selectedMonth = item.month;
                    }
                    root.ensureMonthRange();
                }

                delegate: Item {
                    id: monthDelegate

                    required property int year
                    required property int month

                    width: monthList.width
                    height: root.monthHeight

                    Grid {
                        anchors.fill: parent
                        columns: 7
                        rowSpacing: 0
                        columnSpacing: 0

                        Repeater {
                            model: 42

                            delegate: Item {
                                id: dayCell

                                required property int index
                                readonly property int rawDay: root.dayForIndex(monthDelegate.year, monthDelegate.month, index)
                                readonly property int displayYear: rawDay < 1 ? new Date(monthDelegate.year, monthDelegate.month, 0).getFullYear() : rawDay > root.daysInMonth(monthDelegate.year, monthDelegate.month) ? new Date(monthDelegate.year, monthDelegate.month + 1, 1).getFullYear() : monthDelegate.year
                                readonly property int displayMonth: rawDay < 1 ? new Date(monthDelegate.year, monthDelegate.month, 0).getMonth() : rawDay > root.daysInMonth(monthDelegate.year, monthDelegate.month) ? new Date(monthDelegate.year, monthDelegate.month + 1, 1).getMonth() : monthDelegate.month
                                readonly property int displayDay: rawDay < 1 ? new Date(monthDelegate.year, monthDelegate.month, 0).getDate() + rawDay : rawDay > root.daysInMonth(monthDelegate.year, monthDelegate.month) ? rawDay - root.daysInMonth(monthDelegate.year, monthDelegate.month) : rawDay
                                readonly property bool isOutside: displayMonth !== monthDelegate.month || displayYear !== monthDelegate.year
                                readonly property bool isToday: root.isCurrentDay(displayYear, displayMonth, displayDay)

                                width: parent.width / 7
                                height: root.dayHeight

                                Text {
                                    anchors.centerIn: parent
                                    text: String(dayCell.displayDay)
                                    color: dayCell.isToday ? ThemeColors.background : dayCell.isOutside ? ThemeColors.textMuted : ThemeColors.text
                                    opacity: dayCell.isOutside ? 0.45 : 1
                                    font.pixelSize: 10
                                    font.weight: dayCell.isToday ? Font.DemiBold : Font.Normal
                                }

                                Rectangle {
                                    visible: dayCell.isToday
                                    width: 28
                                    height: 28
                                    radius: 14
                                    anchors.centerIn: parent
                                    color: ThemeColors.accent
                                    z: -1
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    Column {
        id: monthsContent

        visible: root.selectorMode === "months"
        y: 12
        spacing: 14

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: 356
            height: 48
            title: "Month"
            subtitle: String(root.selectedYear)
            onBackClicked: root.goBack()
        }

        Grid {
            id: monthGrid

            width: 356
            /*
            * 4 rows × 56px
            * 3 × 8px row gaps
            *
            * No extra bottom space.
            */
            height: 56 * 4 + 8 * 3
            columns: 3
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: 12

                delegate: Rectangle {
                    id: monthCell

                    required property int index

                    width: (monthGrid.width - monthGrid.columnSpacing * 2) / 3
                    height: 56
                    radius: 13
                    color: root.selectedMonth === monthCell.index ? ThemeColors.accent : monthHover.hovered ? ThemeColors.surfaceHover : ThemeColors.surface
                    border.width: 1
                    border.color: root.selectedMonth === monthCell.index ? ThemeColors.accent : monthHover.hovered ? ThemeColors.accent : ThemeColors.border
                    scale: monthHover.hovered ? 1.025 : 1

                    Text {
                        anchors.centerIn: parent
                        text: root.monthShortName(monthCell.index)
                        color: root.selectedMonth === monthCell.index ? ThemeColors.background : ThemeColors.text
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    HoverHandler {
                        id: monthHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.selectMonth(monthCell.index)
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

        }

    }

    Column {
        id: yearsContent

        visible: root.selectorMode === "years"
        y: 12
        spacing: 14

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        PageHeader {
            width: 356
            height: 48
            title: "Year"
            subtitle: "Select a year"
            onBackClicked: root.goBack()
        }

        Item {
            width: 356
            /*
             * 4 rows × 44px + 3 × 8px gaps
             *
             * No unnecessary bottom space.
             */
            height: 200
            clip: true

            ListModel {
                id: yearGroupModel
            }

            ListView {
                id: yearGroupList

                anchors.fill: parent
                orientation: ListView.Vertical
                model: yearGroupModel
                clip: true
                spacing: 0
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                maximumFlickVelocity: 1400
                onMovementEnded: {
                    const index = Math.round(contentY / height);
                    positionViewAtIndex(index, ListView.SnapPosition);
                }

                delegate: Item {
                    id: yearGroup

                    required property int startYear

                    width: yearGroupList.width
                    height: yearGroupList.height

                    Grid {
                        id: yearGrid

                        anchors.fill: parent
                        columns: 3
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: 12

                            delegate: Rectangle {
                                id: yearCell

                                required property int index
                                readonly property int year: yearGroup.startYear + index

                                width: (yearGrid.width - yearGrid.columnSpacing * 2) / 3
                                height: (yearGrid.height - yearGrid.rowSpacing * 3) / 4
                                radius: 13
                                color: root.selectedYear === yearCell.year ? ThemeColors.accent : yearHover.hovered ? ThemeColors.surfaceHover : ThemeColors.surface
                                border.width: 1
                                border.color: root.selectedYear === yearCell.year ? ThemeColors.accent : yearHover.hovered ? ThemeColors.accent : ThemeColors.border
                                scale: yearHover.hovered ? 1.025 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: String(yearCell.year)
                                    color: root.selectedYear === yearCell.year ? ThemeColors.background : ThemeColors.text
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                HoverHandler {
                                    id: yearHover

                                    cursorShape: Qt.PointingHandCursor
                                }

                                TapHandler {
                                    onTapped: root.selectYear(yearCell.year)
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutCubic
                                    }

                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }

                                }

                                Behavior on border.color {
                                    ColorAnimation {
                                        duration: 120
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
