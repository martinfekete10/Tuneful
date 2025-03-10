import SwiftUI

struct SettingsView: View {
    @State private var selectedCategory: SettingsCategory = .general

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(SettingsCategory.allCases) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack {
                            Image(systemName: category.iconName)
                            Text(category.title)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: 230, height: 40)
                    .if(category == selectedCategory) { button in
                        button.buttonStyle(LuminareCompactButtonStyle())
                    }
                    .if(category != selectedCategory) { button in
                        button
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 12) // Same as LuminareCompactButtonStyle
                    }
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 0) {
                Text(selectedCategory.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()

                selectedCategory.detailView
            }
            .offset(y: -35)
        }
    }
}

enum SettingsCategory: String, Identifiable, CaseIterable {
    case general
    case menuBar

    var id: String { rawValue }

    @ViewBuilder
    var detailView: some View {
        switch self {
        case .general: GeneralSettingsView()
        case .menuBar: MenuBarSettingsView()
        }
    }
    
    var title: String {
        switch self {
        case .general: "General"
        case .menuBar: "Menu bar"
        }
    }
    
    var iconName: String {
        switch self {
        case .general: "gear"
        case .menuBar: "gear"
        }
    }
}
