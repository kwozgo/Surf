import UIKit

extension UINib {

    static func instantiateNibCell<T: UICollectionViewCell>(for cellType: T.Type, owner: Any?) -> T? {
        let bundle = Bundle(for: T.self)
        let cellNib = UINib(nibName: "\(cellType)", bundle: bundle)
        return cellNib.instantiate(withOwner: self).first as? T
    }
}
