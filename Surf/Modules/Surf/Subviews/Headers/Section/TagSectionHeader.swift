import UIKit

final class TagSectionHeader: UICollectionReusableView {

    private var label: UILabel = {
        let label = UILabel()
        label.textColor = Color.textLightGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = .zero
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabelConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLabelConstraints()
    }

    // MARK: - Public Interface

    func setLabelText(_ text: String?) {
        label.text = text
    }

    // MARK: - Private Helpers

    private func configureLabelConstraints() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
