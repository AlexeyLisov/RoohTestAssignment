//
//  AvatarUICollectionViewCell.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI
import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImageCollectionViewCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage?, isSelected: Bool) {
        imageView.image = image
        contentView.transform = isSelected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
    }
}


#Preview(body: {
    UIViewPreview {
        
        let imageViewCell = AvatarCollectionViewCell()
        
        imageViewCell.configure(with: UIImage(systemName: "circle")!,
                                isSelected: false)
        return imageViewCell
    }
})



