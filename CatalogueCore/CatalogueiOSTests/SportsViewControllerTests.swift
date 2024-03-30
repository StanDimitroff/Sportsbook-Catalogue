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
    let (_, loader) = makeSUT()

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsSports() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()

    let exp = expectation(description: "Wait for load completion")

    loader.complete {
      exp.fulfill()

      XCTAssertEqual(loader.loadCallCount, 1)
    }

    wait(for: [exp], timeout: 1.0)
  }

  func test_loadSports_rendersNoSportsOnLoaderError() {
    let (sut, loader) = makeSUT()
    let exp = expectation(description: "Wait for load completion")

    sut.loadViewIfNeeded()

    loader.completeWithError {
      exp.fulfill()

      let renderedCells = sut.tableView.numberOfRows(inSection: 0)

      XCTAssertEqual(renderedCells, 0)
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func makeSUT() -> (SportsViewController, SportsLoaderSpy) {
    let loader = SportsLoaderSpy()
    let sut = SportsViewController(loader: loader)

    return (sut, loader)
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
        DispatchQueue.main.async {
          completion()
        }
      }
    }

    func completeWithError(completion: @escaping () -> Void) {
      responseContinuation.yield(.failure(NSError(domain: "SportsLoader", code: 0)))
      responseContinuation.onTermination = { _ in
        DispatchQueue.main.async {
          completion()
        }
      }
    }
  }
}
