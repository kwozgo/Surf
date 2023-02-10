import UIKit

extension TagViewModel {

    var backgroundColor: UIColor {
        state ? Color.backgroundActiveDarkGray : Color.backgroundInactiveGray
    }

    var titleColor: UIColor {
        state ? .white : Color.backgroundActiveDarkGray
    }
}
