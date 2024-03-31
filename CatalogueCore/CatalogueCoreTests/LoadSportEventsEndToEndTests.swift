//
//  LoadSportEventsEndToEndTests.swift
//  CatalogueCoreTests
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import XCTest
import CatalogueCore

final class LoadSportEventsEndToEndTests: XCTestCase {

  func test_endToEndTestServerGETSportEventsResult_matchesFixedTestData() async {
    let testServerURL = URL(string: "http://localhost:8080/sports/1/events")!

    var urlRequest = URLRequest(url: testServerURL)
    urlRequest.setValue("Bearer ewogICAibmFtZSI6ICJHdWVzdCIKfQ==", forHTTPHeaderField: "Authorization")
    let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSportEventsLoader(request: urlRequest, client: client)

    let receivedResult: LoadSportEventsResult = await loader.load()

    switch receivedResult {
    case let .success(receivedSports):
      XCTAssertFalse(receivedSports.isEmpty, "Expected sport events to not be empty in the test catalogue.")
    case let .failure(error):
      XCTFail("Expected successful sport events result, got \(error) instead.")
    }
  }
}
