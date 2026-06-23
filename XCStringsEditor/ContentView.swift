//
//  ContentView.swift
//  XCStringEditor
//
//  Created by JungHoon Noh on 1/20/24.
//

import SwiftUI
import SwiftData
import OSLog

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")

struct ActivityIndicatorModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                ProgressView()
            }
        }
    }
}

internal struct ContentView: View {
    enum Field: Hashable {
        case search
        case translation
        case table
    }
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.windowDelegate) private var windowDelegate
    
    @State private var translation: String = ""
    @State private var isEditing: Bool = false
    @State private var nextEditingItem: LocalizeItem?
    @FocusState private var focusedField: Field?
    @State private var showConfirmClose: Bool = false
    
    
//    init() {
//        #if DEBUG
//        logger.debug("init ContentView")
//        #endif
//    }
        
    @ViewBuilder
    var tableView: some View {
        @Bindable var appModel = appModel
        Table(selection: $appModel.selected, sortOrder: $appModel.sortOrder) {
            TableColumn("Key", value: \.key) { item in
                keyColumnView(item: item)
            }
            TableColumn("Default Localization (\(appModel.baseLanguage.code))") { item in
                sourceColumnView(item: item)
            }
            TableColumn(appModel.currentLanguage.localizedName) { item in
                translationView(item: item, appModel: appModel)
            }
            TableColumn("Reverse Translation") { item in
                reverseTranslationColumnView(item: item)
            }
            TableColumn("Comment") { item in
                commentColumnView(comment: item.comment ?? "")
            }
            TableColumn("State", value: \.state) { item in
                ItemStateView(state: item.state)
            }
            .width(80)
            .alignment(.center)
        } rows: {
            OutlineGroup(appModel.localizeItems, children: \.children) { item in
                TableRow(item)
                    .contextMenu { rowContextMenu(for: item) }
            }
        }
    }

    @ViewBuilder
    private func translationView(item: LocalizeItem, appModel: AppModel) -> some View {
        ZStack {
            Text(verbatim: item.translation ?? item.sourceString)
                .foregroundStyle(item.translation == nil ? .secondary.opacity(0.5) : (item.needsWork ? Color.orange : .primary))
                .opacity(isEditing && item.id == appModel.editingID ? 0.0 : 1.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .allowsHitTesting(item.children == nil)
                .onTapGesture {
                    onTapTranslation(item: item)
                }

            if isEditing && appModel.editingID == item.id {
                TextField(item.sourceString, text: $translation, axis: .vertical)
                    .lineLimit(nil)
                    .focused($focusedField, equals: .translation)
                    .onSubmit {
                        focusedField = .table
                    }
                    .onAppear {
                        logger.debug("textfield appear")
                        self.translation = item.translation ?? ""
                        DispatchQueue.main.async {
                            focusedField = .translation
                        }
                    }
            }
        }
    }

    var body: some View {
        @Bindable var appModel = appModel

        NavigationStack {
            tableView
                .focused($focusedField, equals: .table)
                .searchable(text: $appModel.searchText)
                .navigationTitle("XCStringsEditor")
                .onAppear(perform: setupUI)
                .onChange(of: appModel.sortOrder) { _, newValue in
                    appModel.sort(using: newValue)
                }
                .onChange(of: focusedField) { _, _ in
                    if focusedField != .translation {
                        endEditing()
                    }
                }
                .toolbar { languageAndFilterToolbar(appModel: appModel) }
                .toolbarRole(.editor)
                .alert("Confirm Close", isPresented: $showConfirmClose, actions: closeAlertActions, message: closeAlertMessage)
        }
        .modifier(ActivityIndicatorModifier(isPresented: $appModel.isLoading))
    }

    @ToolbarContentBuilder
    private func languageAndFilterToolbar(appModel: AppModel) -> some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            languagePicker(appModel: appModel)
            filterMenu(appModel: appModel)
        }
    }

    @ViewBuilder
    private func languagePicker(appModel: AppModel) -> some View {
        Picker("Language", selection: .init(
            get: { appModel.currentLanguage },
            set: { appModel.currentLanguage = $0 }
        )) {
            ForEach(appModel.languages) { language in
                Text(language.localizedName).tag(language)
            }
        }
        .frame(minWidth: 160)
    }

    @ViewBuilder
    private func filterMenu(@Bindable appModel: AppModel) -> some View {
        Menu {
            Button("Reset", action: { appModel.filter.reset() })
            Divider()
            Toggle("New", isOn: $appModel.filter.new)
            Toggle("Needs Review", isOn: $appModel.filter.needsReview)
            Toggle("Needs Work", isOn: $appModel.filter.needsWork)
            Toggle("Translate Later", isOn: $appModel.filter.translateLater)
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    @ViewBuilder
    private func closeAlertActions() -> some View {
        Button("Cancel", role: .cancel) {}
        Button("Discard", role: .destructive) {
            NSApp.terminate(nil)
        }
    }

    @ViewBuilder
    private func closeAlertMessage() -> some View {
        Text("Unsaved changes")
    }


    private func setupUI() {
        startMonitorKeyboardEvent()
    }

    private func endEditing(updateTranslation: Bool = true) {
#if DEBUG
        logger.debug("endEditing")
#endif
        // update editing item
        if let editingID = appModel.editingID, updateTranslation == true {
            appModel.updateTranslation(for: editingID, with: translation)
        }
        
        appModel.editingID = nil
        isEditing = false
    }
    
    private func progressColor(_ progress: Float) -> Color {
        if progress > 0.9 {
            return .green
        } else if progress > 0.7 {
            return .blue
        } else if progress > 0.5 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func keyColumnView(item: LocalizeItem) -> some View {
        HStack {
            Circle()
                .fill(.blue)
                .frame(width: 6, height: 6)
                .opacity(item.isModified ? 1.0 : 0.0)
            Text(item.key)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(item.translateLater || item.shouldTranslate == false ? .secondary : (item.needsWork && item.children != nil ? Color.orange : .primary))
        }
    }
    
    private func sourceColumnView(item: LocalizeItem) -> some View {
        Text(item.sourceString)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(item.translateLater || item.shouldTranslate == false ? .secondary : .primary)
    }
    
    @ViewBuilder
    private func reverseTranslationColumnView(item: LocalizeItem) -> some View {
        if isReverseTranslationMatch(item) {
            let image = Image(systemName: isReverseTranslationExact(item) ? "checkmark.circle.fill" : "checkmark.circle")
            
            (
                Text(image)
                    .foregroundStyle(.green) +
                Text(item.reverseTranslation ?? "")
            )
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(verbatim: item.reverseTranslation ?? "")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func commentColumnView(comment: String) -> some View {
        Text(comment)
            .foregroundStyle(.secondary)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func rowContextMenu(for item: LocalizeItem) -> some View {
        let itemIDs = contextMenuItemIDs(itemID: item.id)

        Button("Auto Translate") {
            Task {
                await appModel.translate(ids: itemIDs)
            }
        }
        Button("Reverse Translate") {
            Task {
                await appModel.reverseTranslate(ids: itemIDs)
            }
        }

        Divider()

        Button("Mark for Review") {
            appModel.markNeedsReview(ids: itemIDs)
        }
        Button("Mark as Reviewed") {
            appModel.reviewed(ids: itemIDs)
        }

        Divider()
        
        if appModel.items(with: Array(itemIDs)).allSatisfy({ $0.shouldTranslate == false }) {
            Button("Mark for Translation") {
                appModel.setShouldTranslate(true, for: itemIDs)
            }
        } else {
            Button("Mark as \"Don't Translate\"") {
                appModel.setShouldTranslate(false, for: itemIDs)
            }
        }

        Divider()
        
        Button("Mark for Translate Later") {
            appModel.markTranslateLater(ids: itemIDs, value: true)
        }
        Button("Unmark Translate Later") {
            appModel.markTranslateLater(ids: itemIDs, value: false)
        }
        Button("Mark for Needs Work") {
            appModel.markNeedsWork(ids: itemIDs, value: true)
        }
        Button("Unmark Needs Work") {
            appModel.markNeedsWork(ids: itemIDs, value: false)
        }
    }
    
    private func startMonitorKeyboardEvent() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if modifierFlags == [] {
                if event.keyCode == 36/* Enter */ {
                    if appModel.editingID == nil {
                        if let itemID = appModel.selected.first, let item = appModel.item(with: itemID) {
                            editItem(item)
                        }
                        return nil  // Intercept the event
                    }
                } else if event.keyCode == 53/* Esc */ {
                    if focusedField == .translation {
                        endEditing(updateTranslation: false)
                        focusedField = .table
                        return nil
                    }
                }
            } else if modifierFlags == [.command] && event.characters == "f" {
                focusedField = .search
                return nil
            }
            return event  // Let the event continue to be processed
        }
    }
    
    private func save() {
//        #if DEBUG
//        for item in stringsModel.allLocalizeItems {
//            print(item)
//        }
//        #endif
    }
    
    private func contextMenuItemIDs(itemID: LocalizeItem.ID) -> Set<LocalizeItem.ID> {
        if appModel.selected.contains(itemID) {
            return appModel.selected
        } else {
            return [itemID]
        }
    }
    
    private func onTapTranslation(item: LocalizeItem) {
        guard item.shouldTranslate == true else {
            return
        }
        
        if focusedField == .translation {
            nextEditingItem = item
            focusedField = nil
        } else {
            editItem(item)
        }
    }
    
    private func editItem(_ item: LocalizeItem) {
        guard item.children == nil else {
            return
        }
        appModel.selected = [item.id]
        appModel.editingID = item.id
        isEditing = true
    }
    
    private func colorForItemState(_ state: LocalizeItem.State) -> Color {
        switch state {
        case .needsReview:
            return .orange
        case .stale:
            return .secondary
        default:
            return .primary
        }
    }
    
    private func isReverseTranslationExact(_ item: LocalizeItem) -> Bool {
        return item.reverseTranslation == item.sourceString
    }
    
    private func isReverseTranslationMatch(_ item: LocalizeItem) -> Bool {
        return item.reverseTranslation?.uppercased() == item.sourceString.uppercased()
    }
}

#Preview {
    ContentView()
}
