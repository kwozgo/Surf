import UIKit

final class TableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let sectionSpace: CGFloat = 24
    private let dataSource: [TagSectionViewModel] = TagDatabase.collection

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        tableView.isScrollEnabled = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.recalculateHeaderViewHeight()
    }

    // MARK: - Private Helpers

    // MARK: - Table Configuration Methods

    private func configureTableView() {
        configureTableDelegates()
        registerTableCells()
        configureTableSectionHeader()
        configureTableCell()
        configureTableAppearence()
        configureTableHeader()
    }

    private func configureTableDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func registerTableCells() {
        let flexibleCellNib = UINib(nibName: "FlexibleAreaCell", bundle: .main)
        tableView.register(flexibleCellNib, forCellReuseIdentifier: "FlexibleAreaCell")

        let horizontalCellNib = UINib(nibName: "HorizontalScrollCell", bundle: .main)
        tableView.register(horizontalCellNib, forCellReuseIdentifier: "HorizontalScrollCell")
    }

    private func configureTableSectionHeader() {
        tableView.estimatedSectionHeaderHeight = 42
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    private func configureTableCell() {
        tableView.estimatedRowHeight = 128
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func configureTableAppearence() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }

    private func configureTableHeader() {
        tableView.tableHeaderView = TagTableHeader()
    }
}

// MARK: - TableViewController+UITableViewDataSource

extension TableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDataSource = dataSource[indexPath.section]
        switch sectionDataSource.tag {
        case .loop:
            return configureFlexibleAreaCell(for: indexPath)
        case .adaptive:
            return configureHorizontalScrollCell(for: indexPath)
        }
    }

    // MARK: - Private Helpers

    private func configureFlexibleAreaCell(for indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "FlexibleAreaCell",
                for: indexPath
            ) as? FlexibleAreaCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: dataSource[indexPath.section].tags)
        cell.selectionStyle = .none
        return cell
    }

    private func configureHorizontalScrollCell(for indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "HorizontalScrollCell",
                for: indexPath
            ) as? HorizontalScrollCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: dataSource[indexPath.section].tags)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - TableViewController+UITableViewDelegate

extension TableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sectionSpace
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = TagSectionHeader()
        let sectionHeaderTitle = dataSource[section].title
        sectionHeader.setLabelText(sectionHeaderTitle)
        return sectionHeader
    }
}
