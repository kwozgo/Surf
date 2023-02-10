import UIKit

final class HorizontalScrollCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!
    private var dataSource: [TagViewModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        registerCollectionCell()
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

    // MARK: - Public Interface

    func configure(with viewModels: [TagViewModel]) {
        dataSource = viewModels
    }

    // MARK: - Private Helpers

    private func registerCollectionCell() {
        let cellNib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "CollectionViewCell")
    }

    private func configureCollectionHeight() {
        guard let cell = makeCellViaNib() else { return }
        cell.configure(TagViewModel(title: "Any Text", state: Bool.random()))

        let cellHeight = layoutSize(for: cell).height
        let maximumAllowableHeight = cellHeight
        collectionViewHeightConstraint.constant = maximumAllowableHeight
    }

    private func makeCellViaNib() -> CollectionViewCell? {
        let bundle = Bundle(for: CollectionViewCell.self)
        let cellNib = UINib(nibName: "CollectionViewCell", bundle: bundle)
        return cellNib.instantiate(withOwner: self).first as? CollectionViewCell
    }

    private func layoutSize(for view: UIView) -> CGSize {
        let sizeToFit = CGSize(width: 100, height: 50)
        let viewSize = view.systemLayoutSizeFitting(
            sizeToFit,
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .fittingSizeLevel
        )
        return viewSize
    }
}

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
