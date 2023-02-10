import UIKit

final class SubmitView: UIView {
    var onSubmit: (() -> Void)?

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Хочешь к нам?"
        label.textColor = Color.textLightGray
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = .zero
        return label
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Отправить заявку"
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 44,
            bottom: 20,
            trailing: 44
        )
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = Color.backgroundActiveDarkGray
        configuration.baseForegroundColor = .white
        button.configuration = configuration
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSelf()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSelf()
    }

    // MARK: - Private Helpers

    @objc
    private func submitAction() {
        onSubmit?()
    }

    private func configureSelf() {
        configureSubmitButtonConstraints()
        configureLabelConstraints()
    }

    private func configureLabelConstraints() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant: -24)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureSubmitButtonConstraints() {
        addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            submitButton.topAnchor.constraint(equalTo: topAnchor),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
