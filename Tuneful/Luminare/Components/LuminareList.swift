//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

public struct LuminareList<ContentA, ContentB, V, ID>: View where ContentA: View, ContentB: View, V: Hashable, ID: Hashable {
    @Environment(\.tintColor) var tintColor
    @Environment(\.clickedOutsideFlag) var clickedOutsideFlag

    let header: LocalizedStringKey?
    @Binding var items: [V]
    @Binding var selection: Set<V>
    let addAction: () -> ()
    let content: (Binding<V>) -> ContentA
    let emptyView: () -> ContentB

    @State private var firstItem: V?
    @State private var lastItem: V?
    let id: KeyPath<V, ID>

    let addText: LocalizedStringKey
    let removeText: LocalizedStringKey

    @State var canRefreshSelection = true
    let cornerRadius: CGFloat = 2
    let lineWidth: CGFloat = 1.5
    @State var eventMonitor: AnyObject?

    public init(
        _ header: LocalizedStringKey? = nil,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        id: KeyPath<V, ID>,
        addText: LocalizedStringKey,
        removeText: LocalizedStringKey
    ) {
        self.header = header
        self._items = items
        self._selection = selection
        self.addAction = addAction
        self.content = content
        self.emptyView = emptyView
        self.id = id
        self.addText = addText
        self.removeText = removeText
    }

    public init(
        _ header: LocalizedStringKey? = nil,
        addText: LocalizedStringKey,
        removeText: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        id: KeyPath<V, ID>,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        addAction: @escaping () -> ()
    ) {
        self.init(
            header,
            items: items,
            selection: selection,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
            id: id,
            addText: addText,
            removeText: removeText
        )
    }

    public init(
        _ header: LocalizedStringKey? = nil,
        addText: LocalizedStringKey,
        removeText: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        id: KeyPath<V, ID>,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        addAction: @escaping () -> ()
    ) where ContentB == EmptyView {
        self.init(
            header,
            addText: addText,
            removeText: removeText,
            items: items,
            selection: selection,
            id: id,
            content: content,
            emptyView: {
                EmptyView()
            },
            addAction: addAction
        )
    }

    public var body: some View {
        LuminareSection(header, disablePadding: true) {
            HStack(spacing: 2) {
                Button(addText) {
                    addAction()
                }

                Button(removeText) {
                    if !selection.isEmpty {
                        canRefreshSelection = false
                        items.removeAll(where: { selection.contains($0) })

                        selection = []

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            canRefreshSelection = true
                        }
                    }
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(selection.isEmpty)
            }
            .modifier(
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.vertical, 4)
            .padding(.bottom, 4)
            .padding([.top, .horizontal], 1)

            if items.isEmpty {
                emptyView()
                    .frame(minHeight: 50)
            } else {
                List(selection: $selection) {
                    ForEach($items, id: id) { item in
                        LuminareListItem(
                            items: $items,
                            selection: $selection,
                            item: item,
                            content: content,
                            firstItem: $firstItem,
                            lastItem: $lastItem,
                            canRefreshSelection: $canRefreshSelection
                        )
                    }
                    // .onDelete(perform: deleteItems) // deleteItems crashes Loop, need to be investigated further
                    .onMove { indices, newOffset in
                        withAnimation(LuminareConstants.animation) {
                            items.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -10)
                }
                .frame(height: CGFloat(items.count * 50))
                .padding(.top, 4)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .listStyle(.plain)
            }
        }
        .onChange(of: clickedOutsideFlag) { _ in
            withAnimation(LuminareConstants.animation) {
                selection = []
            }
        }
        .onChange(of: selection) { _ in
            processSelection()

            if selection.isEmpty {
                removeEventMonitor()
            } else {
                addEventMonitor()
            }
        }
        .onAppear {
            if !selection.isEmpty {
                addEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    // #warning("onDelete & deleteItems WILL crash on macOS 14.5, but it's fine on 14.4 and below.")
    // private func deleteItems(at offsets: IndexSet) {
    //  withAnimation {
    //    items.remove(atOffsets: offsets)
    //  }
    // }

    func processSelection() {
        if selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first(where: { selection.contains($0) })
            lastItem = items.last(where: { selection.contains($0) })
        }
    }

    func addEventMonitor() {
        if eventMonitor != nil {
            return
        }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let kVK_Escape: CGKeyCode = 0x35

            if event.keyCode == kVK_Escape {
                withAnimation(LuminareConstants.animation) {
                    selection = []
                }
                return nil
            }
            return event
        } as? NSObject
    }

    func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    @Environment(\.tintColor) var tintColor

    @Binding var item: V
    let content: (Binding<V>) -> Content

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var firstItem: V?
    @Binding var lastItem: V?
    @Binding var canRefreshSelection: Bool

    @State var isHovering = false

    let cornerRadius: CGFloat = 2
    let maxLineWidth: CGFloat = 1.5
    @State var lineWidth: CGFloat = .zero

    let maxTintOpacity: CGFloat = 0.15
    @State var tintOpacity: CGFloat = .zero

    init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: Binding<V>,
        @ViewBuilder content: @escaping (Binding<V>) -> Content,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>,
        canRefreshSelection: Binding<Bool>
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self.content = content
        self._firstItem = firstItem
        self._lastItem = lastItem
        self._canRefreshSelection = canRefreshSelection
    }

    var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareItem, isHovering)
            }
            .tag(item)
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }

            .background {
                ZStack {
                    getItemBorder()
                    getItemBackground()
                }
                .padding(.horizontal, 1)
                .padding(.leading, 1)
            }

            .overlay {
                if item != items.last {
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .padding(.trailing, -0.5)
                }
            }
            .onChange(of: selection) { _ in
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(LuminareConstants.animation) {
                        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
                        lineWidth = selection.contains(item) ? maxLineWidth : .zero
                    }
                }
            }
    }

    @ViewBuilder func getItemBackground() -> some View {
        Group {
            tintColor()
                .opacity(tintOpacity)

            if isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
    }

    @ViewBuilder func getItemBorder() -> some View {
        if isFirstInSelection(), isLastInSelection() {
            singleSelectionPart(isBottomOfList: item == items.last)

        } else if isFirstInSelection() {
            firstItemPart()

        } else if isLastInSelection() {
            lastItemPart(isBottomOfList: item == items.last)

        } else if selection.contains(item) {
            doubleLinePart()
        }
    }

    func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !selection.contains(items[firstIndex - 1]) {
            return true
        }

        return item == firstItem
    }

    func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1,
           !selection.contains(items[firstIndex + 1]) {
            return true
        }

        return item == lastItem
    }

    func firstItemPart() -> some View {
        VStack(spacing: 0) {
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius
                )
                .strokeBorder(tintColor(), lineWidth: lineWidth)

                VStack {
                    Color.clear
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                }
            }
            .compositingGroup()

            // --- Bottom part ---

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(tintColor())
        }
    }

    func lastItemPart(isBottomOfList: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(tintColor())

            // --- Bottom part ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    topTrailingRadius: 0
                )
                .strokeBorder(tintColor(), lineWidth: lineWidth)

                VStack {
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                    Color.clear
                }
            }
            .compositingGroup()
        }
    }

    func doubleLinePart() -> some View {
        HStack {
            Rectangle()
                .frame(width: lineWidth)

            Spacer()

            Rectangle()
                .frame(width: lineWidth)
        }
        .foregroundStyle(tintColor())
    }

    func singleSelectionPart(isBottomOfList: Bool) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .strokeBorder(tintColor(), lineWidth: lineWidth)
    }
}

extension NSTableView {
    override open func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
    }
}
