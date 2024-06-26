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
  private var tableModel: [TableModel] = []

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
      tableModel = (try? result?.get())?.toTableModel() ?? []
      tableView.reloadData()
    }
  }

  public override func numberOfSections(in tableView: UITableView) -> Int {
    tableModel.count
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel[section].events.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let sportEvent = tableModel[indexPath.section].events[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "SportEventCell", for: indexPath) as! SportEventCell
    cell.marketLabel.text = sportEvent.marketName
    cell.matchLabel.text = sportEvent.eventName

    for odd in sportEvent.odds {
      let view = OddsView()
      view.titleLabel.text = odd.title
      view.numeratorLabel.text = odd.numerator
      view.denominatorLabel.text = odd.denominator

      cell.odsStackView.addArrangedSubview(view)
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    tableModel[section].date
  }
}

struct TableModel {
  let date: String
  let events: [SportEventPresentableModel]
}

struct SportEventPresentableModel {
  typealias RunnerOdds = (title: String, numerator: String, denominator: String)

  let marketName: String
  let eventName: String

  let odds: [RunnerOdds]
}

extension Array where Element == SportEvent {
  func toTableModel() -> [TableModel] {
    let groupsByDate: [Date: [SportEvent]] = Dictionary(grouping: self, by: { $0.date })
    let sortedGroups = groupsByDate.sorted { $0.key < $1.key }

    let nameTransformer: (SportEvent) -> (home: String, away: String) = {
      let separator = $0.primaryMarket.type == .matchBetting ? " vs " : " v "
      let teamNames = $0.name.split(separator: separator)
      let homeTeam = String(teamNames[0])
      let awayTeam = String(teamNames[1])

      return (homeTeam, awayTeam)
    }

    let dateTransformer: (Date) -> String = {
      let weekDay = $0.formatted(Date.FormatStyle().weekday(.wide))
      let day = $0.formatted(Date.FormatStyle().day(.ordinalOfDayInMonth))
      let month = $0.formatted(Date.FormatStyle().month(.wide))
      return "\(weekDay) \(day) \(month)"
    }

    let homeDrawAwayTransformer: (SportEvent) -> [SportEventPresentableModel.RunnerOdds] = {
      let homeTeam = nameTransformer($0).home
      let awayTeam = nameTransformer($0).away

      guard 
        let homeOdds = $0.primaryMarket.runners.first(where: { $0.name == homeTeam })?.odds,
        let drawOdds = $0.primaryMarket.runners.first(where: { $0.name == "Draw" })?.odds,
        let awayOdds = $0.primaryMarket.runners.first(where: { $0.name == awayTeam })?.odds
      else { return [] }

      return [
        (title: "Home", numerator: "\(homeOdds.numerator)", denominator: "\(homeOdds.denominator)"),
        (title: "Draw", numerator: "\(drawOdds.numerator)", denominator: "\(drawOdds.denominator)"),
        (title: "Away", numerator: "\(awayOdds.numerator)", denominator: "\(awayOdds.denominator)")
      ]
    }

    let totalGoalsTransformer: (SportEvent) -> [SportEventPresentableModel.RunnerOdds] = {
      guard $0.primaryMarket.runners.map({ $0.totalGoals }).allSatisfy({ $0 != nil }) else { return [] }
      return $0.primaryMarket.runners.toPresentableGoalsModels()
    }

    return sortedGroups.map { (date, events) in
      TableModel(
        date: dateTransformer(date),
        events: events.map {
          SportEventPresentableModel(
            marketName: $0.primaryMarket.name,
            eventName: "\(nameTransformer($0).home)\n\n\(nameTransformer($0).away)",
            odds: $0.primaryMarket.type == .totalGoalsInMatch ? totalGoalsTransformer($0) : homeDrawAwayTransformer($0)
          )
        }
      )
    }
  }
}

extension Array where Element == Runner {
  func toPresentableGoalsModels() -> [SportEventPresentableModel.RunnerOdds] {
    map {
      return (title: "\($0.totalGoals!)", numerator: "\($0.odds.numerator)", denominator: "\($0.odds.denominator)")
    }
  }
}
