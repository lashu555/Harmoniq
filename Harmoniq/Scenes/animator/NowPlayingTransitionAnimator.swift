//
//  NowPlayingTransitionAnimator.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 27.03.25.
//

import UIKit

class NowPlayingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval = 0.5
    var isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }

        let containerView = transitionContext.containerView
        let nowPlayingVC = isPresenting ? toViewController.view! : fromViewController.view!

        if isPresenting {
            // **Initial state before animation**
            nowPlayingVC.alpha = 0
            nowPlayingVC.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)

            containerView.addSubview(nowPlayingVC)
        }

        // **Animate elements smoothly**
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            if self.isPresenting {
                nowPlayingVC.alpha = 1
                nowPlayingVC.transform = .identity
            } else {
                nowPlayingVC.alpha = 0
                nowPlayingVC.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
            }
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

