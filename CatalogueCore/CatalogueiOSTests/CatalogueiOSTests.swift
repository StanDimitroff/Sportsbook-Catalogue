//
//  CatalogueiOSTests.swift
//  CatalogueiOSTests
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import XCTest

final class SportsViewController {

  init(loader: SportsLoaderSpy) {

  }
}

final class CatalogueiOSTests: XCTestCase {

  func test_init_doesNotLoadSports() {
    let loader = SportsLoaderSpy()
    let _ = SportsViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }
}

class SportsLoaderSpy {
  var loadCallCount: Int = 0
}
