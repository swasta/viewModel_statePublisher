//
//  Created by Nikita Borodulin on 27.07.2022.
//

import Combine
import XCTest
@testable import ViewModelTest

final class SomeViewModel: ObservableViewModel {

    struct State {
        let value: Int
    }

    enum Action {
        case update
    }

    @Published private(set) var state: State = .init(value: 1)

    func handle(_ action: Action) {
        switch action {
            case .update:
                state = .init(value: 2)
        }
    }
}

final class ViewModelTestTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    func testDelayedAction() throws {
        let viewModel = SomeViewModel()

        let expectation = expectation(description: "waiting")
        expectation.expectedFulfillmentCount = 2

        var responses: [(oldState: SomeViewModel.State, newState: SomeViewModel.State)] = []

        viewModel.statePublisher
            .sink { oldState, newState in
                responses.append((oldState, newState))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.handle(.update)
        }

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(responses.count, 2)

        XCTAssertEqual(responses[0].oldState.value, 1)
        XCTAssertEqual(responses[0].newState.value, 1)

        XCTAssertEqual(responses[1].oldState.value, 1)
        XCTAssertEqual(responses[1].newState.value, 2)
    }

    func testImmediateAction() {
        let viewModel = SomeViewModel()

        let expectation = expectation(description: "waiting")
        expectation.expectedFulfillmentCount = 2

        var responses: [(oldState: SomeViewModel.State, newState: SomeViewModel.State)] = []

        viewModel.statePublisher
            .sink { oldState, newState in
                responses.append((oldState, newState))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.handle(.update)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(responses.count, 2)

        XCTAssertEqual(responses[0].oldState.value, 1)
        XCTAssertEqual(responses[0].newState.value, 1)

        XCTAssertEqual(responses[1].oldState.value, 1)
        XCTAssertEqual(responses[1].newState.value, 2)
    }
}
