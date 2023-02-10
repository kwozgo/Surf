import UIKit

final class LoopScrollManager: NSObject {
    private var cellSize: CGFloat = 0.0
    private var space: CGFloat = 0.0
    private var numberOfBoundaryElements = 0
    private weak var collectionView: UICollectionView!
    private weak var delegate: LoopScrollManagerDelegate?
    private var originDataSource: [LoopScrollModel]
    private var boundaryDataSource: [LoopScrollModel] = []
    private var collectionConfiguration: CollectionViewConfiguration

    private var collectionViewBoundsValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
            case .horizontal:
                return collectionView.bounds.size.width
            case .vertical:
                return collectionView.bounds.size.height
            @unknown default:
                fatalError()
            }
        }
    }
    
    private var scrollViewContentSizeValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
            case .horizontal:
                return collectionView.contentSize.width
            case .vertical:
                return collectionView.contentSize.height
            @unknown default:
                fatalError()
            }
        }
    }
    

    
    public init(withCollectionView collectionView: UICollectionView, andData dataSet: [LoopScrollModel], delegate: LoopScrollManagerDelegate, configuration: CollectionViewConfiguration) {
        self.collectionView = collectionView
        self.originDataSource = dataSet
        self.collectionConfiguration = configuration
        self.delegate = delegate
        super.init()
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        scrollToElement(at: .zero)
    }

    // MARK: - Public Interface

    func reload(with newOriginDataSource: [LoopScrollModel]) {
        originDataSource = newOriginDataSource
        configureBoundariesForInfiniteScroll()
        collectionView.reloadData()
    }












    
    
    private func configureBoundariesForInfiniteScroll() {
        boundaryDataSource = originDataSource
        calculateCellWidth()
        let absoluteNumberOfElementsOnScreen = ceil(collectionViewBoundsValue / cellSize)
        numberOfBoundaryElements = Int(absoluteNumberOfElementsOnScreen)
        addLeadingBoundaryElements()
        addTrailingBoundaryElements()
    }
    
    private func calculateCellWidth() {
        switch collectionConfiguration.layoutType {
        case .fixedSize(let sizeValue, let padding):
            cellSize = sizeValue
            self.space = padding
        case .numberOfCellOnScreen(let numberOfCellsOnScreen):
            cellSize = (collectionViewBoundsValue/numberOfCellsOnScreen.cgFloat)
            space = 12
        }
    }
    
    private func addLeadingBoundaryElements() {
        for index in stride(from: numberOfBoundaryElements, to: 0, by: -1) {
            let indexToAdd = (originDataSource.count - 1) - ((numberOfBoundaryElements - index)%originDataSource.count)
            let data = originDataSource[indexToAdd]
            boundaryDataSource.insert(data, at: 0)
        }
    }
    
    private func addTrailingBoundaryElements() {
        for index in 0..<numberOfBoundaryElements {
            let data = originDataSource[index%originDataSource.count]
            boundaryDataSource.append(data)
        }
    }
    
    private func configureCollectionView() {
        guard let _ = self.delegate else { return }
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = collectionConfiguration.scrollingDirection
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    
    

    


    // MARK: - Private Helpers

    private func boundaryIndex(for originIndex: Int) -> Int {
        originIndex + numberOfBoundaryElements
    }

    private func getModelInformation(for indexPath: IndexPath) -> (originIndex: Int, viewModel: LoopScrollModel) {
        let originIndex = originIndex(for: indexPath.item)
        let viewModel = boundaryDataSource[indexPath.item]
        return (originIndex, viewModel)
    }

    private func scrollToElement(at originIndex: Int) {
        let indexPath = IndexPath(item: boundaryIndex(for: originIndex), section: .zero)
        let scrollPosition: UICollectionView.ScrollPosition = collectionConfiguration.scrollingDirection == .horizontal ? .left : .top
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
    }

    private func originIndex(for boundaryIndex: Int) -> Int {
        let difference = boundaryIndex - numberOfBoundaryElements
        if difference < .zero {
            let originIndex = originDataSource.count + difference
            return abs(originIndex % originDataSource.count)
        } else if difference < originDataSource.count {
            return difference
        } else {
            return abs((difference - originDataSource.count) % originDataSource.count)
        }
    }
}

// MARK: - LoopScrollManager+UICollectionViewDelegateFlowLayout

extension LoopScrollManager: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        space
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch (collectionConfiguration.scrollingDirection, delegate) {
        case (.horizontal, .some(let delegate)):
            let inset = delegate.verticalInsetOfHorizontalScroll(self)
            return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        case (.vertical, .some(let delegate)):
            let inset = delegate.horizonalInsetOfHorizontalScroll(self)
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        case (_, _):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        switch (collectionConfiguration.scrollingDirection, delegate) {
        //        case (.horizontal, .some(let delegate)):
        //            let height = collectionView.bounds.size.height - 2*delegate.verticalPaddingForHorizontalInfiniteScrollingBehaviour(behaviour: self)
        //            return CGSize(width: cellSize, height: height)
        //        case (.vertical, .some(let delegate)):
        //            let width = collectionView.bounds.size.width - 2*delegate.horizonalPaddingForHorizontalInfiniteScrollingBehaviour(behaviour: self)
        //            return CGSize(width: width, height: cellSize)
        //        case (.horizontal, _):
        //            return CGSize(width: cellSize, height: collectionView.bounds.size.height)
        //        case (.vertical, _):
        //            return CGSize(width: collectionView.bounds.size.width, height: cellSize)
        //    }
        guard let cell = makeCellViaNib() else { return CGSize(width: 100, height: 42) }
        let originalIndex = originIndex(for: indexPath.item)
        cell.configure((originDataSource[originalIndex] as? TagViewModel)!)
        let cellSize = layoutSize(for: cell)
        return cellSize
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modelInformation = getModelInformation(for: indexPath)
        delegate?.loopScrollManager(
            self,
            didSelectAt: indexPath,
            origin: modelInformation.originIndex,
            viewModel: modelInformation.viewModel
        )
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let boundarySize = numberOfBoundaryElements.cgFloat * cellSize + (numberOfBoundaryElements.cgFloat * space)
        let contentOffsetValue = collectionConfiguration.scrollingDirection == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        if contentOffsetValue >= (scrollViewContentSizeValue - boundarySize) {
            let offset = boundarySize - space
            let updatedOffsetPoint = collectionConfiguration.scrollingDirection == .horizontal ?
            CGPoint(x: offset, y: 0) : CGPoint(x: 0, y: offset)
            scrollView.contentOffset = updatedOffsetPoint
        } else if contentOffsetValue <= 0 {
            let boundaryLessSize = originDataSource.count.cgFloat * cellSize + (originDataSource.count.cgFloat * space)
            let updatedOffsetPoint = collectionConfiguration.scrollingDirection == .horizontal ?
            CGPoint(x: boundaryLessSize, y: 0) : CGPoint(x: 0, y: boundaryLessSize)
            scrollView.contentOffset = updatedOffsetPoint
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.loopScrollManagerDidEndDecelerating(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            delegate?.loopScrollManagerDidEndDecelerating(self)
        }
    }
}

// MARK: - LoopScrollManager+UICollectionViewDataSource

extension LoopScrollManager: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        boundaryDataSource.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let delegate else {
            return UICollectionViewCell()
        }
        let modelInformation = getModelInformation(for: indexPath)
        return delegate.configureCell(
            self,
            at: indexPath,
            origin: modelInformation.originIndex,
            viewModel: modelInformation.viewModel
        )
    }
}
