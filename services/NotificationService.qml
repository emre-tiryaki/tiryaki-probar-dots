pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property int pendingFocusId: -1
    property int maxHistory: 50
    property int maxToasts: 3
    property int defaultToastTimeout: 5000
    property int criticalToastTimeout: 12000

    readonly property alias notifications: historyModel
    readonly property alias toasts: toastModel
    readonly property int count: historyModel.count

    property var _raw: ({})

    signal focusRequested(int id)

    ListModel {
        id: historyModel
    }

    ListModel {
        id: toastModel
    }

    Process {
        id: copyProc

        property string payload: ""

        command: ["wl-copy", "--", payload]
    }

    NotificationServer {
        bodySupported: true
        actionsSupported: true

        onNotification: n => {
            n.tracked = true
            root._upsert(n)
        }
    }

    function _entry(n, time) {
        const actions = []
        for (let i = 0; i < n.actions.length; i++) {
            const a = n.actions[i]
            if (a.identifier !== "default")
                actions.push({ "identifier": a.identifier, "text": a.text })
        }

        let timeout = n.expireTimeout > 0 ? n.expireTimeout * 1000 : root.defaultToastTimeout
        if (n.urgency === NotificationUrgency.Critical)
            timeout = Math.max(timeout, root.criticalToastTimeout)

        return {
            "notifId": n.id,
            "summary": n.summary || "",
            "body": n.body || "",
            "appName": n.appName || "",
            "appIcon": n.appIcon || "",
            "urgency": n.urgency,
            "time": time,
            "actionsJson": JSON.stringify(actions),
            "timeout": timeout
        }
    }

    function indexOfId(id) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).notifId === id)
                return i
        }
        return -1
    }

    function _toastIndex(id) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).notifId === id)
                return i
        }
        return -1
    }

    function _dropToast(id) {
        const i = _toastIndex(id)
        if (i >= 0)
            toastModel.remove(i)
    }

    function _pushToast(entry) {
        _dropToast(entry.notifId)
        toastModel.insert(0, entry)
        while (toastModel.count > maxToasts)
            toastModel.remove(toastModel.count - 1)
    }

    function _upsert(n) {
        const idx = indexOfId(n.id)
        const time = idx >= 0 ? historyModel.get(idx).time : Qt.formatTime(new Date(), "hh:mm")
        const entry = _entry(n, time)

        _raw[n.id] = n
        n.closed.connect(() => root._remove(n.id))
        n.summaryChanged.connect(() => root._refresh(n.id))
        n.bodyChanged.connect(() => root._refresh(n.id))

        if (idx >= 0) {
            historyModel.set(idx, entry)
        } else {
            historyModel.insert(0, entry)
            while (historyModel.count > maxHistory)
                dismiss(historyModel.count - 1)
        }

        if (!dnd)
            _pushToast(entry)
    }

    function _refresh(id) {
        const idx = indexOfId(id)
        const n = _raw[id]
        if (idx < 0 || !n)
            return

        const entry = _entry(n, historyModel.get(idx).time)
        historyModel.set(idx, entry)

        const ti = _toastIndex(id)
        if (ti >= 0)
            toastModel.set(ti, entry)
    }

    function _remove(id) {
        const idx = indexOfId(id)
        if (idx >= 0)
            historyModel.remove(idx)
        _dropToast(id)
        delete _raw[id]
    }

    function dismiss(index) {
        if (index < 0 || index >= historyModel.count)
            return

        const id = historyModel.get(index).notifId
        const raw = _raw[id]
        _remove(id)
        if (raw)
            raw.dismiss()
    }

    function dismissById(id) {
        dismiss(indexOfId(id))
    }

    function clearAll() {
        while (historyModel.count > 0)
            dismiss(0)
    }

    function expireToast(id) {
        _dropToast(id)
    }

    function clearToasts() {
        toastModel.clear()
    }

    function openFromToast(id) {
        _dropToast(id)
        pendingFocusId = id
        focusRequested(id)
    }

    function consumeFocus() {
        pendingFocusId = -1
    }

    function invokeAction(id, identifier) {
        const n = _raw[id]
        if (!n)
            return

        for (let i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === identifier) {
                n.actions[i].invoke()
                return
            }
        }
    }

    function copy(text) {
        copyProc.payload = text
        copyProc.running = false
        copyProc.running = true
    }

    function toggleDnd() {
        dnd = !dnd
        if (dnd)
            clearToasts()
    }
}