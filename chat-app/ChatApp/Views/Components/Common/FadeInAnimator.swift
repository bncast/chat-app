//
//  FadeInAnimator.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/20/24.
//

import UIKit

class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.3
    var isPresent = true

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            presentTransition(using: transitionContext)
        } else {
            dismissTransition(using: transitionContext)
        }
    }

    private func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to)
        else { fatalError("Couldn't get information for transitioning views.") }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.alpha = 0
        UIView.animate(withDuration: duration) {
            toView.alpha = 1
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private func dismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from)
        else { fatalError("Couldn't get information for transitioning views.") }

        fromView.alpha = 1
        UIView.animate(withDuration: duration) {
            fromView.alpha = 0
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension FadeInAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented _: UIViewController,
                             presenting _: UIViewController,
                             source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
}

