//
//  Coordinator.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 1.04.24.
//

import Foundation
import UIKit
import CatalogueCore

protocol Coordinator {
  var navigationController: UINavigationController { get set }

  func start()
}

public class MainCoordinator: Coordinator {
  var navigationController: UINavigationController

  public init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  public func start() {
    var urlRequest = URLRequest(url: URL(string: "http://localhost:8080/sports")!)
    urlRequest.setValue("Bearer ewogICAibmFtZSI6ICJHdWVzdCIKfQ==", forHTTPHeaderField: "Authorization")
    let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSportsLoader(request: urlRequest, client: client)

    let bundle = Bundle(for: SportsViewController.self)
    let storyboard = UIStoryboard(name: "Catalogue", bundle: bundle)
    let sportsViewController = storyboard.instantiateViewController(
      identifier: String.init(describing: SportsViewController.self)
    ) { coder in
      return SportsViewController(coder: coder, loader: loader)
    }

    sportsViewController.coordinator = self

    navigationController.pushViewController(sportsViewController, animated: false)
  }

  func goToSportEvents(for sport: Sport) {
    var urlRequest = URLRequest(url: URL(string: "http://localhost:8080/sports/\(sport.id)/events")!)
    urlRequest.setValue("Bearer ewogICAibmFtZSI6ICJHdWVzdCIKfQ==", forHTTPHeaderField: "Authorization")
    let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSportEventsLoader(request: urlRequest, client: client)

    let bundle = Bundle(for: SportEventsViewController.self)
    let storyboard = UIStoryboard(name: "Catalogue", bundle: bundle)
    let sportEventsViewController = storyboard.instantiateViewController(
      identifier: String.init(describing: SportEventsViewController.self)
    ) { coder in
      return SportEventsViewController(coder: coder, loader: loader)
    }

    sportEventsViewController.title = sport.name

    navigationController.pushViewController(sportEventsViewController, animated: true)
  }
}
