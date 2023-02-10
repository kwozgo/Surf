import UIKit

protocol LoopScrollManagerDelegate: AnyObject {
    func configureCell(
        _ manager: CollectionLoopScrollManager,
        at indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) -> UICollectionViewCell
    func collectionLoopScrollManager(
        _ manager: CollectionLoopScrollManager,
        didSelectAt indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    )

    func collectionLoopScrollManagerDidEndDecelerating(_ manager: CollectionLoopScrollManager)
    func verticalInsetOfHorizontalScroll(_ manager: CollectionLoopScrollManager) -> CGFloat
    func horizonalInsetOfHorizontalScroll(_ manager: CollectionLoopScrollManager) -> CGFloat
}

extension LoopScrollManagerDelegate {
    
    func collectionLoopScrollManager(
        _ manager: CollectionLoopScrollManager,
        didSelectAt indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) {}

    func collectionLoopScrollManagerDidEndDecelerating(_ manager: CollectionLoopScrollManager) {}

    func verticalInsetOfHorizontalScroll(_ manager: CollectionLoopScrollManager) -> CGFloat {
        .zero
    }

    func horizonalInsetOfHorizontalScroll(_ manager: CollectionLoopScrollManager) -> CGFloat {
        .zero
    }
}
