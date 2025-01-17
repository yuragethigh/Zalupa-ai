//
//  ListModeTVCell.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import UIKit

final class ListModeTVCell: UITableViewCell {
    
    static let identifier = String(describing: ListModeTVCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupLogoImageViewConstraints()
        setupLockImageViewConstraints()
        setupConstraints()
    }
    
    //MARK: - Private variables
    
    private let logoImageGradient: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .SFProText(weight: .semibold, size: 17)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.font = .SFProText(weight: .regular, size: 15)
        subTitleLabel.textColor = .textSecondary
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subTitleLabel
    }()
    
    private let chevronImageView: UIImageView = {
        let chvronImageView = UIImageView()
        chvronImageView.image = .chevroneRight
        chvronImageView.translatesAutoresizingMaskIntoConstraints = false
        return chvronImageView
    }()
    
    private let devider: UIView = {
        let devider = UIView()
        devider.backgroundColor = .topStroke
        devider.translatesAutoresizingMaskIntoConstraints = false
        return devider
    }()
    
    private let lockImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .lock
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Private methods
    
    private func setupConstraints() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(devider)
        
        NSLayoutConstraint.activate([
           
            
            titleLabel.leadingAnchor.constraint(equalTo: logoImageGradient.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),

            chevronImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            devider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            devider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            devider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 83),
            devider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func setupLogoImageViewConstraints() {
        contentView.addSubview(logoImageGradient)
        NSLayoutConstraint.activate([
            logoImageGradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            logoImageGradient.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageGradient.heightAnchor.constraint(equalToConstant: 45),
            logoImageGradient.widthAnchor.constraint(equalToConstant: 45),
        ])
        
        
        logoImageGradient.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: logoImageGradient.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: logoImageGradient.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: logoImageGradient.trailingAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: logoImageGradient.bottomAnchor)
        ])
    }
    
    private func setupLockImageViewConstraints() {
        logoImageView.addSubview(lockImage)
        NSLayoutConstraint.activate([
            lockImage.widthAnchor.constraint(equalToConstant: 20),
            lockImage.heightAnchor.constraint(equalToConstant: 20),
            lockImage.topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -3.5),
            lockImage.trailingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 3.5),
        ])
    }
    
    
    private var isPremium: Bool = false
    private var backgroundColors: AssistantsColors?
    
    //MARK: - Public methods
    
    func configure(_ item: AssistantsConfiguration, isPremium: Bool) {
        self.logoImageView.kf.setImage(with: item.imageAvatar)
        self.titleLabel.text = item.name
        self.subtitleLabel.text = item.title
        self.isPremium = isPremium || item.freeAssistant
        self.lockImage.isHidden = self.isPremium
        self.backgroundColors = item.backgroundColor

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentColors: [UIColor]? {
        if let bgcolors = backgroundColors, !bgcolors.color1.isEmpty {
            let isNotPremium = [
                UIColor.hex("C0C0C0"),
                UIColor.hex("282828")
            ]
            let premium = [
                UIColor.hex(bgcolors.color1),
                UIColor.hex(bgcolors.color2)
            ]
            return isPremium ? premium : isNotPremium
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        logoImageGradient.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        if let currentColors = currentColors {
            logoImageGradient.applyGradient(
                colours: currentColors,
                cornerRadius: 22,
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: 1)
            )
        }
    }

}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    TabBarController()
}
#endif
