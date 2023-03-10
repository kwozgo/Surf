import UIKit

protocol IsModalPresenter {
    var modalState: ModalState { get set }
    var dataSource: [TagSectionViewModel] { get }
}

final class ModalViewController: UIViewController {
    var presenter: IsModalPresenter!

    private enum DragDirection {
        case up
        case down
        
        init(_ state: Bool) {
            self = state ? .down : .up
        }
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var submitContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var submitView: SubmitView = {
        let view = SubmitView()
        view.onSubmit = { [weak self] in
            self?.submitApplication()
        }
        return view
    }()
    
    private lazy var backstageView: UIView = {
        let backgroundImage = UIImage(named: "Background")!
        let view = UIImageView(image: backgroundImage)
        return view
    }()
    
    private lazy var collectionController: TableViewController = {
        let controller = TableViewController()
        controller.dataSource = presenter.dataSource
        return controller
    }()
    
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?
    private var submitContainerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSelf()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSubmitViewConstraints()
        animatePresentationMovement()
    }
    
    // MARK: - Private Helpers
    
    // MARK: - Configuration Methods
    
    private func configureSelf() {
        view.backgroundColor = .clear
        configureBackstageConstraints()
        configureGesture()
        configureContainerViewConstraints()
        configureContentViewConstraints()
        configureSubmitContainerViewConstraints()
    }
    
    func configureBackstageConstraints() {
        view.addSubview(backstageView)
        backstageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            backstageView.topAnchor.constraint(equalTo: view.topAnchor),
            backstageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backstageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backstageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        view.addGestureRecognizer(gesture)
    }
    
    private func configureContainerViewConstraints() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        configureDynamicContainerViewConstraints()
    }
    
    private func configureDynamicContainerViewConstraints() {
        /// Set default (`mini`) container height
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: presenter.modalState.height)
        
        /// By setting the height to default (`mini`) height, the container will be hide below the bottom anchor view
        /// Later, will bring it up by set it to `.zero`, set the constant to default (`mini`) height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: presenter.modalState.height)
        
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    private func configureContentViewConstraints() {
        addChild(collectionController)
        collectionController.view.frame = containerView.bounds
        containerView.addSubview(collectionController.view)
        collectionController.didMove(toParent: self)
        collectionController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            collectionController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            collectionController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureSubmitContainerViewConstraints() {
        view.addSubview(submitContainerView)
        submitContainerView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            submitContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            submitContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        submitContainerViewBottomConstraint = submitContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: presenter.modalState.height)
        submitContainerViewBottomConstraint?.isActive = true
    }
    
    private func configureSubmitViewConstraints() {
        submitContainerView.addSubview(submitView)
        submitView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            submitView.centerXAnchor.constraint(equalTo: submitContainerView.centerXAnchor),
            submitView.topAnchor.constraint(equalTo: submitContainerView.topAnchor, constant: 32),
            submitView.bottomAnchor.constraint(equalTo: submitContainerView.bottomAnchor, constant: -safeAreaBottom)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private var safeAreaBottom: CGFloat {
        guard let window = UIApplication.shared.keyWindow else { return .zero}
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        let bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        return bottomSafeAreaHeight
    }
    
    @objc
    private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let dragMovementHeight = translation.y
        let direction = DragDirection(dragMovementHeight > .zero)
        monitorModalState(gesture.state, direction: direction, dragMovementHeight: dragMovementHeight, gesture: gesture)
    }
    
    // MARK: - Modal State Calculation Methods
    
    private func monitorModalState(
        _ gestureState: UIGestureRecognizer.State,
        direction: DragDirection,
        dragMovementHeight: CGFloat,
        gesture: UIPanGestureRecognizer
    ) {
        let newHeight = presenter.modalState.height - dragMovementHeight
        if gestureState == .changed {
            setActualContainerHeight(newHeight)
            setActualSubmitContainerHeight(newHeight, dragMovementHeight: dragMovementHeight)
        } else if gestureState == .ended {
            moveToNewState(using: newHeight, direction: direction, gesture: gesture)
        }
    }
    
    private func setActualContainerHeight(_ newHeight: CGFloat) {
        if newHeight < ModalState.full.height {
            containerViewHeightConstraint?.constant = newHeight
            view.layoutIfNeeded()
        }
    }
    
    private func setActualSubmitContainerHeight(_ newHeight: CGFloat, dragMovementHeight: CGFloat) {
        if newHeight < ModalState.mini.height {
            switch presenter.modalState {
            case .mini:
                submitContainerViewBottomConstraint?.constant = dragMovementHeight
            case .half:
                let difference = ModalState.half.height - ModalState.mini.height
                submitContainerViewBottomConstraint?.constant = dragMovementHeight - difference
            case .full:
                let difference = ModalState.full.height - ModalState.mini.height
                submitContainerViewBottomConstraint?.constant = dragMovementHeight - difference
            case .dismiss:
                break
            }
        } else {
            submitContainerViewBottomConstraint?.constant = .zero
        }
    }
    
    private func moveToNewState(using height: CGFloat, direction: DragDirection, gesture: UIPanGestureRecognizer) {
        if height < ModalState.dismiss.height {
            animateDismissMovement(gesture: gesture)
        } else if height > ModalState.dismiss.height && direction == .up && height < ModalState.mini.height {
            animateMovement(to: .mini)
        } else if height > ModalState.mini.height && direction == .up && height < ModalState.half.height {
            animateMovement(to: .half)
        } else if height > ModalState.half.height && direction == .up && height < ModalState.full.height {
            animateMovement(to: .full)
        } else if height > ModalState.half.height && direction == .down && height < ModalState.full.height {
            animateMovement(to: .half)
        } else if height > ModalState.mini.height && direction == .down && height < ModalState.half.height {
            animateMovement(to: .mini)
        } else if height > ModalState.dismiss.height && direction == .down && height < ModalState.mini.height {
            animateMovement(to: .mini)
        }
    }
    
    // MARK: - Animation Methods
    
    private func animatePresentationMovement() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = .zero
            self.submitContainerViewBottomConstraint?.constant = .zero
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateMovement(to newState: ModalState) {
        presenter.modalState = newState
        UIView.animate(withDuration: 0.3) {
            self.containerViewHeightConstraint?.constant = newState.height
            self.submitContainerViewBottomConstraint?.constant = .zero
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissMovement(gesture: UIPanGestureRecognizer) {
        gesture.isEnabled = false
        presenter.modalState = .dismiss
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = ModalState.mini.height
            self.submitContainerViewBottomConstraint?.constant = ModalState.mini.height
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Alert
    
    private func submitApplication() {
        let alertController = UIAlertController(
            title: "??????????????????????!",
            message: "???????? ???????????? ?????????????? ????????????????????!",
            preferredStyle: .alert
        )
        let close = UIAlertAction(title: "??????????????", style: .destructive)
        alertController.addAction(close)
        self.present(alertController, animated: true)
    }
}

// MARK: - ModalViewController+IsModalView

extension ModalViewController: IsModalView {}
