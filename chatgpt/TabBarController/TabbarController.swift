//
//  TabbarController.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//
import UIKit

final class TabBarController: UITabBarController {
    
    private lazy var tabbarRouter = TabbarRouter(viewController: self)
    
    private var customTabBarView = UIView(frame: .zero)
    
    private lazy var customButton: UIButton = {
        let button = CustomButton(CustomTabButtonSUI())
        button.addTarget(
            self,
            action: #selector(handleTabBarButtonTap),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let gradientView = UIView()

    private var customButtonBottomConstraint: NSLayoutConstraint?

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupGradient()

        setupTabBar()
        addCustomTabBarView()
        
        setupViewControllers()
        setupCustomButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        customButtonBottomConstraint?.constant = view.safeAreaInsets.bottom > 0 ? -37 : 0
        
        view.layoutIfNeeded()
        
        self.setupCustomTabBarFrame()
        gradientView.applyGradient(
            isVertical: true,
            colorArray: [.bg.withAlphaComponent(0), .bg]
        )
    }

    
    // MARK: Private methods
    
    private func setupViewControllers() {
        let createMainViewController = MainModuleFactory.createModule()
        
        tabbarItemConfigure(
            vc: createMainViewController,
            title: "Главная",
            image: UIImage.tab1,
            tag: 0
        )
        
        
        let settingsViewController = UIViewController()
        let settingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        tabbarItemConfigure(
            vc: settingsViewController,
            title: "Настройки",
            image: UIImage.tab2,
            tag: 1
        )
        
        
        self.viewControllers = [
            createMainViewController,
            UIViewController(),
            settingsNavigationController
        ]
    }
    
    private func setupCustomButton() {
        let rect: CGFloat = 84
        
        view.addSubview(customButton)
        
        customButtonBottomConstraint = customButton.bottomAnchor.constraint(
            equalTo: customTabBarView.bottomAnchor,
            constant: view.safeAreaInsets.bottom > 0 ? -30 : 0
        )
        
        NSLayoutConstraint.activate([
            customButtonBottomConstraint!,
            customButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customButton.widthAnchor.constraint(equalToConstant: rect),
            customButton.heightAnchor.constraint(equalToConstant: rect),
        ])
    }
    
    @objc private func handleTabBarButtonTap() {
        tabbarRouter.presentViewController()
    }
    
    private func setupGradient() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        view.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 152)
        ])
    }
    
    private func setupCustomTabBarFrame() {
        let height = self.view.safeAreaInsets.bottom + 56
        
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = self.view.frame.size.height - height
        
        self.tabBar.frame = tabFrame
        self.tabBar.setNeedsLayout()
        self.tabBar.layoutIfNeeded()
        customTabBarView.frame = tabBar.frame
    }
    
    private func setupTabBar() {

        
        let appearance = self.tabBar.standardAppearance
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.mainAccent,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.unactive,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.unactive
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.mainAccent
        self.tabBar.standardAppearance = appearance
    }
    
    private func addCustomTabBarView() {
        self.customTabBarView.frame = tabBar.frame
        
        self.customTabBarView.backgroundColor = .card
        self.customTabBarView.layer.cornerRadius = 32
        self.customTabBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.view.addSubview(customTabBarView)
        self.view.bringSubviewToFront(self.tabBar)
    }
}





//#if DEBUG
//@available(iOS 17.0, *)
//#Preview {
//   TabBarController()
//}
//#endif


