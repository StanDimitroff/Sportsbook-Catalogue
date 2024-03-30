//
//  SportsViewControllerTests.swift
//  SportsViewControllerTests
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import XCTest
import CatalogueCore
import CatalogueiOS

final class SportsViewControllerTests: XCTestCase {

  func test_init_doesNotLoadSports() {
    let loader = SportsLoaderSpy()
    let _ = SportsViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsSports() {
    let loader = SportsLoaderSpy()
    let sut = SportsViewController(loader: loader)

    sut.loadViewIfNeeded()

    let exp = expectation(description: "Wait for load completion")

    loader.complete {
      exp.fulfill()

      XCTAssertEqual(loader.loadCallCount, 1)
    }

    wait(for: [exp], timeout: 1.0)
  }
}

private class SportsLoaderSpy: SportsLoader {
  private(set) var loadCallCount: Int = 0

  private let responseContinuation: AsyncStream<Result<[Sport], Error>>.Continuation
  private let responseStream: AsyncStream<Result<[Sport], Error>>

  init() {
    var responseContinuation: AsyncStream<Result<[Sport], Error>>.Continuation!
    self.responseStream = AsyncStream { responseContinuation = $0 }
    self.responseContinuation = responseContinuation
  }

  func load() async -> LoadSportsResult {
    loadCallCount += 1

    let result = await responseStream.first(where: { _ in true })!
    responseContinuation.finish()

    return result
  }

  func complete(with items: [Sport] = [], completion: @escaping () -> Void) {
    responseContinuation.yield(.success(items))
    responseContinuation.onTermination = { _ in
      completion()
    }
  }
}
