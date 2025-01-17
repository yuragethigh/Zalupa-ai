//
//  ViewController.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit
import Combine


final class MainViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: MainViewModel
    private let preferences: Preferences
    private var router: MainRouter?

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .bg
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.bottom = 62
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.register(
            HorizontalTVCell.self,
            forCellReuseIdentifier: HorizontalTVCell.identifier
        )
        tableView.register(
            ChatHistoryTVCell.self,
            forCellReuseIdentifier: ChatHistoryTVCell.identifier
        )
        tableView.register(
            ChatHistoryPlaceholderTVCell.self,
            forCellReuseIdentifier: ChatHistoryPlaceholderTVCell.identifier
        )
        tableView.register(
            ListModeTVCell.self,
            forCellReuseIdentifier: ListModeTVCell.identifier
        )
        return tableView
    }()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(viewModel: MainViewModel, preferences: Preferences) {
        self.viewModel = viewModel
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bg

        setupTVDelegate()
        setupTVConstraints()
        setupBindings()
        viewModel.fetchAssistants()
        
        //MOCK:
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewModel.updateHistoryChats(mock)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "App Name"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setColor(backgroud: .bg, hideLine: true)
        navigationItem.rightBarButtonItem = setupRightBarButtom(
            isListMode: preferences.isListModeEnabled
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .account, target: self, action: #selector(test))
    }
    
    @objc private func test() {
        preferences.isPremiumEnabled.toggle()
    }

    // MARK: - Private Methods

    private func setupRightBarButtom(isListMode: Bool) -> UIBarButtonItem {
        UIBarButtonItem(
            image: isListMode ? .categoryList : .category,
            target: self,
            action: #selector(didTapRightBarButtot)
        )
    }

    @objc private func didTapRightBarButtot() {
        preferences.isListModeEnabled.toggle()
        navigationItem.rightBarButtonItem = setupRightBarButtom(
            isListMode: preferences.isListModeEnabled
        )
    }
    
    private var tableDisplayStrategy: TableDisplayStrategy {
        preferences.isListModeEnabled ?
        
        ListModeStrategy(
            assistans: viewModel.assistants[.list] ?? [],
            isPremium: preferences.isPremiumEnabled,
            selectItemDelegate: self
        )
        
        :
        
        SectionModeStrategy(
            assistans: viewModel.assistants[.pager] ?? [],
            historyChats: viewModel.historyChats,
            isPremium: preferences.isPremiumEnabled,
            selectItemDelegate: self
        )
    }

    private func setupBindings() {
        
        viewModel.$assistants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let section = IndexSet(integer: 0)
                tableView.reloadSections(section, with: .fade)

            }.store(in: &cancellables)
        
        viewModel.$historyChats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self, !preferences.isListModeEnabled else { return }
                let section = IndexSet(integer: 1)
                tableView.reloadSections(section, with: .fade)
            }.store(in: &cancellables)
        
        preferences.$isPremiumEnabled
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] val in
                guard let self else { return }
                let section = IndexSet(integer: 0)
                tableView.reloadSections(section, with: .fade)
            }.store(in: &cancellables)

        preferences.$isListModeEnabled
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                tableView.reloadData()
            }.store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func configure(router: MainRouter) {
        self.router = router
    }
}




// MARK: - UITableViewDataSource / UITableViewDelegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableDisplayStrategy.numberOfSections()
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
            
        return tableDisplayStrategy.numberOfRows(in: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        return tableDisplayStrategy.cellForRow(at: indexPath, in: tableView)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return tableDisplayStrategy.heightForRow(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        
        return tableDisplayStrategy.heightForHeader(in: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        
        return tableDisplayStrategy.viewForHeader(in: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        tableDisplayStrategy.didSelectRow(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        
        return tableDisplayStrategy.canEditRow(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        return tableDisplayStrategy.trailingSwipeActionsConfiguration(
            forRowAt: indexPath,
            in: tableView
        ) { [weak self] indexPath, confirmed  in
            self?.presentDeleteConfirmation(
                at: indexPath,
                completionHandler: confirmed
            )
        }
    }
    
    private func presentDeleteConfirmation(
        at indexPath: IndexPath,
        completionHandler: @escaping (Bool) -> Void
    ) {
        
        let alert = alertController(
            title: nil,
            message: "Этот чат будет удалён.",
            preferredStyle: .actionSheet
        ) { [weak self] completion in
            
            completionHandler(completion)
            
            if completion {
                self?.viewModel.removeHistoryChat(indexPath.row)
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
}



//MARK: - SelectItemDelegate

extension MainViewController: SelectItemDelegate {
    func collectionTableViewCell(didSelectItem model: AssistantsConfiguration) {
        //TODO: handle selection cell
        
//        preferences.isPremiumEnabled.toggle()
//        print(model.name, model.backgroundColor)

        if model.freeAssistant || preferences.isPremiumEnabled {
            router?.presentChatView()
            print("Selected item from collection: \(model)")
        } else {
            //TODO: handle is not premium model
        }
    }
}


//MARK: - Setup TV Constraints

private extension MainViewController {
    
    private func setupTVConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTVDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}



#if DEBUG
@available(iOS 17.0, *)
#Preview {
    TabBarController()
}
#endif



