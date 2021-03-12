//
//  File.swift
//  
//
//  Created by Leko Murphy on 3/12/21.
//

import UIKit

extension UIViewController {

    var isTopMostController: Bool {
        return self === UIViewController.topViewController()
    }
    
    private static func topViewController(_ controller: UIViewController? = UIApplication.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(presented)
        }
        return controller
    }

}
