import UIKit

final class LoopScrollManager: NSObject {
    fileprivate var cellSize: CGFloat = 0.0
    fileprivate var space: CGFloat = 0.0
    fileprivate var numberOfBoundaryElements = 0
    fileprivate(set) public weak var collectionView: UICollectionView!
    fileprivate(set) public weak var delegate: LoopScrollManagerDelegate?
    fileprivate(set) public var dataSet: [LoopScrollModel]
    fileprivate(set) public var boundaryDataSource: [LoopScrollModel] = []
    
    fileprivate var collectionViewBoundsValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
            case .horizontal:
                return collectionView.bounds.size.width
            case .vertical:
                return collectionView.bounds.size.height
            }
        }
    }
    
    fileprivate var scrollViewContentSizeValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
            case .horizontal:
                return collectionView.contentSize.width
            case .vertical:
                return collectionView.contentSize.height
            }
        }
    }
    
    fileprivate(set) public var collectionConfiguration: CollectionViewConfiguration
    
    public init(withCollectionView collectionView: UICollectionView, andData dataSet: [LoopScrollModel], delegate: LoopScrollManagerDelegate, configuration: CollectionViewConfiguration) {
        self.collectionView = collectionView
        self.dataSet = dataSet
        self.collectionConfiguration = configuration
        self.delegate = delegate
        super.init()
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        scrollToFirstElement()
    }
    
    
    private func configureBoundariesForInfiniteScroll() {
        boundaryDataSource = dataSet
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
            let indexToAdd = (dataSet.count - 1) - ((numberOfBoundaryElements - index)%dataSet.count)
            let data = dataSet[indexToAdd]
            boundaryDataSource.insert(data, at: 0)
        }
    }
    
    private func addTrailingBoundaryElements() {
        for index in 0..<numberOfBoundaryElements {
            let data = dataSet[index%dataSet.count]
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
    
    private func scrollToFirstElement() {
        scroll(toElementAtIndex: 0)
    }
    
    
    public func scroll(toElementAtIndex index: Int) {
        let boundaryDataSetIndex = indexInBoundaryDataSet(forIndexInOriginalDataSet: index)
        let indexPath = IndexPath(item: boundaryDataSetIndex, section: 0)
        let scrollPosition: UICollectionView.ScrollPosition = collectionConfiguration.scrollingDirection == .horizontal ? .left : .top
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
    }
    
    public func indexInOriginalDataSet(forIndexInBoundaryDataSet index: Int) -> Int {
        let difference = index - numberOfBoundaryElements
        if difference < 0 {
            let originalIndex = dataSet.count + difference
            return abs(originalIndex % dataSet.count)
        } else if difference < dataSet.count {
            return difference
        } else {
            return abs((difference - dataSet.count) % dataSet.count)
        }
    }
    
    public func indexInBoundaryDataSet(forIndexInOriginalDataSet index: Int) -> Int {
        return index + numberOfBoundaryElements
    }
    
    
    public func reload(withData dataSet: [LoopScrollModel]) {
        self.dataSet = dataSet
        configureBoundariesForInfiniteScroll()
        collectionView.reloadData()
        //scrollToFirstElement()
    }
    
    public func updateConfiguration(configuration: CollectionViewConfiguration) {
        collectionConfiguration = configuration
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.collectionView.reloadData()
            self.scrollToFirstElement()
        }
    }

    // MARK: - Private Helpers

    private func getModelInformation(for indexPath: IndexPath) -> (originIndex: Int, viewModel: LoopScrollModel) {
        let originIndex = indexInOriginalDataSet(forIndexInBoundaryDataSet: indexPath.item)
        let viewModel = boundaryDataSource[indexPath.item]
        return (originIndex, viewModel)
    }
}

// MARK: - LoopScrollManager+UICollectionViewDelegateFlowLayout

extension LoopScrollManager: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        space
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        space
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        let originalIndex = indexInOriginalDataSet(forIndexInBoundaryDataSet: indexPath.item)
        cell.configure((dataSet[originalIndex] as? TagViewModel)!)
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
            let boundaryLessSize = dataSet.count.cgFloat * cellSize + (dataSet.count.cgFloat * space)
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
