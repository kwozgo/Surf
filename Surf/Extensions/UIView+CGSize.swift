import UIKit

extension UIView {

    func layoutSize() -> CGSize {
        let sizeToFit = CGSize(width: 100, height: 50)
        let viewSize = systemLayoutSizeFitting(
            sizeToFit,
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .fittingSizeLevel
        )
        return viewSize
    }
}
