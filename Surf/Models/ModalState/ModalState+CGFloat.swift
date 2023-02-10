import UIKit

extension ModalState {

    var height: CGFloat {
        switch self {
        case .mini:
            return 305
        case .half:
            return 465
        case .full:
            return screenHeight - statusBarHeight
        case .dismiss:
            return 200
        }
    }

    // MARK: - Private Helpers

    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    private var statusBarHeight: CGFloat {
        UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
    }
}
