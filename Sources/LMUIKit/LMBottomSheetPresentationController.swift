//
//  LMUIKit.swift
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

public class LMBottomSheetPresentationController: UIPresentationController {
    
    public var widthInset: CGFloat = 0
    
    private lazy var grayBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(grayBackgroundTapped)))
        view.alpha = 0
        return view
    }()
    
    public override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        grayBackground.frame = containerView.frame
        containerView.addSubview(grayBackground)
        containerView.addSubview(presentedViewController.view)
                
        let coordinator = presentingViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in
            self.grayBackground.alpha = 1.0
        }, completion: nil)
    }
    
    public override func dismissalTransitionWillBegin() {
        let coordinator = presentingViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in
            self.grayBackground.alpha = 0.0
        }, completion: { _ in
            self.grayBackground.removeFromSuperview()
        })
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
              let presentedView = presentedView else { return .zero }
                
        let frame = containerView.bounds
        
        let targetWidth = frame.width - 2 * widthInset
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        
        let targetHeight = presentedView.systemLayoutSizeFitting(fittingSize,
                                                                 withHorizontalFittingPriority: .required,
                                                                 verticalFittingPriority: .defaultLow).height
        
        var finalFrame = frame
        finalFrame.origin.x += widthInset
        finalFrame.origin.y += finalFrame.size.height - targetHeight
        finalFrame.size.width = targetWidth
        finalFrame.size.height = targetHeight
        return finalFrame
    }
    
    @objc private func grayBackgroundTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
