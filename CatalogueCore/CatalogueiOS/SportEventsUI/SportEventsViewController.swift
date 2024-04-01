//
//  SportEventsViewController.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import UIKit
import CatalogueCore

final class SportEventsViewController: UITableViewController {

  private var loader: SportEventsLoader?
  private var sportEvents: [SportEvent] = []

  public init?(coder: NSCoder, loader: SportEventsLoader) {
    self.loader = loader
    super.init(coder: coder)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    Task {
      let result = await loader?.load()
      sportEvents = (try? result?.get()) ?? []
      tableView.reloadData()
    }
  }

  public override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sportEvents.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let sportEvent = sportEvents[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "SportEventCell", for: indexPath) as! SportEventCell
    cell.marketLabel.text = sportEvent.primaryMarket.name
    cell.matchLabel.text = sportEvent.name
    return cell
  }
}
