import UIKit

final class ModalViewController: UIViewController {
    private enum ModalState {
        case mini
        case half
        case full
        case dismiss

        var height: CGFloat {
            switch self {
            case .mini:
                return 305
            case .half:
                return 465
            case .full:
                return screenHeight - statusBarHeight
            case .dismiss:
                return 200
            }
        }

        // MARK: - Private Helpers

        private var screenHeight: CGFloat {
            UIScreen.main.bounds.height
        }

        private var statusBarHeight: CGFloat {
            UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
        }
    }

    private enum DragDirection {
        case up
        case down

        init(_ state: Bool) {
            self = state ? .down : .up
        }
    }

    private var modalState: ModalState = .mini

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

    private func submitApplication() {
        let alertController = UIAlertController(title: "Поздравляем!", message: "Ваша заявка успешно отправлена!", preferredStyle: .alert)
        let close = UIAlertAction(title: "Закрыть", style: .destructive)
        alertController.addAction(close)
        self.present(alertController, animated: true)
    }


    private lazy var collectionController: TableViewController = {
        TableViewController()
    }()

    private var currentContainerHeight: CGFloat = ModalState.mini.height

    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?
    private var submitContainerViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSelf()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSubmitContainerViewConstraints()
        configureSubmitViewConstraints()
        animatePresentationMovement()
    }

    // MARK: - Private Helpers

    // MARK: - Configuration Methods

    func configureSelf() {
        view.backgroundColor = .clear
        configureGesture()
        configureContainerViewConstraints()
        configureContentViewConstraints()
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
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: ModalState.mini.height)

        /// By setting the height to default (`mini`) height, the container will be hide below the bottom anchor view
        /// Later, will bring it up by set it to `.zero`, set the constant to default (`mini`) height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ModalState.mini.height)

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

        submitContainerViewBottomConstraint = submitContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ModalState.mini.height)
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
        let newHeight = currentContainerHeight - dragMovementHeight
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
            switch modalState {
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

    func animatePresentationMovement() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = .zero
            self.submitContainerViewBottomConstraint?.constant = .zero
            self.view.layoutIfNeeded()
        }
    }

    private func animateMovement(to newState: ModalState) {
        modalState = newState
        UIView.animate(withDuration: 0.3) {
            self.containerViewHeightConstraint?.constant = newState.height
            self.submitContainerViewBottomConstraint?.constant = .zero
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = newState.height
    }

    func animateDismissMovement(gesture: UIPanGestureRecognizer) {
        gesture.isEnabled = false
        modalState = .dismiss
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = ModalState.mini.height
            self.submitContainerViewBottomConstraint?.constant = ModalState.mini.height
            self.view.layoutIfNeeded()
        }
    }
}














//    private lazy var contentView: UIView = {
//        let stackView = UIStackView(arrangedSubviews: [titleLabel, notesLabel])
//        stackView.axis = .vertical
//        stackView.spacing = 12.0
//        return stackView
//    }()

//
//private lazy var taskLabel: UILabel = {
//    let label = UILabel()
//    label.text = "Работай над реальными задачами под руководством опытного наставника и получи возможность стать частью команды мечты."
//    label.font = .systemFont(ofSize: 14)
//    label.textColor = .darkGray
//    label.numberOfLines = 3
//    return label
//}()
//
//private lazy var benefitsLabel: UILabel = {
//    let label = UILabel()
//    label.text = "Получай стипендию, выстраивай удобный график, работай на современном железе."
//    label.font = .systemFont(ofSize: 14)
//    label.textColor = .darkGray
//    label.numberOfLines = 2
//    return label
//}()
//
//lazy var notesLabel: UILabel = {
//    let label = UILabel()
//    label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sem fringilla ut morbi tincidunt augue interdum. \n\nUt morbi tincidunt augue interdum velit euismod in pellentesque massa. Pulvinar etiam non quam lacus suspendisse faucibus interdum posuere. Mi in nulla posuere sollicitudin aliquam ultrices sagittis orci a. Eget nullam non nisi est sit amet. Odio pellentesque diam volutpat commodo. Id eu nisl nunc mi ipsum faucibus vitae.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sem fringilla ut morbi tincidunt augue interdum. Ut morbi tincidunt augue interdum velit euismod in pellentesque massa."
//    label.font = .systemFont(ofSize: 16)
//    label.textColor = .darkGray
//    label.numberOfLines = 0
//    return label
//}()


//    private lazy var taskCollectionView: UICollectionView = {
////        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
////        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
////        layout.itemSize = CGSize(width: 100, height: 50)
////        layout.scrollDirection = .horizontal
//
//
//
//
////        func makeLayout() -> UICollectionViewLayout {
////            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
////                if section == 0 {
////                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
////                    item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 12.0, bottom: 0.0, trailing: 12.0)
////                    let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.25)), subitem: item, count: 1)
////                    let section = NSCollectionLayoutSection(group: group)
////                    section.contentInsets = NSDirectionalEdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0)
////                    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
////                    return section
////                }
////                return nil
////            }
////            return layout
////        }
////        let layout = makeLayout()
//
//
//
//        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.scrollDirection = .horizontal
//
//        let collectionView = UICollectionView(frame: CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.width, height: 50)), collectionViewLayout: layout)
//
//
//
//
//
//
////        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        //collectionView.translatesAutoresizingMaskIntoConstraints = false
//        return collectionView
//    }()

//    let categories = Category.load() // Load data
//    let feeds = Feed.load()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        categoriesCollectionView.dataSource = self
//        categoriesCollectionView.delegate = self
//        feedCollectionView.dataSource = self
//        feedCollectionView.delegate = self
//        // Do any additional setup after loading the view.
//    }




//extension ModalViewController: UICollectionViewDelegate {
//    // Not sure when to use this
//}

// Diese Erweiterung legt die Datenquelle einer Collection View fest
//extension ModalViewController: UICollectionViewDataSource {
//    // Wie viele Reihen?
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    // Wie viele Objekete soll es geben?
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return tasks.count * 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TagCell.self)", for: indexPath) as! TagCell
////            let category = tasks[indexPath.item]
////        cell.titleLabel.text= category
//
//
//
//        var index = indexPath.item
//        if index > tasks.count - 1 {
//            index -= tasks.count
//        }
//        cell.titleLabel.text = tasks[index % tasks.count]
//
//
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//        // if collection view scrolls vertically, use offset.y else comment below code
//        var offset = collectionView.contentOffset
//        let height = collectionView.contentSize.height
//        if offset.y < height/4 {
//            offset.y += height/2
//            collectionView.setContentOffset(offset, animated: false)
//        } else if offset.y > height/4 * 3 {
//            offset.y -= height/2
//            collectionView.setContentOffset(offset, animated: false)
//        }
//
//        // if collection view scrolls horizontally, use offset.x else comment below line of code
//        // In my case the collectionview scrolls vertically this I am commenting below line of code
//        //        let width = collectionView.contentSize.width
//        //        if offset.x < width/4 {
//        //            offset.x += width/2
//        //            collectionView.setContentOffset(offset, animated: false)
//        //        } else if offset.x > width/4 * 3 {
//        //            offset.x -= width/2
//        //            collectionView.setContentOffset(offset, animated: false)
//        //        }
//    }
//}


//extension ModalViewController: UICollectionViewDelegateFlowLayout {
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
////                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        return CGSize(width: 150, height: 75)
////    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
//        let pageInt = Int(round(pageFloat))
//
//        switch pageInt {
//        case 0:
//            taskCollectionView.scrollToItem(at: [0, 3], at: .left, animated: false)
//        case tasks.count - 1:
//            taskCollectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
//        default:
//            break
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.taskCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
//    }
//
//}









//
//class TagCell: UICollectionViewCell {
//
//    var titleLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(titleLabel)
//
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
//        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 20).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
//
//        contentView.backgroundColor = UIColor.cyan
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func systemLayoutSizeFitting(_ targetSize: CGSize,
//                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
//                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
//
//        guard let leftConstraintConstant = titleLabel.findConstraint(layoutAttribute: .left)?.constant,
//              let rightConstraintConstant = titleLabel.findConstraint(layoutAttribute: .left)?.constant else {
//            return CGSize(width: titleLabel.intrinsicContentSize.width, height: titleLabel.intrinsicContentSize.height)
//        }
//
//        let width = titleLabel.intrinsicContentSize.width + leftConstraintConstant + rightConstraintConstant
//
//        return CGSize(width: width, height: 50)
//    }
//
//}
//
//extension UIView {
//    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
//        if let constraints = superview?.constraints {
//            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
//                return constraint
//            }
//        }
//        return nil
//    }
//
//    func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
//        if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView {
//            let firstItemMatch = firstItem == self && constraint.firstAttribute == layoutAttribute
//            let secondItemMatch = secondItem == self && constraint.secondAttribute == layoutAttribute
//            return firstItemMatch || secondItemMatch
//        }
//        return false
//    }
//}
//
//
//
//
















//
//
//
//
//class FreelancerCell: UICollectionViewCell {
//
//    override var reuseIdentifier: String? {
//        "\(FreelancerCell.self)"
//    }
//
//
//    let profileImageButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 18
//        button.clipsToBounds = true
//        button.setImage(UIImage(named: "Profile"), for: .normal)
//
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkGray
//        label.text = "Bob Lee"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//
//    let distanceLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "30000 miles"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    let pricePerHourLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.darkGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "$40/hour"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//
//
//    let ratingLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "4.9+"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//
//    let showCaseImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.white
//        imageView.image = UIImage(named: "Profile")
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//
//    let likesLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "424 likes"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//
//    let topSeparatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.darkGray
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    let bottomSeparatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.darkGray
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//
//    let likeButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Like", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
//        button.setTitleColor(UIColor.darkGray, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    let hireButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Hire", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
//        button.setTitleColor(UIColor.darkGray, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//
//    let messageButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Message", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
//        button.setTitleColor(UIColor.darkGray, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//
//
//    let stackView: UIStackView = {
//        let sv = UIStackView()
//        sv.axis  = NSLayoutConstraint.Axis.horizontal
//        sv.alignment = UIStackView.Alignment.center
//        sv.distribution = UIStackView.Distribution.fillEqually
//        sv.translatesAutoresizingMaskIntoConstraints = false;
//        return sv
//    }()
//
//
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addViews()
//    }
//
//
//
//
//    func addViews(){
//        backgroundColor = UIColor.black
//
//        addSubview(profileImageButton)
//        addSubview(nameLabel)
//        addSubview(distanceLabel)
//        addSubview(pricePerHourLabel)
//        addSubview(ratingLabel)
//        addSubview(showCaseImageView)
//        addSubview(likesLabel)
//
//        addSubview(topSeparatorView)
//        addSubview(bottomSeparatorView)
//
//        // Stack View
//        addSubview(likeButton)
//        addSubview(messageButton)
//        addSubview(hireButton)
//        addSubview(stackView)
//
//
//        profileImageButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
//        profileImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
//        profileImageButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
//        profileImageButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
//
//        nameLabel.leftAnchor.constraint(equalTo: profileImageButton.rightAnchor, constant: 5).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor, constant: -8).isActive = true
//        nameLabel.rightAnchor.constraint(equalTo: pricePerHourLabel.leftAnchor).isActive = true
//
//        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
//        distanceLabel.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor, constant: 8).isActive = true
//        distanceLabel.widthAnchor.constraint(equalToConstant: 300)
//
//        pricePerHourLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
//        pricePerHourLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
//
//        // Distance depeneded on the priceLabel and distance Label
//        ratingLabel.rightAnchor.constraint(equalTo: pricePerHourLabel.rightAnchor).isActive = true
//        ratingLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
//
//        showCaseImageView.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 10).isActive = true
//        showCaseImageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        showCaseImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20).isActive = true
//
//        likesLabel.topAnchor.constraint(equalTo: showCaseImageView.bottomAnchor, constant: 10).isActive = true
//        likesLabel.leftAnchor.constraint(equalTo: profileImageButton.leftAnchor).isActive = true
//
//        topSeparatorView.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 10).isActive = true
//        topSeparatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//
//        stackView.addArrangedSubview(likeButton)
//        stackView.addArrangedSubview(hireButton)
//        stackView.addArrangedSubview(messageButton)
//
//        stackView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 4).isActive = true
//        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//
//        bottomSeparatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4).isActive = true
//        bottomSeparatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//
//
//    }
//
//
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
//
//
////
////
////class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
////
////    let list = [ #colorLiteral(red: 0.5843137255, green: 0.8823529412, blue: 0.8274509804, alpha: 1) ,#colorLiteral(red: 0.9529411765, green: 0.5058823529, blue: 0.5058823529, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.8901960784, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.5843137255, green: 0.8823529412, blue: 0.8274509804, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.5058823529, blue: 0.5058823529, alpha: 1)]
////    @IBOutlet weak var collectionView: UICollectionView!
////
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return list.count
////    }
////
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
////        cell.contentView.backgroundColor = list[indexPath.row]
////        return cell
////    }
////
////
////
////}
