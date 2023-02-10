import UIKit

final class LeftAlignCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 12
        minimumInteritemSpacing = 12
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        for (index, layoutAttribute) in layoutAttributes.enumerated() {
            if index == .zero || layoutAttributes[index - 1].frame.origin.y != layoutAttribute.frame.origin.y {
                layoutAttribute.frame.origin.x = sectionInset.left
            } else {
                let previousLayoutAttribute = layoutAttributes[index - 1]
                let previousEndPosition = previousLayoutAttribute.frame.origin.x + previousLayoutAttribute.frame.width
                layoutAttribute.frame.origin.x = previousEndPosition + minimumInteritemSpacing
            }
            attributesArray.append(layoutAttribute)
        }
        return attributesArray
    }
}
