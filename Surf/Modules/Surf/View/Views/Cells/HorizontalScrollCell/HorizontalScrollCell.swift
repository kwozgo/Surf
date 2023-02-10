import UIKit

final class HorizontalScrollCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var collectionLoopScrollManager: CollectionLoopScrollManager!
    private var dataSource: [TagViewModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerCell(with: "CollectionViewCell")
        configureCollectionHeight()
    }
    
    // MARK: - Private Helpers
    
    private func configureCollectionHeight() {
        guard let cell = UINib.instantiateNibCell(for: CollectionViewCell.self, owner: self) else { return }
        cell.configure(TagViewModel(title: "Any Text", state: Bool.random()))
        let cellHeight = cell.layoutSize().height
        let maximumAllowableHeight = cellHeight
        collectionViewHeightConstraint.constant = maximumAllowableHeight
    }
    
    private func configureLoopScrollManager() {
        let configuration = CollectionViewConfiguration(
            layoutType: .numberOfCellOnScreen(4.5),
            scrollingDirection: .horizontal
        )
        collectionLoopScrollManager = CollectionLoopScrollManager(
            with: collectionView,
            dataSource: dataSource,
            delegate: self,
            configuration: configuration
        )
    }
}

// MARK: - HorizontalScrollCell+CanConfigureCell

extension HorizontalScrollCell: CanConfigureCell {
    
    func configure(with viewModels: [TagViewModel]) {
        dataSource = viewModels
        configureLoopScrollManager()
    }
}

// MARK: - HorizontalScrollCell+InfiniteScrollingBehaviourDelegate

extension HorizontalScrollCell: LoopScrollManagerDelegate {
    
    func configureCell(
        _ manager: CollectionLoopScrollManager,
        at indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CollectionViewCell",
                for: indexPath
            ) as? CollectionViewCell,
            let viewModel = viewModel as? TagViewModel
        else {
            return UICollectionViewCell()
        }
        cell.configure(viewModel)
        return cell
    }
    
    func collectionLoopScrollManager(
        _ manager: CollectionLoopScrollManager,
        didSelectAt indexPath: IndexPath,
        origin index: Int,
        viewModel: LoopScrollModel
    ) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        else {
            return
        }
        setUpdateState(for: cell, at: index)
    }
    
    private func setUpdateState(for cell: CollectionViewCell, at index: Int) {
        dataSource[index].state.toggle()
        collectionLoopScrollManager.reload(with: dataSource)
    }
}
