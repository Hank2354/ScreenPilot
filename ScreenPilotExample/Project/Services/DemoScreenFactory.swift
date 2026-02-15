import UIKit

@MainActor
final class DemoScreenFactory {

    @MainActor
    static func createScreen(number: Int) -> DemoViewController {
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemPink, .systemTeal, .systemIndigo, .systemBrown
        ]
        let color = colors[number % colors.count]
        
        return DemoViewController(screenNumber: number, color: color)
    }
}
