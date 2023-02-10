import UIKit

final class HorizontalScrollCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var loopScrollManager: LoopScrollManager!
    private var dataSource: [TagViewModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerCell(with: "CollectionViewCell")
        configureCollectionHeight()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard loopScrollManager == nil else { return }
        let configuration = CollectionViewConfiguration(
            layoutType: .numberOfCellOnScreen(4),
            scrollingDirection: .horizontal
        )
        loopScrollManager = LoopScrollManager(
            withCollectionView: collectionView,
            andData: dataSource,
            delegate: self,
            configuration: configuration
        )
    }

    // MARK: - Private Helpers

    private func configureCollectionHeight() {
        guard let cell = UINib.instantiateNibCell(for: CollectionViewCell.self, owner: self) else { return }
        cell.configure(TagViewModel(title: "Any Text", state: Bool.random()))
        let cellHeight = cell.layoutSize().height
        let maximumAllowableHeight = cellHeight
        collectionViewHeightConstraint.constant = maximumAllowableHeight
    }
}

// MARK: - HorizontalScrollCell+CanConfigureCell

extension HorizontalScrollCell: CanConfigureCell {

    func configure(with viewModels: [TagViewModel]) {
        dataSource = viewModels
    }
}

// MARK: - HorizontalScrollCell+InfiniteScrollingBehaviourDelegate

extension HorizontalScrollCell: LoopScrollManagerDelegate {

    func configureCell(
        _ manager: LoopScrollManager,
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

    func loopScrollManager(
        _ manager: LoopScrollManager,
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
        loopScrollManager.reload(withData: dataSource)
    }
}
