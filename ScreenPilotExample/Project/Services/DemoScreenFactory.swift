import UIKit

@MainActor
protocol DemoScreenFactory {
    func makeDemoScreen(number: Int, navigationManager: NavigationManager) -> DemoViewController
}

final class DemoScreenFactoryImpl: DemoScreenFactory {

    func makeDemoScreen(number: Int, navigationManager: NavigationManager) -> DemoViewController {
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemPink, .systemTeal, .systemIndigo, .systemBrown
        ]
        let color = colors[number % colors.count]
        
        return DemoViewController(
            navigationManager: navigationManager,
            color: color,
            screenNumber: number
        )
    }
}
