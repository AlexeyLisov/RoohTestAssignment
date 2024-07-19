//
//  AvatarUICollectionView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI
import UIKit


struct AvatarModel {
    let imageName: String
}

class AvatarCollectionViewModel {
    private var images: [AvatarModel]
    private(set) var selectedIndexPath: IndexPath?
    
    init(images: [AvatarModel]) {
        self.images = images
        self.selectedIndexPath = IndexPath(item: 0, section: 0)
    }
    
    func numberOfItems() -> Int {
        return images.count
    }
    
    func image(for indexPath: IndexPath) -> UIImage? {
        let imageName = images[indexPath.item].imageName
        return UIImage(systemName: imageName)
    }
    
    func selectItem(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func isSelectedItem(at indexPath: IndexPath) -> Bool {
        return selectedIndexPath == indexPath
    }
}

class AvatarCollectionViewController: UIViewController {
    private var viewModel: AvatarCollectionViewModel!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupCollectionView()
    }
    
    private func setupViewModel() {
        
        let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
        viewModel = AvatarCollectionViewModel(images: images)
    }
    
    private func setupCollectionView() {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AvatarCollectionViewCell.self, forCellWithReuseIdentifier: AvatarCollectionViewCell.identifier)
        
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    private func scrollToSelectedItem() {
        guard let selectedIndexPath = viewModel.selectedIndexPath else { return }
        collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func selectItemClosestToCenter() {
        let centerPoint = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            withAnimation {
                viewModel.selectItem(at: indexPath)
                collectionView.reloadData()
            }
            
        }
    }
    
    private let cellWidth: CGFloat = 100
    private let cellHeight: CGFloat = 100
    private let minimumInteritemSpacing: CGFloat = 10
}

extension AvatarCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCollectionViewCell.identifier, for: indexPath) as! AvatarCollectionViewCell
        let image = viewModel.image(for: indexPath)
        let isSelected = viewModel.isSelectedItem(at: indexPath)
        cell.configure(with: image, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        collectionView.reloadData()
        scrollToSelectedItem()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = (collectionView.frame.width - 100) / 2
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectItemClosestToCenter()
        scrollToSelectedItem()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectItemClosestToCenter()
            scrollToSelectedItem()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectItemClosestToCenter()
    }
}


#Preview {
    UIViewControllerPreview {
        let vc = AvatarCollectionViewController()
        return vc
    }
}
