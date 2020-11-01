//
//  LMUIKit.swift
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

public class LMBottomSheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresentation ? 0.3 : 0.15
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        
        guard let controller = transitionContext.viewController(forKey: key) else { return }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        let dismissedFrame = CGRect(x: 0,
                                    y: UIScreen.main.bounds.height,
                                    width: presentedFrame.width,
                                    height: presentedFrame.height)
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        
        controller.view.layoutIfNeeded()
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            controller.view.frame = finalFrame
            controller.view.layoutIfNeeded()
        }, completion: { finished in
            
            transitionContext.completeTransition(finished)
            
            if !self.isPresentation && finished {
                controller.view.removeFromSuperview()
            }
        })
    }
}
