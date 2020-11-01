//
//  LMUIKit.swift
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

public class LMBottomSheetPresentationController: UIPresentationController {
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
        guard let containerView = self.containerView else { return .zero }

        return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: containerView.intrinsicContentSize.height)
    }
    
    @objc private func grayBackgroundTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
