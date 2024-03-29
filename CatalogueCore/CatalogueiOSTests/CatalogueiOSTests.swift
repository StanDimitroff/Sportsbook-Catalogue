//
//  CatalogueiOSTests.swift
//  CatalogueiOSTests
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import XCTest

final class SportsViewController: UIViewController {

  private var loader: SportsLoaderSpy?

  convenience init(loader: SportsLoaderSpy) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loader?.load()
  }
}

final class CatalogueiOSTests: XCTestCase {

  func test_init_doesNotLoadSports() {
    let loader = SportsLoaderSpy()
    let _ = SportsViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsSports() {
    let loader = SportsLoaderSpy()
    let sut = SportsViewController(loader: loader)

    sut.loadViewIfNeeded()

    XCTAssertEqual(loader.loadCallCount, 1)
  }
}

class SportsLoaderSpy {
  var loadCallCount: Int = 0

  func load() {
    loadCallCount += 1
  }
}
