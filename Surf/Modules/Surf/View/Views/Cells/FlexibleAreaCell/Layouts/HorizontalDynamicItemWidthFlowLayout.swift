import UIKit

final class HorizontalDynamicItemWidthFlowLayout: UICollectionViewFlowLayout {

    private var frameOfCells: [[CGRect]] = []

    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let layoutAttributes = super.layoutAttributesForElements(in: rect)
        else {
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
