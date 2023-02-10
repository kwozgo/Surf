import UIKit

final class HorizontalDynamicItemWidthFlowLayout: UICollectionViewFlowLayout {

    private var frameOfCells: [[CGRect]] = []

    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard
//            let layoutAttributes = super.layoutAttributesForElements(in: rect)
//        else {
//            return nil
//        }


        var r: CGRect = rect
        // we could probably get and use the max-width from the cachedFrames array...
        //  but let's just set it to a very large value for now
        r.size.width = 50000
        guard let layoutAttributes = super.layoutAttributesForElements(in: r) else {
            return nil
        }

        let rowsCount = frameOfCells.count
        guard
            let attributesToReturn = layoutAttributes.map({ $0.copy() }) as? [UICollectionViewLayoutAttributes]
        else {
            return nil
        }

        attributesToReturn.forEach { layoutAttribute in
            let row: Int = layoutAttribute.indexPath.item % rowsCount
            let column: Int = layoutAttribute.indexPath.item / rowsCount
            layoutAttribute.frame.origin.x = frameOfCells[row][column].origin.x
        }

        return attributesToReturn
    }

    // MARK: - Public Interface

    func setCacheFrameOfCells(_ frameOfCells: [[CGRect]]) {
        self.frameOfCells = frameOfCells
    }
}
