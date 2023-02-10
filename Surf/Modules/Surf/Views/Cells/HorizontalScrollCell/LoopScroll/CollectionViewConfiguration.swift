import UIKit

struct CollectionViewConfiguration {
    let scrollingDirection: UICollectionView.ScrollDirection
    var layoutType: LayoutType

    init(layoutType: LayoutType, scrollingDirection: UICollectionView.ScrollDirection) {
        self.layoutType = layoutType
        self.scrollingDirection = scrollingDirection
    }
}
