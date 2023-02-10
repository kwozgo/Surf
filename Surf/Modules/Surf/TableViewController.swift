import UIKit

protocol CanConfigureCell {
    func configure(with viewModels: [TagViewModel])
}

final class TableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let dataSource: [TagSectionViewModel] = TagDatabase.collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.recalculateHeaderViewHeight()
    }
    
    // MARK: - Private Helpers
    
    private func configureTableView() {
        configureTableDelegates()
        configureTableSectionHeader()
        configureTableCell()
        configureTableAppearence()
        configureTableHeader()
    }
    
    private func configureTableDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureTableSectionHeader() {
        tableView.estimatedSectionHeaderHeight = 42
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    private func configureTableCell() {
        tableView.estimatedRowHeight = 128
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerCell(for: "FlexibleAreaCell")
        tableView.registerCell(for: "HorizontalScrollCell")
    }
    
    private func configureTableAppearence() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
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
            return configureCell(for: indexPath, with: FlexibleAreaCell.self)
        case .adaptive:
            return configureCell(for: indexPath, with: HorizontalScrollCell.self)
        }
    }
    
    // MARK: - Private Helpers
    
    private func configureCell<CellType: CanConfigureCell & UITableViewCell>(
        for indexPath: IndexPath,
        with type: CellType.Type
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "\(type)",
                for: indexPath
            ) as? CellType
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
        let spaceBetweenSection: CGFloat = 24
        return spaceBetweenSection
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
