//
//  TabbarViewModel.swift
//  chatgpt
//
//  Created by Yuriy on 27.01.2025.
//

import Foundation
import Combine

final class TabbarViewModel {
    
    private let networkService: NetworkService
    var defaultAssistants: AssistantsConfiguration?
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        
        fetchAssistants()
    }
    
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
            defaultAssistants = responseModel.first
        }.store(in: &cancellables)
    }
}
