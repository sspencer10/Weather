import SwiftUI

// view modifier
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
        
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 4)
    }
        
}
// view extension for better modifier access
extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
