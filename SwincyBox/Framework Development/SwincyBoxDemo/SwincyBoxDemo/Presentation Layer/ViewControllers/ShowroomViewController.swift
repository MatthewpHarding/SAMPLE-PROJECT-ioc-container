//
//  ViewController.swift
//  SwincyDemo
//
//  Created by Matthew Paul Harding on 17/06/2022.
//

import UIKit
import SwincyBox

/*
    NOTICE:
            Did you notice that there aren't any references to 'Car', only the protocol 'Vehicle'?
 */
class ShowroomViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var vehicleMakeLabel: UILabel?
    @IBOutlet var vehicleModelLabel: UILabel?
    @IBOutlet var vehicleTopSpeedLabel: UILabel?
    @IBOutlet var vehicleDoorsLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    // MARK: - Dependencies
    var showroom: Showroom?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDefaultValues()
        setupNavigationBar()
    }
    
    private func populateDefaultValues() {
        selectFamilyVehicle()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = showroom?.manufacturer ?? ""
    }
    
    // MARK: - IBActions
    @IBAction private func familyVehicleButtonPressed(_ sender: UIButton) {
        selectFamilyVehicle()
    }
    
    @IBAction private func sportsVehicleButtonPressed(_ sender: UIButton) {
        selectSportsVehicle()
    }
    
    // MARK: - Showroom
    private func selectFamilyVehicle() {
        guard let showroom = self.showroom else { return }
        // 📦 Use custom created getters to access dependencies conveniently from the main box
        showroom.shopWindowType = .familyDriving
        displayVehicleInsideShopWindow(showroom.shopWindowVehicle)
    }
    
    private func selectSportsVehicle() {
        guard let showroom = self.showroom else { return }
        // 📦 Use custom created getters to access dependencies conveniently from the main box
        showroom.shopWindowType = .funMiddleAgedDriving
        displayVehicleInsideShopWindow(showroom.shopWindowVehicle)
    }
    
    private func displayVehicleInsideShopWindow(_ vehicle: Vehicle) {
        vehicleMakeLabel?.text = vehicle.make
        vehicleModelLabel?.text = vehicle.model
        vehicleTopSpeedLabel?.text = String(vehicle.topSpeed)
        vehicleDoorsLabel?.text = String(vehicle.doors)
        imageView?.image = UIImage(named: vehicle.imageName)
    }
}
