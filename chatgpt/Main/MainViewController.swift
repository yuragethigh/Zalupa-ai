//
//  ViewController.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit
import Combine
import Kingfisher


final class MainViewController: UIViewController {
    
    //MARK: - MOCK
    @Published var isPremium: Bool = false
    
    //MARK: - inits
    private let viewModel: MainViewModel
    private let preferences: Preferences
    private var router: MainRouter?
    
    init(viewModel: MainViewModel, preferences: Preferences) {
        self.viewModel = viewModel
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: - View variables
    
    private var cancellables: Set<AnyCancellable> = []

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
            forCellReuseIdentifier: HorizontalTVCell.id
        )
        tableView.register(
            ChatListPlaceholderTVCell.self,
            forCellReuseIdentifier: ChatListPlaceholderTVCell.id
        )
        tableView.register(
            ListTVCell.self,
            forCellReuseIdentifier: ListTVCell.identifier
        )
        return tableView
    }()
    
    private func setupRightBarButtom(isListMode: Bool) -> UIBarButtonItem {
        UIBarButtonItem(
            image: isListMode ? .categoryList : .category,
            target: self,
            action: #selector(didTapAdd)
        )
    }
    
    @objc private func didTapAdd() {
        preferences.isListModeEnabled.toggle()
        navigationItem.rightBarButtonItem = setupRightBarButtom(isListMode: preferences.isListModeEnabled)
    }

    
    // MARK: - View lifecycle
    
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
    
    // MARK: - Private methods
    
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
    
    private func setupBindings() {
        viewModel.$tableViewSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
        
        $isPremium
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                
            }.store(in: &cancellables)
        
        preferences.$isListModeEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
               
            }.store(in: &cancellables)
    }
    
    // MARK: - Public methods
    
    func configure(router: MainRouter) {
        self.router = router
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - UITableViewDelegate / UITableViewDataSource

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.isListModeEnabled ? 1 : viewModel.tableViewSections.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        if preferences.isListModeEnabled {
            return viewModel.extractItems.count
            
        } else {
            
            switch viewModel.tableViewSections[section] {
                
            case .horizontalCV(_):
                return 1
                
            case .chatsList(let items):
                return items.isEmpty ? 1 : items.count
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if preferences.isListModeEnabled {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTVCell.identifier
            ) as? ListTVCell else {
                return UITableViewCell()
            }
            let items = viewModel.extractItems
            let sectionItem = items[indexPath.row]
            cell.configure(sectionItem)
            
            return cell
        } else {
            
            switch viewModel.tableViewSections[indexPath.section] {
                
            case .horizontalCV(let items):
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: HorizontalTVCell.id
                ) as? HorizontalTVCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
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
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        if preferences.isListModeEnabled {
            return 76
        } else {
            switch viewModel.tableViewSections[indexPath.section] {
            case .horizontalCV(_):
                //MARK: - 407: Cell height + 32 bottom padding + 10 top padding
                return 407 + 32 + 10
            case .chatsList(let items):
                return items.isEmpty ? 232 : 76
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        
        if preferences.isListModeEnabled {
            return 0
        } else {
            switch viewModel.tableViewSections[section] {
            case .horizontalCV(_):
                return 0
            case .chatsList(_):
                return 64
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        if preferences.isListModeEnabled {
            return nil
        } else {
            switch viewModel.tableViewSections[section] {
            case .horizontalCV(_):
                return nil
            case .chatsList(_):
                return ChatListSectionHeader()
            }
        }
    }
}



//MARK: - SelectItemDelegate


extension MainViewController: SelectItemDelegate {
    func collectionTableViewCell(_ cell: HorizontalTVCell, didSelectItem model: any CollectionCellConfig) {
        //TODO: handle selection cell
        router?.presentChatView()
        print("Selected item from collection: \(model), \(cell)")
    }
}




#if DEBUG
@available(iOS 17.0, *)
#Preview {
    TabBarController()
}
#endif



final class ListTVCell: UITableViewCell {
    
    static let identifier = String(describing: ListTVCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        setupConstraints()
    }
    
    //MARK: - Private variables
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .SFProText(weight: .semibold, size: 17)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.font = .SFProText(weight: .regular, size: 15)
        subTitleLabel.textColor = .textSecondary
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subTitleLabel
    }()
    
    private let chvronImageView: UIImageView = {
        let chvronImageView = UIImageView()
        chvronImageView.image = .chevroneRight
        chvronImageView.translatesAutoresizingMaskIntoConstraints = false
        return chvronImageView
    }()
    
    private let devider: UIView = {
        let devider = UIView()
        devider.backgroundColor = .topStroke
        devider.translatesAutoresizingMaskIntoConstraints = false
        return devider
    }()
    
    
    //MARK: - Private methods
    
    private func setupConstraints() {
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chvronImageView)
//        contentView.addSubview(subTitleLabel)
        
        contentView.addSubview(devider)
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 45),
            logoImageView.widthAnchor.constraint(equalToConstant: 45),
            
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

            chvronImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            chvronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            devider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            devider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            devider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 83),
            devider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    
    //MARK: - Public methods
    
    func configure(_ items: CollectionCellConfig) {
        self.logoImageView.kf.setImage(with: items.imageAvatar)
        self.titleLabel.text = items.title
        self.subTitleLabel.text = items.description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
