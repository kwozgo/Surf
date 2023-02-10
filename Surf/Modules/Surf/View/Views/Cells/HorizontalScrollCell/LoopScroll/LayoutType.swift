import CoreGraphics

enum LayoutType {
    case fixedCellSize(cellSizeValue: CGFloat, lineSpacing: CGFloat)
    case numberOfCellOnScreen(Double)
}
