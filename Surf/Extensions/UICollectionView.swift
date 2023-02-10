import UIKit

extension UICollectionView {

    func registerCell(with identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: .main)
        register(cellNib, forCellWithReuseIdentifier: identifier)
    }
}
