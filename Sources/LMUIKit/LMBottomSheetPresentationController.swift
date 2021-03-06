//
//  LMUIKit.swift
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

public class LMBottomSheetPresentationController: UIPresentationController {
    
    private var swipeOffset: CGFloat = 0
    private lazy var swipeOriginalPoint = CGPoint(x: frameOfPresentedViewInContainerView.midX, y: frameOfPresentedViewInContainerView.midY)
    private var swipePreviousPoint: CGPoint = .zero
    
    private var keyboardHeight: CGFloat = 0
    
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
        
        if keyboardHeight > 0 {
            frame.origin.y -= (keyboardHeight - containerView.safeAreaInsets.bottom)
        }
        
        return frame
    }
    
    @objc private func grayBackgroundTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSwipeToDismiss(sender: UIPanGestureRecognizer) {
        guard let containerView = self.containerView else {
            return
        }
        
        let minDismissVelocity: CGFloat = 2000; // pt/s
        let minDismissDistance: CGFloat = presentedViewController.view.bounds.height / 2
        
        swipeOffset = sender.translation(in: presentedViewController.view).y
        
        let distanceVector = CGPoint(x: presentedViewController.view.layer.position.x - swipeOriginalPoint.x,
                                     y: presentedViewController.view.layer.position.y - swipeOriginalPoint.y)
        
        let distance = sqrt((distanceVector.x * distanceVector.x) + (distanceVector.y * distanceVector.y))
        
        let velocityVector = sender.velocity(in: containerView)
        let velocity = sqrt((velocityVector.x * velocityVector.x) + (velocityVector.y * velocityVector.y))
                
        let goingDown = distanceVector.y > 0

        switch sender.state {
            case .began:
                swipeOriginalPoint = presentedViewController.view.center
                swipePreviousPoint = swipeOriginalPoint
            case .changed:
                swipePreviousPoint = presentedViewController.view.center
                
                presentedViewController.view.center = CGPoint(x: swipeOriginalPoint.x,
                                                              y: swipeOriginalPoint.y + swipeOffset / (goingDown ? 1.0 : max(2.0, sqrt(distance))))
            case .ended:
                if goingDown && (velocity > minDismissVelocity || distance > minDismissDistance) {
                    presentedViewController.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.15) {
                        self.presentedViewController.view.center = self.swipeOriginalPoint
                    }
                }
            default:
                break
        }
    }
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func onKeyboardShown(notification: Notification) {
        guard presentedViewController.isTopMostController else {
            return 
        }
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let curve = UIView.AnimationOptions(rawValue: curveInt)
        
        self.keyboardHeight = keyboardFrameEnd.height

        if self.presentedViewController.isBeingPresented {
            presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            }, completion: nil)
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, curve], animations: {
                self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            }, completion: nil)
        }
    }
    
    @objc private func onKeyboardHidden(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let curve = UIView.AnimationOptions(rawValue: curveInt)
        
        self.keyboardHeight = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, curve], animations: {
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
    }
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
    }
}
