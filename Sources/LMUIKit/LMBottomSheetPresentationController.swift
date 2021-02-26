//
//  LMUIKit.swift
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

public class LMBottomSheetPresentationController: UIPresentationController {
    
    public var widthInset: CGFloat = 0
    public var showsGrayBackground: Bool = true {
        didSet {
            grayBackground.isHidden = !showsGrayBackground
        }
    }
    
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
                
        presentedViewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                                                 action: #selector(handleSwipeToDismiss)))
        
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
                
        let safeAreaFrame = containerView.bounds
            .inset(by: containerView.safeAreaInsets)
        
        let targetWidth = safeAreaFrame.width - 2 * widthInset
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        
        let targetHeight = presentedView.systemLayoutSizeFitting(fittingSize,
                                                                 withHorizontalFittingPriority: .required,
                                                                 verticalFittingPriority: .defaultLow).height
        
        var frame = safeAreaFrame
        frame.origin.x += widthInset
        frame.origin.y += frame.size.height - targetHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight + containerView.safeAreaInsets.bottom
        return frame
    }
    
    @objc private func grayBackgroundTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSwipeToDismiss(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: presentedViewController.view)
        switch sender.state {
            case .changed:
                presentedViewController.view.frame.origin.y = translation.y
            case .ended:
                if translation.y > 50 {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            default:
                break
        }
    }
}
