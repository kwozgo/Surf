import UIKit

protocol LoopScrollManagerDelegate: AnyObject {
    func configureCell(
        _ manager: LoopScrollManager,
        at indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) -> UICollectionViewCell
    func loopScrollManager(
        _ manager: LoopScrollManager,
        didSelectAt indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    )

    func loopScrollManagerDidEndDecelerating(_ manager: LoopScrollManager)
    func verticalInsetOfHorizontalScroll(_ manager: LoopScrollManager) -> CGFloat
    func horizonalInsetOfHorizontalScroll(_ manager: LoopScrollManager) -> CGFloat
}

extension LoopScrollManagerDelegate {
    
    func loopScrollManager(
        _ manager: LoopScrollManager,
        didSelectAt indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) {}

    func loopScrollManagerDidEndDecelerating(_ manager: LoopScrollManager) {}

    func verticalInsetOfHorizontalScroll(_ manager: LoopScrollManager) -> CGFloat {
        .zero
    }

    func horizonalInsetOfHorizontalScroll(_ manager: LoopScrollManager) -> CGFloat {
        .zero
    }
}
