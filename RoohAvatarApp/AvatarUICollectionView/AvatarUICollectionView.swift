//
//  AvatarUICollectionView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI
import UIKit


struct ImageModel {
    let imageName: String
}

class ImageViewModel {
    private var images: [ImageModel]
    private(set) var selectedIndexPath: IndexPath?
    
    init(images: [ImageModel]) {
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

class ImageCollectionViewController: UIViewController {
    private var viewModel: ImageViewModel!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupCollectionView()
    }
    
    private func setupViewModel() {
        
        let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { ImageModel(imageName: $0) }
        viewModel = ImageViewModel(images: images)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
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
            viewModel.selectItem(at: indexPath)
            collectionView.reloadData()
        }
    }
}

extension ImageCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
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
        
        let isSelected = viewModel.isSelectedItem(at: indexPath)
        let width = collectionView.frame.width - (isSelected ? 0 : 60)  // Account for padding if needed
        let height = collectionView.frame.height - (isSelected ? 0 : 60)
        
        return CGSize(width: min(width, height), height: min(width, height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = (collectionView.frame.width - 100) / 2
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectItemClosestToCenter()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollToSelectedItem()
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width
        
        let estimatedIndex = targetContentOffset.pointee.x / cellWidthIncludingSpacing
        var index = round(estimatedIndex)
        
        if index < 0 {
            index = 0
        } else if index >= CGFloat(viewModel.numberOfItems()) {
            index = CGFloat(viewModel.numberOfItems() - 1)
        }
        
        print(index)
        
        targetContentOffset.pointee = CGPoint(x: index * cellWidthIncludingSpacing, y: targetContentOffset.pointee.y)
        
        viewModel.selectItem(at: IndexPath(item: Int(index), section: 0))
//        scrollToSelectedItem()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectItemClosestToCenter()
    }
}




#Preview {
    UIViewControllerPreview {
        let vc = ImageCollectionViewController()
        return vc
    }
}
