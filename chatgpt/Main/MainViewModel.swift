//
//  MainViewModel.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import Foundation
import Combine
import UIKit

final class MainViewModel {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    @Published private(set) var historyChats = [HistoryChatConfiguration]()
    @Published private(set) var assistants = [AssistanceTypes: [AssistantsConfiguration]]()
    
    func fetchAssistants() {
        networkService.request(
            decodedType: [AssistansModel].self,
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
            updateAssistants(responseModel)
        }.store(in: &cancellables)
    }
}

extension MainViewModel {
    func updateHistoryChats(_ items: [HistoryChatConfiguration]) {
        self.historyChats = items
    }
    
    func updateAssistants(_ items: [AssistantsConfiguration]) {
        let assistansWithoutFirst = Array(items.dropFirst())
        assistants[.pager] = assistansWithoutFirst
        assistants[.list] = items
    }
    
    func removeHistoryChat(_ item: Int) {
        self.historyChats.remove(at: item)
    }
}

enum AssistanceTypes: String {
    case pager, list
}


struct HistoryCellModeLive: HistoryChatConfiguration {
    let image: UIImage
    let title: String
    let subtitle: String
}

let mock = [
    HistoryCellModeLive(
        image: .m1,
        title: "Title",
        subtitle: "Subtitle"
    ),
    
    HistoryCellModeLive(
        image: .m2,
        title: "Title",
        subtitle: "Subtitle"
    ),
    
    HistoryCellModeLive(
        image: .m3,
        title: "Title",
        subtitle: "Subtitle"
    ),
]

