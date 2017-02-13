//
//  StoryBoardExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/18/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

class StoryBoardExtension: NSObject {

}

extension UIStoryboard {
    enum Storyboard :String {
        case Main
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        let optionalViewController = instantiateViewController(withIdentifier: T.storyboardIdentifier)
        
        guard let viewController = optionalViewController as? T else {
            fatalError("Couldn’t instantiate view controller with identifier \(T.storyboardIdentifier)")
        }
        
        return viewController
    }
}


extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController : StoryboardIdentifiable { }
