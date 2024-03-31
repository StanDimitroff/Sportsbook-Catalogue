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
    let exp = expectation(description: "Wait for load completion")

    sut.loadViewIfNeeded()

    loader.complete {
      exp.fulfill()
      XCTAssertEqual(loader.loadCallCount, 1)
    }

    wait(for: [exp], timeout: 2.0)
  }

  func test_loadSports_rendersNoSportsOnLoaderError() {
    let (sut, loader) = makeSUT()
    let exp = expectation(description: "Wait for load completion")

    sut.loadViewIfNeeded()

    loader.complete(with: NSError(domain: "SportsLoader", code: 0)) {
      exp.fulfill()
      XCTAssertEqual(sut.numberOfRenderedSports(), 0)
    }

    wait(for: [exp], timeout: 2.0)
  }

  func test_loadSports_rendersNoSportsOnEmptySportsList() {
    let (sut, loader) = makeSUT()
    let exp = expectation(description: "Wait for load completion")

    sut.loadViewIfNeeded()

    loader.complete {
      exp.fulfill()
      XCTAssertEqual(sut.numberOfRenderedSports(), 0)
    }

    wait(for: [exp], timeout: 2.0)
  }

  func test_loadSports_rendersSportsOnNonEmptySportsList() {
    let (sut, loader) = makeSUT()

    let exp = expectation(description: "Wait for load completion")
    let expectedSports = [Sport(id: 1, name: "Football"), Sport(id: 2, name: "Rugby")]

    sut.loadViewIfNeeded()
    loader.complete(with: expectedSports) {
      exp.fulfill()
      XCTAssertEqual(sut.numberOfRenderedSports(), expectedSports.count)

      expectedSports.enumerated().forEach { index, sport in
        let cell = sut.cell(for: index)

        guard let cell = cell as? SportCell else {
          return XCTFail("Expected \(SportCell.self) instance, got \(String(describing: cell)) instead")
        }

        XCTAssertEqual(cell.name, sport.name)
      }
    }
    
    wait(for: [exp], timeout: 2.0)
  }

  // MARK: - Helpers
  private func makeSUT() -> (SportsViewController, SportsLoaderSpy) {
    let loader = SportsLoaderSpy()
    let bundle = Bundle(for: SportsViewController.self)
    let storyboard = UIStoryboard(name: "Catalogue", bundle: bundle)
    let sut = storyboard.instantiateInitialViewController { coder in
      return SportsViewController(coder: coder, loader: loader)
    }!

    return (sut, loader)
  }

  private class SportsLoaderSpy: SportsLoader {

    private(set) var loadCallCount: Int = 0

    private let responseContinuation: AsyncStream<Result<[Sport], Error>>.Continuation
    private let responseStream: AsyncStream<Result<[Sport], Error>>

    private(set) var loadCompletion: (() -> Void)?

    init() {
      var responseContinuation: AsyncStream<Result<[Sport], Error>>.Continuation!
      self.responseStream = AsyncStream { responseContinuation = $0 }
      self.responseContinuation = responseContinuation

      self.responseContinuation.onTermination = { @Sendable _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.loadCompletion?()
        }
      }
    }

    func load() async -> LoadSportsResult {
      loadCallCount += 1

      let result = await responseStream.first(where: { _ in true })!
      responseContinuation.finish()

      return result
    }

    func complete(with sports: [Sport] = [], completion: @escaping (() -> Void)) {
      loadCompletion = completion
      responseContinuation.yield(.success(sports))
    }

    func complete(with error: Error, completion: @escaping (() -> Void)) {
      loadCompletion = completion
      responseContinuation.yield(.failure(error))
    }
  }
}

private extension SportsViewController {
  func numberOfRenderedSports() -> Int {
    tableView.numberOfRows(inSection: 0)
  }

  func cell(for row: Int) -> UITableViewCell? {
    let dataSource = tableView.dataSource
    let indexPath = IndexPath(row: row, section: 0)

    return dataSource?.tableView(tableView, cellForRowAt: indexPath)
  }
}

private extension SportCell {
  var name: String? {
    nameLabel.text
  }
}
