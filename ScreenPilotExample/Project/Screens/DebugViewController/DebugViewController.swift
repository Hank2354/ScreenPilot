import UIKit

final class DebugViewController: UIViewController {

    private var navigationManager: NavigationManager
    private var hierarchyObserver: ViewControllerHierarchyObserver

    init(navigationManager: NavigationManager, hierarchyObserver: ViewControllerHierarchyObserver) {
        self.navigationManager = navigationManager
        self.hierarchyObserver = hierarchyObserver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private var castedView: DebugView {
        view as! DebugView
    }

    override func loadView() {
        view = DebugView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        castedView.configure()
        castedView.output = self
        hierarchyObserver.addListener(self)
        
        let initialHierarchy = hierarchyObserver.getCurrentHierarchy()
        castedView.updateHierarchy(initialHierarchy)
    }
}

extension DebugViewController: DebugViewOutput {

    func debugButtonTapped() {
        castedView.toggleOverlay()
    }

    func overlayCloseTapped() {
        castedView.toggleOverlay()
    }

    func didSelectedNavigation(_ action: NavigationAction) {
        Task {
            await navigationManager.execute(action)
        }
    }
}

extension DebugViewController: HierarchyListener {
    
    func hierarchyDidChange(_ hierarchy: String) {
        castedView.updateHierarchy(hierarchy)
    }
}
