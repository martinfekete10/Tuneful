import SwiftUI
import Luminare

struct SettingsView: View {
    @State private var selectedCategory: SettingsCategory? = .general

    var body: some View {
        //        NavigationView {
        //            List(SettingsCategory.allCases, selection: $selectedCategory) { category in
        //                VStack(alignment: .leading) {
        //                    Button(action: { selectedCategory = category }) {
        //                        HStack {
        //                            Image(systemName: category.iconName)
        //                            Text(category.title)
        //                        }
        //                        .frame(maxWidth: .infinity, alignment: .leading)
        //                    }
        //                    .if(category == selectedCategory) { button in
        //                        button.buttonStyle(LuminareCompactButtonStyle())
        //                    }
        //                    .if(category != selectedCategory) { button in
        //                        button
        //                            .buttonStyle(PlainButtonStyle())
        //                            .padding(.horizontal, 12) // Same as LuminareCompactButtonStyle
        //                    }
        //                }
        //                .frame(width: 200, height: 40)
        //            }
        //            .listStyle(.sidebar)
        //            .frame(width: 250)
        //            .background(
        //                VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
        //            )
        //            .offset(y: 60)
        //
        //            VStack {
        //                Text(selectedCategory!.title)
        //                    .frame(width: 550, height: 50)
        //
        //                Divider()
        //
        //                selectedCategory!.detailView
        //                    .frame(width: 550, height: 450)
        //            }
        //            .background(
        //                VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
        //            )
        //        }
        HStack {
            VStack {
                Text("Test")
            }
            .offset(y: -60)
            .frame(width: 300, height: 800)
            
            Divider()
                .frame(height: 800)
                .offset(y: -60)
            
            VStack {
                Text("Test")
            }
            .offset(y: -60)
            .frame(width: 500, height: 800)
            .background(
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            )
        }
        .frame(width: 800, height: 500)
//        .background(
//            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
//        )
    }
}

enum SettingsCategory: String, Identifiable, CaseIterable {
    case general
    case appearance
    case privacy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .privacy: return "Privacy"
        }
    }

    var iconName: String {
        switch self {
        case .general: return "gear"
        case .appearance: return "paintbrush"
        case .privacy: return "lock.shield"
        }
    }

    @ViewBuilder
    var detailView: some View {
        switch self {
        case .general: GeneralSettingsView().border(Color.green)
        case .appearance: AppearanceSettingsView()
        case .privacy: PrivacySettingsView()
        }
    }
}

struct GeneralSettingsView2: View {
    var body: some View {
        Text("General Settings")
            .font(.title)
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings")
            .font(.title)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .font(.title)
    }
}
