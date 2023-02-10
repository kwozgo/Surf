import Foundation

protocol IsModalView: AnyObject {}

final class ModalPresenter {
    weak var view: IsModalView!
    var modalState: ModalState = .mini
    var dataSource: [TagSectionViewModel]

    init(dataSource: [TagSectionViewModel]) {
        self.dataSource = dataSource
    }
}

// MARK: - ModalPresenter+IsModalPresenter

extension ModalPresenter: IsModalPresenter {}
