import UIKit

extension UITableView {

    func recalculateHeaderViewHeight() {
        guard let header = tableHeaderView else { return }
        let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        header.frame.size.height = newSize.height
    }
}

extension UITableView {

    func registerCell(for identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: .main)
        register(cellNib, forCellReuseIdentifier: identifier)
    }
}
