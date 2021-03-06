//
//  AHPopTransitionHandler.swift
//  AHPinterest
//
//  Created by Andy Hurricane on 4/25/17.
//  Copyright © 2017 AndyHurricane. All rights reserved.
//

import UIKit

protocol AHPopInteractiveDelegate: NSObjectProtocol {
    // The scrollView's contentOffset. Only its y position will be used though.
    func popInteractiveForContentOffset() -> CGPoint
    
    // Interaction triggered when offset is less than the triggerYOffset. 
    // It should be "negative"!
    func popInteractiveForTriggerYOffset() -> CGFloat
    
    // The animating subject is the main to animate with. In the Pinterest case, it's the presenting imageView.
    func popInteractiveForAnimatingSubject() -> UIView
    
    // The animating subject will use this frame after the interactive animation. It should be relative to the background view. Because the animating subject will be "sticked" on the background view.
    func popInteractiveForAnimatingSubjectFinalFrame() -> CGRect
    
    // The attached view with animating subject. It will change its appearence as animation goes, as opposed to the animating subject which will not be changed.
    func popInteractiveForAnimatingSubjectBackground() -> UIView
    
    // The final view displayed after the interactive animation. And it will change its appearence too.
    func popInteractiveForAnimatingBackground() -> UIView
}


class AHPopInteractive: NSObject {
    weak var delegate: AHPopInteractiveDelegate!
    weak var vc: UIViewController!
    var isInPopTranstion = false
    let popInteractiveVC = AHPopInteractiveVC()
    var pan: UIPanGestureRecognizer?


    func attachView(vc: UIViewController,view: UIView){
        pan = UIPanGestureRecognizer(target: self, action: #selector(panHanlder(_:)))
        pan?.delegate = self
        view.addGestureRecognizer(pan!)
        self.vc = vc
    }
    
}

extension AHPopInteractive: UIGestureRecognizerDelegate, UICollectionViewDelegate {
    
    func panHanlder(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began,.changed:
            let pt = sender.location(in: popInteractiveVC.view)
            let contentOffset = delegate.popInteractiveForContentOffset()
            let triggerYOffset = delegate.popInteractiveForTriggerYOffset()
            
            if  contentOffset.y < triggerYOffset && !isInPopTranstion {
                isInPopTranstion = true
                setupPopInteractiveVC()
                
                popInteractiveVC.modalPresentationStyle = .custom
                vc.present(popInteractiveVC, animated: false, completion: nil)
                return
            }
            if isInPopTranstion {
                popInteractiveVC.touchMoved(to: pt)
            }
        case .cancelled, .ended:
            if isInPopTranstion {
                isInPopTranstion = false
                popInteractiveVC.touchEnded()
            }
        default:
            break
        }
    }

    func setupPopInteractiveVC() {
        popInteractiveVC.delegate = self
        
        let subjectBg = delegate.popInteractiveForAnimatingSubjectBackground()
        popInteractiveVC.subjectBg = subjectBg
        
        let subject = delegate.popInteractiveForAnimatingSubject()
        popInteractiveVC.subject = subject
        
        let background = delegate.popInteractiveForAnimatingBackground()
        popInteractiveVC.background = background
        
        let finalFrame = delegate.popInteractiveForAnimatingSubjectFinalFrame()
        popInteractiveVC.subjectFinalFrame = finalFrame
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension AHPopInteractive: AHPopInteractiveVCDelegate {
    func popInteractiveVCShouldPopController(bool: Bool) {
        if bool {
            if let navVC = vc.navigationController as? AHNavigationController {
                navVC.popViewController(animated: false)
            }
        }
    }
}




