//
//  BottomSheetController.swift
//  GPTClone
//
//  Created by Yuriy on 03.10.2024.
//

import UIKit

/// Use `BottomSheetController` as the basis for your bottom sheet. Subclass it or use it as is.
/// You add subviews and child view controllers as you would with every other view/view controller.
///
/// The `BottomSheetController` installs its own `UIViewControllerTransitioningDelegate`
/// and forces `UIModalPresentationStyle` to `UIModalPresentationStyle.custom`.
/// Present it as you would present any other `UIViewController`, using `UIViewController.present(_:)`.
class BottomSheetController: UIViewController {

    /// Enum that specify how the sheet should size it self based on its content.
    /// The sheet sizing act as a loose anchor on how big the sheet should be, and the sheet will always respect its content's constraints.
    /// However, the sheet will never extend beyond the top safe area (plus any stretch offset).
    enum PreferredSheetSizing: CGFloat {
        /// The sheet will try to size it self so that it only just fits its content.
        case fit = 0
        /// The sheet will try to size it self so that it fills 1/4 of available space.
        case small = 0.25
        /// The sheet will try to size it self so that it fills 1/2 of available space.
        case medium = 0.6
        /// The sheet will try to size it self so that it fills 3/4 of available space.
        case large = 0.75
        /// The sheet will try to size it self so that it fills all available space.
        case fill = 1
        
        case custom = 0.4
        
    }

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        preferredSheetTopInset: preferredSheetTopInset,
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetSizingFactor: preferredSheetSizing.rawValue,
        preferredSheetBackdropColor: preferredSheetBackdropColor
    )

    override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            .init(
                top: super.additionalSafeAreaInsets.top + preferredSheetCornerRadius,
                left: super.additionalSafeAreaInsets.left,
                bottom: super.additionalSafeAreaInsets.bottom,
                right: super.additionalSafeAreaInsets.right
            )
        }
        set {
            super.additionalSafeAreaInsets = newValue
        }
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }

    /// Preferred space between the sheet's max stretch height and the safe area.
    /// Defaults to 0.
    var preferredSheetTopInset: CGFloat = 0 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }

    /// Preferred corner radius of the sheet's top left and right corner.
    /// Defaults to 8.
    var preferredSheetCornerRadius: CGFloat = 24 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    /// Preferred sheet sizing. See `PreferredSheetSizing` for all available options.
    /// Defaults to `PreferredSheetSizing.medium`.
    var preferredSheetSizing: PreferredSheetSizing = .medium {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    /// Preferred sheet backdrop color. This is the color of the overlay/backdrop view behind the sheet.
    /// Defaults to `UIColor.label`.
    var preferredSheetBackdropColor: UIColor = .overlay {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
        }
    }

    /// Boolean to specify if it should be possible to dismiss the sheet by tapping the backdrop.
    /// Defaults to true.
    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }

    /// Boolean to specify if it should be possible to dismiss the sheet by dragging it down.
    /// Defaults to true.
    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}



//MARK: -


final class BottomSheetInteractiveDismissalTransition: NSObject {

    private let stretchHeight: CGFloat

    // Points per seconds. Just a number that felt "natural".
    // Used as threshold for triggering dismissal.
    private let dismissalVelocityThreshold: CGFloat = 2000

    // "Distance" per seconds. Just a number that felt "natural" and prevents
    // too much overshoot when defining spring parameters with initial velocity.
    private let maxInitialVelocity: CGFloat = 20

    // How quickly the spring animation settles.
    private let springAnimationSettlingTime: CGFloat = 0.33

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    // Capture the sheet's initial height.
    private var initialSheetHeight: CGFloat = .zero

    // This tracks the how far the sheet has initially moved at the start of a gesture.
    // The sheet can be in movement/mid-animation when a gesture happens.
    private var initialTranslation: CGPoint = .zero

    private(set) var interactiveDismissal: Bool = false

    var heightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    init(stretchOffset: CGFloat) {
        self.stretchHeight = stretchOffset
    }

    private func initialVelocity(
        basedOn gestureVelocity: CGPoint,
        startingAt currentValue: CGFloat,
        endingAt finalValue: CGFloat
    ) -> CGVector {
        // Tip on how to calculate initial velocity:
        // https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity
        let distance = finalValue - currentValue

        var velocity: CGFloat = 0

        if distance != 0 {
            velocity = gestureVelocity.y / distance
        }

        // Limit the velocity to prevent too much overshoot if the velocity is high.
        if velocity > 0 {
            velocity = min(velocity, maxInitialVelocity)
        } else {
            velocity = max(velocity, -maxInitialVelocity)
        }

        return CGVector(dx: velocity, dy: velocity)
    }

    private func timingParameters(
        with initialVelocity: CGVector = .zero
    ) -> UITimingCurveProvider {
        UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: initialVelocity
        )
    }

    private func propertyAnimator(
        with initialVelocity: CGVector = .zero
    ) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: springAnimationSettlingTime,
            timingParameters: timingParameters(
                with: initialVelocity
            )
        )
    }

    private func makeHeightAnimator(
        animating view: UIView,
        to height: CGFloat,
        _ completion: @escaping (UIViewAnimatingPosition) -> Void
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()

        // Make sure layout is up to date before adding animations.
        view.superview?.layoutIfNeeded()

        let originalHeight = view.frame.height

        propertyAnimator.addAnimations {
            self.heightConstraint?.constant = height
            self.heightConstraint?.isActive = true

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.heightConstraint?.isActive = position != .start
            self.heightConstraint?.constant = position == .end
                ? height
                : position == .current
                    ? view.frame.height
                    : originalHeight
        }

        propertyAnimator.addCompletion(completion)

        return propertyAnimator
    }

    private func makeOffsetAnimator(
        animating view: UIView,
        to offset: CGFloat,
        _ completion: @escaping (UIViewAnimatingPosition) -> Void
    ) -> UIViewPropertyAnimator {
        let propertyAnimator = propertyAnimator()

        // Make sure layout is up to date before adding animations.
        view.superview?.layoutIfNeeded()

        let originalOffset = bottomConstraint?.constant ?? 0
        let originalCenterY = view.center.y

        propertyAnimator.addAnimations {
            self.bottomConstraint?.constant = originalOffset + offset

            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomConstraint?.constant = position == .end
                ? originalOffset + offset
                : position == .current
                    ? view.center.y - originalCenterY
                    : originalOffset
        }

        propertyAnimator.addCompletion(completion)

        return propertyAnimator
    }

    private func updateHeightAnimator(
        animating view: UIView,
        with fractionComplete: CGFloat
    ) {
        // Cancel any running offset animator so it does not interfere with the height animator.
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        self.offsetAnimator = nil

        let heightAnimator = self.heightAnimator ?? makeHeightAnimator(
            animating: view, to: initialSheetHeight + stretchHeight
        ) { _ in
            // Throw away the used animator, so we are ready to start fresh.
            self.heightAnimator = nil
        }

        heightAnimator.fractionComplete = fractionComplete

        self.heightAnimator = heightAnimator
    }

    private func updateOffsetAnimator(
        animating view: UIView,
        with fractionComplete: CGFloat
    ) {
        // Cancel any running height animator so it does not interfere with the offset animator.
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)

        self.heightAnimator = nil

        defer {
            offsetAnimator?.fractionComplete = fractionComplete

            // Update any active transition context.
            transitionContext?.updateInteractiveTransition(fractionComplete)
        }

        // Return early and leave the creation of the offset animator to
        // our implementation of `UIViewControllerInteractiveTransitioning`
        // if this is an interactive dismissal.
        if interactiveDismissal {
            return
        }

        let offsetAnimator = self.offsetAnimator ?? makeOffsetAnimator(
            animating: view, to: stretchHeight
        ) { position in
            // Throw away the used animator, so we are ready to start fresh.
            self.offsetAnimator = nil
        }

        self.offsetAnimator = offsetAnimator
    }

    private func checkIfPotentialDismissalAndUpdateAnimators(
        animating view: UIView,
        using translation: CGPoint
    ) -> Bool {
        // Figure out how far the sheet has moved away from its original position.
        let totalTranslationY = initialTranslation.y + translation.y

        // Since we animate the same properties in both animators (size and position),
        // we avoid conflicts by only running one animator at the time.
        if totalTranslationY < 0 {
            // The sheet wants to move above its original height.
            // Make (or use an already running) height animator to drive this movement.

            // Figure out the height animator's fraction complete.
            // Using `pow()` to add a rubber band effect.
            let heightFraction = min(pow(abs(min(totalTranslationY, 0)), 0.5) / stretchHeight, 1)

            updateHeightAnimator(
                animating: view,
                with: heightFraction
            )
        } else {
            // The sheet wants to move below its original height.
            // Make (or use an already running) offset animator to drive this movement.

            // Figure out the offset animator's fraction complete.
            // Using `pow()` to add a rubber band effect (when non-interactive dismissal).
            let offsetFraction: CGFloat
            if interactiveDismissal {
                offsetFraction = min(max(totalTranslationY, 0) / initialSheetHeight, 1)
            } else {
                offsetFraction = min(pow(max(totalTranslationY, 0), 0.5) / stretchHeight, 1)
            }

            updateOffsetAnimator(
                animating: view,
                with: offsetFraction
            )
        }

        // Signal that the sheet is moving towards dismissal.
        return interactiveDismissal && totalTranslationY > 0
    }
}

// MARK: Public methods

extension BottomSheetInteractiveDismissalTransition {

    func cancel() {
        // Cancels any active animators (`.stopAnimation(false)`
        // and leave the animated properties at current value (`finishAnimation(at: .current)`).
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .current)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .current)
    }

    func checkIfPotentialDismissalAndStart(
        moving presentedView: UIView,
        using translation: CGPoint,
        asInteractiveDismissal interactiveDismissal: Bool
    ) -> Bool {
        // Capture interactive dismissal control flag.
        self.interactiveDismissal = interactiveDismissal

        if heightAnimator?.state == .active || offsetAnimator?.state == .active {
            // The sheet is currently in movement.

            // Pause the height animator (if present).
            heightAnimator?.pauseAnimation()
            heightAnimator?.isReversed = false

            // Pause the offset animator (if present).
            offsetAnimator?.pauseAnimation()
            offsetAnimator?.isReversed = false

            // Pause any active transition context.
            transitionContext?.pauseInteractiveTransition()

            // Calculate new initial translation.
            let heightFraction = heightAnimator?.fractionComplete ?? 0
            let offsetFraction = offsetAnimator?.fractionComplete ?? 0

            let finalOffset = interactiveDismissal ? initialSheetHeight : stretchHeight

            initialTranslation = CGPoint(
                x: 0,
                y: offsetFraction * finalOffset - heightFraction * stretchHeight
            )

            // How far the sheet has moved away from its original position.
            let totalTranslationY = initialTranslation.y + translation.y

            // Signal that the sheet is moving towards dismissal.
            return interactiveDismissal && totalTranslationY > 0
        } else {
            // The sheet is currently at rest.

            // Capture control values.
            presentedView.superview?.layoutIfNeeded()

            initialSheetHeight = presentedView.frame.height
            initialTranslation = .zero

            return checkIfPotentialDismissalAndUpdateAnimators(
                animating: presentedView, using: translation
            )
        }
    }

    func checkIfPotentialDismissalAndMove(
        _ presentedView: UIView,
        using translation: CGPoint
    ) -> Bool {
        checkIfPotentialDismissalAndUpdateAnimators(
            animating: presentedView, using: translation
        )
    }

    func stop(
        moving presentedView: UIView,
        with velocity: CGPoint
    ) {
        if let heightAnimator {
            let fractionComplete = heightAnimator.fractionComplete

            let initialHeightVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: fractionComplete * stretchHeight,
                endingAt: stretchHeight
            )

            // Always animate back to initial sheet height.
            heightAnimator.isReversed = true

            heightAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    with: initialHeightVelocity
                ),
                durationFactor: 1
            )
        } else if let offsetAnimator {
            let fractionComplete = offsetAnimator.fractionComplete

            // Determine if the dismissal should continue (and animate the sheet off screen),
            // or if it should be canceled (and the animation reversed).
            let continueDismissal = interactiveDismissal && // Needs to be interactive dismissal.
            (
                velocity.y > dismissalVelocityThreshold || // Gesture velocity is more than the threshold.
                fractionComplete > 0.5 && velocity.y > -dismissalVelocityThreshold // The sheet is 50% off screen and the gesture velocity is greater than the negative threshold.
            )

            let initialOffsetVelocity = initialVelocity(
                basedOn: velocity,
                startingAt: fractionComplete * initialSheetHeight,
                endingAt: continueDismissal ? initialSheetHeight : 0
            )

            offsetAnimator.isReversed = !continueDismissal

            // Update any active transition context.
            if continueDismissal {
                transitionContext?.finishInteractiveTransition()
            } else {
                transitionContext?.cancelInteractiveTransition()
            }

            offsetAnimator.continueAnimation(
                withTimingParameters: timingParameters(
                    with: initialOffsetVelocity
                ),
                durationFactor: 1
            )
        } else {
            // We are only allowed to end up here if this is an interactive dismissal.
            // E.g `UIViewControllerInteractiveTransitioning.startInteractiveTransition(_:)` has not yet been called (and hence no offset animator exist yet).
            // If this is a non-interactive dismissal we'd expect one of the animators (height or offset) to always exist.
            assert(interactiveDismissal)
        }

        // Reset any previously set interactive dismissal control flag.
        interactiveDismissal = false
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    private func doDismissTransitionWithoutAnimation() {
        bottomConstraint?.constant += initialSheetHeight
    }

    private func prepareOffsetAnimatorForDismissTransition(
        animating view: UIView,
        associatedWith transitionContext: UIViewControllerContextTransitioning
    ) {
        // Cancel any running height animator so it does not interfere with the offset animator.
        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)

        heightAnimator = nil

        // We expect there to be no other active offset animator
        // before this point when dismissing interactively.
        assert(offsetAnimator == nil)

        let offsetAnimator = makeOffsetAnimator(
            animating: view, to: initialSheetHeight
        ) { position in
            // Throw away the used animator, so we are ready to start fresh.
            self.offsetAnimator = nil

            // Also remove reference to the transition context.
            self.transitionContext = nil

            transitionContext.completeTransition(position == .end)
        }

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        // This value is not really used since we only care about interactive transitions.
        propertyAnimator().duration
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // This is never really called since we only care about interactive transitions,
        // and use UIKit's default transitions/animations for non-interactive transitions.
        guard
            transitionContext.isAnimated,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return doDismissTransitionWithoutAnimation()
        }

        prepareOffsetAnimatorForDismissTransition(
            animating: presentedView, associatedWith: transitionContext
        )

        transitionContext.finishInteractiveTransition()

        offsetAnimator?.startAnimation()
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        // At this point `UIViewControllerInteractiveTransitioning.startInteractiveTransition(_:)`
        // should have been called and there should exist a newly created offset animator.
        guard let offsetAnimator = offsetAnimator else {
            fatalError("Somehow the offset animator was not set")
        }

        return offsetAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning

extension BottomSheetInteractiveDismissalTransition: UIViewControllerInteractiveTransitioning {

    var wantsInteractiveStart: Bool {
        interactiveDismissal
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            transitionContext.isInteractive,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return animateTransition(using: transitionContext)
        }

        prepareOffsetAnimatorForDismissTransition(
            animating: presentedView, associatedWith: transitionContext
        )

        transitionContext.pauseInteractiveTransition()

        offsetAnimator?.pauseAnimation()

        if !interactiveDismissal {
            // The gesture driving the transition has already ended or been canceled.
            // Make sure both transition context and animation is canceled.
            transitionContext.cancelInteractiveTransition()

            self.offsetAnimator?.isReversed = true

            self.offsetAnimator?.continueAnimation(
                withTimingParameters: timingParameters(),
                durationFactor: 1
            )
        }
    }
}


//MARK: -


final class BottomSheetPresentationController: UIPresentationController {

    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = sheetBackdropColor
        view.alpha = 0
        return view
    }()

    // How much the sheet can stretch beyond its original height/offset.
    private static let sheetStretchOffset: CGFloat = 16

    let bottomSheetInteractiveDismissalTransition = BottomSheetInteractiveDismissalTransition(
        stretchOffset: sheetStretchOffset
    )

    let sheetTopInset: CGFloat
    let sheetCornerRadius: CGFloat
    let sheetSizingFactor: CGFloat
    let sheetBackdropColor: UIColor

    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        return gestureRecognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        return gestureRecognizer
    }()

    var panToDismissEnabled: Bool = true

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        sheetTopInset: CGFloat,
        sheetCornerRadius: CGFloat,
        sheetSizingFactor: CGFloat,
        sheetBackdropColor: UIColor
    ) {
        self.sheetTopInset = sheetTopInset
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetSizingFactor = sheetSizingFactor
        self.sheetBackdropColor = sheetBackdropColor

        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    @objc private func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Make sure there is no ongoing pan gesture.
        guard panGestureRecognizer.state == .possible else {
            return
        }

        // Cancel any in flight animation before dismissing the sheet.
        bottomSheetInteractiveDismissalTransition.cancel()

        presentingViewController.dismiss(animated: true)
    }

    @objc private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        let translation = gestureRecognizer.translation(in: presentedView)

        switch gestureRecognizer.state {
            case .began:
                let startingTowardsDismissal = bottomSheetInteractiveDismissalTransition.checkIfPotentialDismissalAndStart(
                    moving: presentedView, using: translation, asInteractiveDismissal: panToDismissEnabled
                )

                if startingTowardsDismissal, !presentedViewController.isBeingDismissed {
                    presentingViewController.dismiss(animated: true)
                }
            case .changed:
                let movingTowardsDismissal = bottomSheetInteractiveDismissalTransition.checkIfPotentialDismissalAndMove(
                    presentedView, using: translation
                )

                if movingTowardsDismissal, !presentedViewController.isBeingDismissed {
                    presentingViewController.dismiss(animated: true)
                }
            default:
                let velocity = gestureRecognizer.velocity(in: presentedView)
                bottomSheetInteractiveDismissalTransition.stop(
                    moving: presentedView, with: velocity
                )
        }
    }

    // MARK: UIPresentationController

    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.addGestureRecognizer(panGestureRecognizer)

        presentedView.clipsToBounds = true
        presentedView.layer.cornerRadius = sheetCornerRadius
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]

        guard let containerView = containerView else {
            return
        }

        backdropView.addGestureRecognizer(tapGestureRecognizer)

        containerView.addSubview(backdropView)

        backdropView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            backdropView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            backdropView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            backdropView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
        ])

        // Define a layout guide we can constrain the presented view to.
        // This layout guide will act as the outer boundaries for the presented view.
        let bottomSheetLayoutGuide = UILayoutGuide()
        containerView.addLayoutGuide(bottomSheetLayoutGuide)

        containerView.addSubview(presentedView)

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        let maximumHeightConstraint = presentedView.heightAnchor.constraint(
            lessThanOrEqualTo: bottomSheetLayoutGuide.heightAnchor,
            // We don't want the sheet to stretch beyond the top of our defined boundaries (`bottomSheetLayoutGuide`).
            constant: -(sheetTopInset + Self.sheetStretchOffset)
        )

        // Prevents conflicts with the height constraint used by the animated transition.
        maximumHeightConstraint.priority = .required - 1

        let preferredHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: bottomSheetLayoutGuide.heightAnchor,
            multiplier: sheetSizingFactor
        )

        preferredHeightConstraint.priority = .fittingSizeLevel

        let heightConstraint = presentedView.heightAnchor.constraint(
            equalToConstant: 0
        )

        let bottomConstraint = presentedView.bottomAnchor.constraint(
            equalTo: bottomSheetLayoutGuide.bottomAnchor
        )

        NSLayoutConstraint.activate([
            bottomSheetLayoutGuide.topAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.topAnchor
            ),
            bottomSheetLayoutGuide.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
            bottomSheetLayoutGuide.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            bottomSheetLayoutGuide.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),

            presentedView.leadingAnchor.constraint(
                equalTo: bottomSheetLayoutGuide.leadingAnchor
            ),
            presentedView.trailingAnchor.constraint(
                equalTo: bottomSheetLayoutGuide.trailingAnchor
            ),
            bottomConstraint,
            maximumHeightConstraint,
            preferredHeightConstraint,
        ])

        bottomSheetInteractiveDismissalTransition.heightConstraint = heightConstraint
        bottomSheetInteractiveDismissalTransition.bottomConstraint = bottomConstraint

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate { context in
            self.backdropView.alpha = 0.3
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backdropView.removeFromSuperview()
            presentedView?.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func dismissalTransitionWillBegin() {
        guard
            let transitionCoordinator = presentingViewController.transitionCoordinator,
            transitionCoordinator.isAnimated
        else {
            return
        }

        transitionCoordinator.animate { context in
            self.backdropView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        panGestureRecognizer.isEnabled = false

        coordinator.animate(alongsideTransition: nil) { context in
            self.panGestureRecognizer.isEnabled = true
        }
    }
}


// MARK: BottomSheetTransitioningDelegate

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var bottomSheetPresentationController: BottomSheetPresentationController?

    var preferredSheetTopInset: CGFloat
    var preferredSheetCornerRadius: CGFloat
    var preferredSheetSizingFactor: CGFloat
    var preferredSheetBackdropColor: UIColor

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.panToDismissEnabled = panToDismissEnabled
        }
    }

    init(
        preferredSheetTopInset: CGFloat,
        preferredSheetCornerRadius: CGFloat,
        preferredSheetSizingFactor: CGFloat,
        preferredSheetBackdropColor: UIColor
    ) {
        self.preferredSheetTopInset = preferredSheetTopInset
        self.preferredSheetCornerRadius = preferredSheetCornerRadius
        self.preferredSheetSizingFactor = preferredSheetSizingFactor
        self.preferredSheetBackdropColor = preferredSheetBackdropColor
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let bottomSheetPresentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source,
            sheetTopInset: preferredSheetTopInset,
            sheetCornerRadius: preferredSheetCornerRadius,
            sheetSizingFactor: preferredSheetSizingFactor,
            sheetBackdropColor: preferredSheetBackdropColor
        )

        bottomSheetPresentationController.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        bottomSheetPresentationController.panToDismissEnabled = panToDismissEnabled

        self.bottomSheetPresentationController = bottomSheetPresentationController

        return bottomSheetPresentationController
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let bottomSheetPresentationController = dismissed.presentationController as? BottomSheetPresentationController,
            bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition.interactiveDismissal
        else {
            return nil
        }

        return bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        animator as? BottomSheetInteractiveDismissalTransition
    }
}
