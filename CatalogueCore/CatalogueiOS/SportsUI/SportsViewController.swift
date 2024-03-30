//
//  SportsViewController.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 30.03.24.
//

import UIKit
import CatalogueCore

public final class SportsViewController: UITableViewController {

  private var loader: SportsLoader?
  private var sports: [Sport] = []

  public convenience init(loader: SportsLoader) {
    self.init()
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    Task {
      let result = await loader?.load()
      sports = (try? result?.get()) ?? []
      tableView.reloadData()
    }
  }

  public override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sports.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let sport = sports[indexPath.row]
    let cell = SportCell()
    cell.nameLabel.text = sport.name
    return cell
  }
}
