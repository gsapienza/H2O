//
//  AppSettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/11/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {
    // MARK: - Public iVars
    
    /// Table View displaying setting cells.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private iVars
    
    /// Cell reuse identifier.
    fileprivate let reuseIdentifier = "\(AppSettingsTableViewCell.self)"
    
    // MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Table View---//
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AppSettingsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource
extension AppSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? AppSettingsTableViewCell else {
            fatalError("Cell is incorrect type.")
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AppSettingsViewController: UITableViewDelegate {
    
}
