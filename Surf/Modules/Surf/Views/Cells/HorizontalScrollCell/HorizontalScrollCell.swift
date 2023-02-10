import UIKit

final class HorizontalScrollCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!
    private var dataSource: [TagViewModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerCell(with: "CollectionViewCell")
        configureCollectionHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard infiniteScrollingBehaviour == nil else { return }
        let configuration = CollectionViewConfiguration(layoutType: .numberOfCellOnScreen(4), scrollingDirection: .horizontal)
        infiniteScrollingBehaviour = InfiniteScrollingBehaviour(withCollectionView: collectionView, andData: dataSource, delegate: self, configuration: configuration)
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

extension HorizontalScrollCell: InfiniteScrollingBehaviourDelegate {

    func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: LoopScrollModel, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        if let collectionCell = cell as? CollectionViewCell,
           let card = data as? TagViewModel {
            collectionCell.configure(card)
        }
        return cell
    }

    func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: LoopScrollModel, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        else {
            return
        }
        setUpdateState(for: cell, at: originalIndex)
    }

    private func setUpdateState(for cell: CollectionViewCell, at indexPath: Int) {
        dataSource[indexPath].state.toggle()
        infiniteScrollingBehaviour.reload(withData: dataSource)
    }
}
