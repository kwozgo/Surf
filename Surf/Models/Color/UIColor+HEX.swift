import UIKit

extension UIColor {
    
    convenience init?(hex: String) {
        let r, g, b: CGFloat

        guard hex.hasPrefix("#") else { return nil }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let hexStringHasCorrectCharacterNumber = hexColor.count == 6

        guard hexStringHasCorrectCharacterNumber else { return nil }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = .zero
        let hexIsValid = scanner.scanHexInt64(&hexNumber)

        guard hexIsValid else { return nil }
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
        b = CGFloat((hexNumber & 0x0000ff)) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
