//
//  ViewController.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit
import Combine
import Kingfisher


protocol TableDisplayStrategy {
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    func heightForHeader(in section: Int) -> CGFloat
    func viewForHeader(in section: Int) -> UIView?
}

//MARK: - ListModeStrategy

final class ListModeStrategy: TableDisplayStrategy {
    private let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return viewModel.extractItems.count
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListTVCell.identifier
        ) as? ListTVCell else {
            return UITableViewCell()
        }
        
        let sectionItem = viewModel.extractItems[indexPath.row]
        cell.configure(sectionItem)
        
        return cell
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func heightForHeader(in section: Int) -> CGFloat {
        return 0
    }

    func viewForHeader(in section: Int) -> UIView? {
        return nil
    }
}


//MARK: - SectionModeStrategy


final class SectionModeStrategy: TableDisplayStrategy {
    
    private let viewModel: MainViewModel
    private let isPremium: Bool
    
    init(viewModel: MainViewModel, isPremium: Bool) {
        self.viewModel = viewModel
        self.isPremium = isPremium
    }

    func numberOfSections() -> Int {
        return viewModel.tableViewSections.count
    }

    func numberOfRows(in section: Int) -> Int {
        
        switch viewModel.tableViewSections[section] {
        case .horizontalCV(_):
            return 1
        case .chatsList(let items):
            return items.isEmpty ? 1 : items.count
        }
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        
        switch viewModel.tableViewSections[indexPath.section] {
            
        case .horizontalCV(let items):
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HorizontalTVCell.id
            ) as? HorizontalTVCell else {
                return UITableViewCell()
            }
            cell.configure(with: items, isPremium: isPremium)
            return cell
            
        case .chatsList(let items):
            
            if items.isEmpty {
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatListPlaceholderTVCell.id
                ) as? ChatListPlaceholderTVCell else {
                    return UITableViewCell()
                }
                return cell
                
            } else {
                let cell = UITableViewCell()
                cell.backgroundColor = .mainAccent
                return cell
            }
        }
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        switch viewModel.tableViewSections[indexPath.section] {
        case .horizontalCV(_): return 407 + 32 + 10
        case .chatsList(let items): return items.isEmpty ? 232 : 76
        }
    }

    func heightForHeader(in section: Int) -> CGFloat {
        switch viewModel.tableViewSections[section] {
        case .horizontalCV(_): return 0
        case .chatsList(_): return 64
        }
    }

    func viewForHeader(in section: Int) -> UIView? {
        switch viewModel.tableViewSections[section] {
        case .horizontalCV(_): return nil
        case .chatsList(_): return ChatListSectionHeader()
        }
    }
}



final class MainViewController: UIViewController {
    // MARK: - Properties
    @Published var isPremium: Bool = false

    private let viewModel: MainViewModel
    private let preferences: Preferences
    private var router: MainRouter?

    private var tableDisplayStrategy: TableDisplayStrategy

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .bg
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.bottom = 62
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.register(HorizontalTVCell.self, forCellReuseIdentifier: HorizontalTVCell.id)
        tableView.register(ChatListPlaceholderTVCell.self, forCellReuseIdentifier: ChatListPlaceholderTVCell.id)
        tableView.register(ListTVCell.self, forCellReuseIdentifier: ListTVCell.identifier)
        return tableView
    }()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(viewModel: MainViewModel, preferences: Preferences) {
        self.viewModel = viewModel
        self.preferences = preferences
        self.tableDisplayStrategy = preferences.isListModeEnabled
            ? ListModeStrategy(viewModel: viewModel)
        : SectionModeStrategy(viewModel: viewModel, isPremium: false)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bg

        setTVDelegate()
        setupTVConstraints()
        setupBindings()
        viewModel.fetchAssistants()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "App Name"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setColor(backgroud: .bg, hideLine: true)
        navigationItem.rightBarButtonItem = setupRightBarButtom(isListMode: preferences.isListModeEnabled)
    }

    // MARK: - Private Methods

    private func setupTVConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setTVDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupRightBarButtom(isListMode: Bool) -> UIBarButtonItem {
        UIBarButtonItem(
            image: isListMode ? .categoryList : .category,
            target: self,
            action: #selector(didTapAdd)
        )
    }

    @objc private func didTapAdd() {
        preferences.isListModeEnabled.toggle()
        updateTableDisplayStrategy()
        navigationItem.rightBarButtonItem = setupRightBarButtom(isListMode: preferences.isListModeEnabled)
    }

    private func updateTableDisplayStrategy() {
        tableDisplayStrategy = preferences.isListModeEnabled
            ? ListModeStrategy(viewModel: viewModel)
            : SectionModeStrategy(viewModel: viewModel, isPremium: isPremium)
        tableView.reloadData()
    }

    private func setupBindings() {
        viewModel.$tableViewSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)

        $isPremium
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)

        preferences.$isListModeEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTableDisplayStrategy()
            }.store(in: &cancellables)
    }
    
    func configure(router: MainRouter) {
           self.router = router
       }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableDisplayStrategy.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDisplayStrategy.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableDisplayStrategy.cellForRow(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableDisplayStrategy.heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableDisplayStrategy.heightForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableDisplayStrategy.viewForHeader(in: section)
    }
}



//MARK: - SelectItemDelegate


extension MainViewController: SelectItemDelegate {
    func collectionTableViewCell(didSelectItem model: CollectionCellConfig) {
        //TODO: handle selection cell
        router?.presentChatView()
        print("Selected item from collection: \(model)")
    }
}




#if DEBUG
@available(iOS 17.0, *)
#Preview {
    TabBarController()
}
#endif



