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

  convenience init(loader: SportEventsLoader) {
    self.init()
    self.loader = loader
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
}
