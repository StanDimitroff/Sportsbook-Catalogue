//
//  LoadSportsEndToEndTests.swift
//  CatalogueCoreTests
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import XCTest
import CatalogueCore

final class LoadSportsEndToEndTests: XCTestCase {

  func test_endToEndTestServerGETSportsResult_matchesFixedTestData() async {
    let testServerURL = URL(string: "http://localhost:8080/sports")!
    let expectedSports = [Sport(id: 1, name: "Football"), Sport(id: 1477, name: "Rugby League")]

    var urlRequest = URLRequest(url: testServerURL)
    urlRequest.setValue("Bearer ewogICAibmFtZSI6ICJHdWVzdCIKfQ==", forHTTPHeaderField: "Authorization")
    let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSportsLoader(request: urlRequest, client: client)

    let receivedResult: LoadSportsResult = await loader.load()

    switch receivedResult {
    case let .success(receivedSports):
      XCTAssertFalse(receivedSports.isEmpty, "Expected sports to not be empty in the test catalogue.")
      XCTAssertEqual(receivedSports, expectedSports)
    case let .failure(error):
      XCTFail("Expected successful sports result, got \(error) instead.")
    }
  }
}
