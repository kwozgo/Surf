import UIKit

final class CollectionViewCell: UICollectionViewCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureSelfView()
        configureLabelConstraints()
    }

    // MARK: - Public Interface

    func configure(_ viewModel: TagViewModel) {
        label.text = viewModel.title
        label.textColor = viewModel.titleColor
        backgroundColor = viewModel.backgroundColor
    }

    // MARK: - Private Helpers

    private func configureSelfView() {
        layer.cornerRadius = 12
    }

    private func configureLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        let constraints = [
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
