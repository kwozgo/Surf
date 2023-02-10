import UIKit

final class CollectionLoopScrollManager: NSObject {
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
    
    init(
        with collectionView: UICollectionView,
        dataSource originDataSource: [LoopScrollModel],
        delegate: LoopScrollManagerDelegate,
        configuration: CollectionViewConfiguration
    ) {
        self.collectionView = collectionView
        self.originDataSource = originDataSource
        self.collectionConfiguration = configuration
        self.delegate = delegate
        super.init()
        configureLoopScrollBoundaryDataSource()
        configureCollectionView()
        scrollToElement(at: .zero)
    }
    
    // MARK: - Public Interface
    
    func reload(with newOriginDataSource: [LoopScrollModel]) {
        originDataSource = newOriginDataSource
        configureLoopScrollBoundaryDataSource()
        collectionView.reloadData()
    }
    
    // MARK: - Private Helpers
    
    // MARK: - Configuration
    
    private func configureCollectionView() {
        configureCollectionDelegates()
        configureCollectionLayout()
        configureCollectionAppearence()
    }
    
    private func configureCollectionDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureCollectionLayout() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = collectionConfiguration.scrollingDirection
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    private func configureCollectionAppearence() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - Loop Scroll Methods
    
    private func configureLoopScrollBoundaryDataSource() {
        boundaryDataSource = originDataSource
        calculateCellWidth()
        let absoluteNumberOfElementsOnScreen = Int(ceil(collectionViewBoundsValue / cellSize))
        numberOfBoundaryElements = absoluteNumberOfElementsOnScreen
        prepareBoundaryDataSource()
    }
    
    private func calculateCellWidth() {
        switch collectionConfiguration.layoutType {
        case .fixedCellSize(let size, let space):
            cellSize = size
            self.space = space
        case .numberOfCellOnScreen(let numberOfCellsOnScreen):
            cellSize = collectionViewBoundsValue / numberOfCellsOnScreen.cgFloat
            space = 12
        }
    }
    
    private func prepareBoundaryDataSource() {
        addLeadingBoundaryElements()
        addTrailingBoundaryElements()
    }
    
    private func addLeadingBoundaryElements() {
        for index in stride(from: numberOfBoundaryElements, to: .zero, by: -1) {
            let indexToAdd = (originDataSource.count - 1) - ((numberOfBoundaryElements - index) % originDataSource.count)
            let viewModel = originDataSource[indexToAdd]
            boundaryDataSource.insert(viewModel, at: .zero)
        }
    }
    
    private func addTrailingBoundaryElements() {
        for index in .zero..<numberOfBoundaryElements {
            let data = originDataSource[index % originDataSource.count]
            boundaryDataSource.append(data)
        }
    }
    
    // MARK: - Additional
    
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
        let horizontalDirection = collectionConfiguration.scrollingDirection == .horizontal
        let scrollPosition: UICollectionView.ScrollPosition = horizontalDirection ? .left : .top
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
    
    private func calculateDynamicCellSize(for indexPath: IndexPath) -> CGSize {
        guard
            let cell = UINib.instantiateNibCell(for: CollectionViewCell.self, owner: self),
            let viewModel = originDataSource[originIndex(for: indexPath.item)] as? TagViewModel
        else {
            return CGSize(width: cellSize, height: collectionView.bounds.size.height)
        }
        cell.configure(viewModel)
        return cell.layoutSize()
    }
}

// MARK: - CollectionLoopScrollManager+UICollectionViewDelegateFlowLayout

extension CollectionLoopScrollManager: UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let delegate else {
            return UIEdgeInsets()
        }
        switch collectionConfiguration.scrollingDirection {
        case .vertical:
            let inset = delegate.verticalInsetOfHorizontalScroll(self)
            return UIEdgeInsets(
                top: inset,
                left: .zero,
                bottom: inset,
                right: .zero
            )
        case .horizontal:
            let inset = delegate.horizonalInsetOfHorizontalScroll(self)
            return UIEdgeInsets(
                top: .zero,
                left: inset,
                bottom: .zero,
                right: inset
            )
        @unknown default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*
         switch (collectionConfiguration.scrollingDirection, delegate) {
         case (.horizontal, .some(let delegate)):
         let height = collectionView.bounds.size.height - 2 * delegate.verticalInsetOfHorizontalScroll(self)
         return CGSize(width: cellSize, height: height)
         case (.vertical, .some(let delegate)):
         let width = collectionView.bounds.size.width - 2 * delegate.horizonalInsetOfHorizontalScroll(self)
         return CGSize(width: width, height: cellSize)
         case (.horizontal, _):
         return CGSize(width: cellSize, height: collectionView.bounds.size.height)
         case (.vertical, _):
         return CGSize(width: collectionView.bounds.size.width, height: cellSize)
         }
         */
        return calculateDynamicCellSize(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modelInformation = getModelInformation(for: indexPath)
        delegate?.collectionLoopScrollManager(
            self,
            didSelectAt: indexPath,
            origin: modelInformation.originIndex,
            viewModel: modelInformation.viewModel
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let boundarySize = numberOfBoundaryElements.cgFloat * cellSize + (numberOfBoundaryElements.cgFloat * space)
        let horizontalDirection = collectionConfiguration.scrollingDirection == .horizontal
        let contentOffsetValue = horizontalDirection ? scrollView.contentOffset.x : scrollView.contentOffset.y
        if contentOffsetValue >= (scrollViewContentSizeValue - boundarySize) {
            let offset = boundarySize - space
            let updatedOffsetPoint = horizontalDirection ? CGPoint(x: offset, y: .zero) : CGPoint(x: .zero, y: offset)
            scrollView.contentOffset = updatedOffsetPoint
        } else if contentOffsetValue <= .zero {
            let boundaryLessSize = originDataSource.count.cgFloat * cellSize + (originDataSource.count.cgFloat * space)
            let updatedOffsetPoint = horizontalDirection ? CGPoint(x: boundaryLessSize, y: .zero) : CGPoint(x: .zero, y: boundaryLessSize)
            scrollView.contentOffset = updatedOffsetPoint
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.collectionLoopScrollManagerDidEndDecelerating(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            delegate?.collectionLoopScrollManagerDidEndDecelerating(self)
        }
    }
}

// MARK: - CollectionLoopScrollManager+UICollectionViewDataSource

extension CollectionLoopScrollManager: UICollectionViewDataSource {
    
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
