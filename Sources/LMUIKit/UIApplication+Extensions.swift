//
//  File.swift
//  
//
//  Created by Leko Murphy on 3/12/21.
//

import UIKit

extension UIApplication {
    static var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first(where:{ $0.isKeyWindow })?.rootViewController
    }
}
