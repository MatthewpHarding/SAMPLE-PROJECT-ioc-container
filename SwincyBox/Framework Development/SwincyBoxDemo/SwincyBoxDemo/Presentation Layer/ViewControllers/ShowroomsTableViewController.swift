//
//  ShowroomsTableViewController.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 23/06/2022.
//

import UIKit


class ShowroomsTableViewController: UITableViewController {
    
    // MARK: - Dependencies
    
    private var registeredShowrooms: [Showroom] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        connectDatasource()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("Showrooms", comment: "")
    }
    
    private func setupTableView() {
        
    }
    
    // MARK: - Setup Datasource
    
    private func connectDatasource() {
        /*
         📦 For demonstration purposes we haven't used dependency injection for our list of manufacturers.
            Instead, we will retrieve them from our root Box
            Thus testing the functionality of our Box framework!
         */
        let app = App.shared
        let showroom1 = app.bmwShowroom // internally resolves dependencies from our Box
        let showroom2 = app.mercederShowroom
        registeredShowrooms.append(showroom1)
        registeredShowrooms.append(showroom2)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredShowrooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowroomCell", for: indexPath) as? ShowroomCell,
            let showroom = registeredShowrooms[safe: indexPath.row]
        else {
            return UITableViewCell()
        }
        
        // decoration
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hex: "#ED6623")
        cell.selectedBackgroundView = backgroundView
        cell.availableCarsLabel?.highlightedTextColor = .white
        cell.onDisplayLabel?.highlightedTextColor = .white
        cell.brandNameLabel?.highlightedTextColor = .white
        
        // data
        cell.brandNameLabel?.text = showroom.manufacturer
        cell.onDisplayLabel?.text = "On Display: \(showroom.shopWindowVehicle.model)"
        cell.availableCarsLabel?.text = "On Display: \(showroom.familyCar.make), \(showroom.sportsCar.make)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let showroom = registeredShowrooms[safe: indexPath.row] else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ShowroomViewController") as? ShowroomViewController else {
            return
        }
        
        viewController.showroom = showroom
        navigationController?.pushViewController(viewController, animated: true)
    }

}
