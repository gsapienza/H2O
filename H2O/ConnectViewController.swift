//
//  ConnectViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController, BoardingProtocol {
    var titleLabel: UILabel!
    var connectTableView :UITableView!
    fileprivate var servicesModel :ServiceIntergrationModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "Done")
        
        titleLabel = generateTitleLabel()
        titleLabel.text = "Connect"
        
        connectTableView = generateConnectTableView()
        
        layout()
    }
    
    private func layout() {
        //---Title Label---
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---Connect Table View---
        view.addSubview(connectTableView)
        
        connectTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        delay(delay: 0.5, closure: {
            completion(true)
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.connectTableView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.connectTableView.alpha = 0
        })
    }
    
    func onRightBarButton() {
        let completeViewController = CompleteBoardingViewController()
        navigationController?.pushViewController(completeViewController, animated: true)
    }
}

extension ConnectViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SupportedServices.allSupportedServices().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ConnectTableViewCell(style: .default, reuseIdentifier: "CONNECT_CELL_IDENTIFIER")
        
        let service = SupportedServices.allSupportedServices()[indexPath.row]
        
        cell.titleLabel.text = "Enable " + service.string()
        cell.iconImageView.image = service.image()
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.frame = cell.frame.offsetBy(dx: 0, dy: view.bounds.height)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            cell.frame = cell.frame.offsetBy(dx: 0, dy: -self.view.bounds.height)
        }, completion: { Bool in
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.bounds.height / 4
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
}

// MARK: - Private Generators
private extension ConnectViewController {
    func generateConnectTableView() -> UITableView {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.bounces = false
        
        return tableView
    }
}
