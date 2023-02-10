import CoreGraphics

enum LayoutType {
    case fixedSize(sizeValue: CGFloat, lineSpacing: CGFloat)
    case numberOfCellOnScreen(Double)
}
