import UIKit

extension UITableView {

    func recalculateHeaderViewHeight() {
        guard let header = tableHeaderView else { return }
        let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        header.frame.size.height = newSize.height
    }
}
