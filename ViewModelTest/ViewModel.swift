//
//  Created by Nikita Borodulin on 27.07.2022.
//

import Foundation
import Combine

public protocol ViewModel {

    associatedtype State
    associatedtype Action

    var state: State { get }

    func handle(_ action: Action)
}

public protocol ObservableViewModel: ViewModel, ObservableObject {}

public extension ObservableViewModel {

    var statePublisher: AnyPublisher<(old: State, new: State), Never> {
        var initialState: State?
        return objectWillChange
            .map { _ in self.state }
            .prepend(state)
            .map { initialState = initialState ?? $0 }
            .receive(on: DispatchQueue.main)
            .compactMap { _ in
                if let old = initialState {
                    initialState = nil
                    return (old: old, new: self.state)
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
}
