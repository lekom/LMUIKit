//
//  File.swift
//  
//
//  Created by Leko Murphy on 10/31/20.
//

import UIKit

public extension UIView {
    
    func pinEdgesToSuperView(ignoreSafeArea: Bool = false) {
        guard let superview = self.superview else {
            assertionFailure("view has no superview to be pinned to")
            return
        }
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: ignoreSafeArea ? superview.topAnchor : superview.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: ignoreSafeArea ? superview.leadingAnchor : superview.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: ignoreSafeArea ? superview.trailingAnchor : superview.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: ignoreSafeArea ? superview.bottomAnchor : superview.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
