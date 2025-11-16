import SwiftUI
import Combine

final class EmberTint: ObservableObject {
    @Published var isDarkMode: Bool = false

    var background: Color {
        isDarkMode ? Color.black : Color.white
    }

    var primary: Color {
        isDarkMode ? Color(red: 0.95, green: 0.45, blue: 0.20)
                   : Color(red: 0.98, green: 0.52, blue: 0.25)
    }

    var secondary: Color {
        isDarkMode ? Color(red: 0.90, green: 0.35, blue: 0.18)
                   : Color(red: 0.96, green: 0.40, blue: 0.20)
    }

    var accent: Color {
        isDarkMode ? Color(red: 1.00, green: 0.65, blue: 0.30)
                   : Color(red: 1.00, green: 0.70, blue: 0.35)
    }

    var surface: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12)
                   : Color(red: 0.97, green: 0.97, blue: 0.97)
    }

    func toggleMode() {
        isDarkMode.toggle()
    }
}
