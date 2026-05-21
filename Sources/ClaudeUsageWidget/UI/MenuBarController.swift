import AppKit
import SwiftUI

/// Manages the menu bar status item and its detail popover.
@MainActor
final class MenuBarController: NSObject, NSPopoverDelegate {
    private let store: UsageStore
    private let onOpenSettings: () -> Void
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    init(store: UsageStore, onOpenSettings: @escaping () -> Void) {
        self.store = store
        self.onOpenSettings = onOpenSettings
        super.init()
    }

    /// Shows the status item. Safe to call repeatedly.
    func install() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = item.button else { return }

        let host = NSHostingView(rootView: MenuBarLabel(store: store))
        host.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(host)
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            host.topAnchor.constraint(equalTo: button.topAnchor),
            host.bottomAnchor.constraint(equalTo: button.bottomAnchor),
        ])
        button.target = self
        button.action = #selector(togglePopover)

        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: DetailPanelView(
                store: store,
                onRefresh: { [weak self] in Task { await self?.store.refreshNow() } },
                onOpenSettings: { [weak self] in
                    self?.popover.performClose(nil)
                    self?.onOpenSettings()
                }
            )
        )
        self.statusItem = item
    }

    /// Removes the status item.
    func remove() {
        if let statusItem { NSStatusBar.system.removeStatusItem(statusItem) }
        statusItem = nil
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            store.setPanelVisible(true, source: .menuBar)
        }
    }

    /// Fires for every close path — explicit toggle and transient click-away —
    /// so the store can restore its normal poll interval.
    nonisolated func popoverDidClose(_ notification: Notification) {
        Task { @MainActor in store.setPanelVisible(false, source: .menuBar) }
    }
}
