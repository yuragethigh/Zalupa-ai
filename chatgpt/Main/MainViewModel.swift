//
//  MainViewModel.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import Foundation
import Combine

final class MainViewModel {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    @Published private(set) var tableViewSections: [MainTVSection] = [
        .horizontalCV([]),
        .chatsList([])
    ]
    
    func fetchAssistants() {
        networkService.request(
            decodedType: [CollectionCellModel].self,
            endPoint: .assistants
        )
        .sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                //TODO: Handle errors
                print(error)
            }
        } receiveValue: { [weak self] responseModel in
            guard let self else { return }
            tableViewSections = self.tableViewSections.map { section in
                switch section {
                case .horizontalCV:
                    return .horizontalCV(responseModel)
                default:
                    return section
                }
            }
        }.store(in: &cancellables)
    }
    
    var extractItems: [CollectionCellConfig] {
        tableViewSections.compactMap {
            if case .horizontalCV(let items) = $0 {
                return items
            }
            return nil
        }.flatMap { $0 }
    }

}

