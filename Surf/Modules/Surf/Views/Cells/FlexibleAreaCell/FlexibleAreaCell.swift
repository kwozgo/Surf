import UIKit

final class FlexibleAreaCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    private let leftAlignCollectionViewFlowLayout = LeftAlignCollectionViewFlowLayout()
    private let horizontalDynamicItemWidthFlowLayout = HorizontalDynamicItemWidthFlowLayout()

    private let rowsCount = 2
    private let cellHorizontalSpace: CGFloat = 12
    private let cellVerticalSpace: CGFloat = 12

    private var dataSource: [TagViewModel] = [] {
        willSet {
            let frames = calculateFrameOfCells(for: rowsCount, in: newValue)
            horizontalDynamicItemWidthFlowLayout.setCacheFrameOfCells(frames)
        }
    }

    override var frame: CGRect {
        willSet {
            let maximumAllowableHeight = calculateCollectionMaximumAllowableHeight()
            let totalContentHeight = leftAlignCollectionViewFlowLayout.collectionViewContentSize.height
            if totalContentHeight > maximumAllowableHeight {
                configureHorizontalDynamicItemWidthFlowLayout()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    // MARK: - Private Helpers

    private func configureCollectionView() {
        collectionView.registerCell(with: "CollectionViewCell")
        configureCollectionDelegates()
        configureCollectionLayout()
        configureCollectionScrollIndicators()
        configureCollectionContentInset()
    }

    private func configureCollectionDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func configureCollectionScrollIndicators() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func configureCollectionContentInset() {
        collectionView.contentInset = UIEdgeInsets(
            top: .zero,
            left: 20,
            bottom: .zero,
            right: .zero
        )
    }

    private func configureCollectionLayout() {
        configureLeftAlignCollectionViewFlowLayout()
        let maximumAllowableHeight = calculateCollectionMaximumAllowableHeight()
        collectionViewHeightConstraint.constant = maximumAllowableHeight
    }

    private func calculateCollectionMaximumAllowableHeight() -> CGFloat {
        guard let cell = UINib.instantiateNibCell(for: CollectionViewCell.self, owner: self) else {
            return .zero
        }
        cell.configure(TagViewModel(title: "Any Text", state: Bool.random()))

        let cellHeight = cell.layoutSize().height
        let maximumAllowableHeight = cellHeight * CGFloat(rowsCount) + cellHorizontalSpace
        return maximumAllowableHeight
    }

    private func configureLeftAlignCollectionViewFlowLayout() {
        collectionView.collectionViewLayout = leftAlignCollectionViewFlowLayout
        collectionView.isScrollEnabled = false
    }

    private func configureHorizontalDynamicItemWidthFlowLayout() {
        horizontalDynamicItemWidthFlowLayout.minimumInteritemSpacing = cellVerticalSpace
        horizontalDynamicItemWidthFlowLayout.minimumLineSpacing = cellHorizontalSpace
        horizontalDynamicItemWidthFlowLayout.estimatedItemSize = CGSize(width: 96, height: 64)

        let frames = calculateFrameOfCells(for: rowsCount, in: dataSource)
        horizontalDynamicItemWidthFlowLayout.setCacheFrameOfCells(frames)

        collectionView.collectionViewLayout = horizontalDynamicItemWidthFlowLayout
        collectionView.isScrollEnabled = true
    }

    private func calculateFrameOfCells(for rowsCount: Int, in dataSource: [TagViewModel]) -> [[CGRect]] {
        var frameOfCells: [[CGRect]] = Array(repeating: [], count: rowsCount)
        guard let cell = UINib.instantiateNibCell(for: CollectionViewCell.self, owner: self) else { return frameOfCells }

        for (index, viewModel) in dataSource.enumerated() {
            cell.configure(viewModel)
            let cellRectangle = CGRect(origin: .zero, size: cell.layoutSize())
            frameOfCells[index % rowsCount].append(cellRectangle)
        }

        /// Loop through each "row" setting the origin.x to the previous cell's origin.x + width + cellVerticalSpace (Between Cells)
        for row in .zero..<rowsCount {
            for cellColumnIndex in 1..<frameOfCells[row].count {
                var thisRectangle = frameOfCells[row][cellColumnIndex]
                let previousRectangle = frameOfCells[row][cellColumnIndex - 1]
                thisRectangle.origin.x += previousRectangle.maxX + cellVerticalSpace
                frameOfCells[row][cellColumnIndex] = thisRectangle
            }
        }
        return frameOfCells
    }
}

// MARK: - FlexibleAreaCell+CanConfigureCell

extension FlexibleAreaCell: CanConfigureCell {

    func configure(with viewModels: [TagViewModel]) {
        dataSource = viewModels
    }
}

// MARK: - FlexibleAreaCell+UICollectionViewDataSource

extension FlexibleAreaCell: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CollectionViewCell",
                for: indexPath
            ) as? CollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(dataSource[indexPath.row])
        return cell
    }
}

// MARK: - FlexibleAreaCell+UICollectionViewDelegate

extension FlexibleAreaCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        else {
            return
        }
        setUpdateState(for: cell, at: indexPath)
        moveToFirstPosition(at: indexPath)

    }

    // MARK: - Private Helpers

    private func setUpdateState(for cell: CollectionViewCell, at indexPath: IndexPath) {
        dataSource[indexPath.row].state.toggle()
        cell.configure(dataSource[indexPath.row])
    }

    private func moveToFirstPosition(at indexPath: IndexPath) {
        let stateIsSelect = dataSource[indexPath.row].state
        if stateIsSelect {
            dataSource.move(from: indexPath.row, to: .zero)
            let firstIndexPath = IndexPath(row: .zero, section: .zero)
            collectionView.moveItem(at: indexPath, to: firstIndexPath)
        }
    }
}
