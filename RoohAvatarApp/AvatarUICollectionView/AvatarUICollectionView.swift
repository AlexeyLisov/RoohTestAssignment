//
//  AvatarUICollectionView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI
import UIKit


class AvatarCollectionViewController: UIViewController {
    
    private var viewModel: AvatarCollectionViewModel!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupViewModel()
        setupCollectionView()
    }
    
    func setupViewModel(viewModel: AvatarCollectionViewModel) {
        self.viewModel = viewModel
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
        collectionView.scrollToItem(at: viewModel.selectedIndexPath, at: .centeredHorizontally, animated: true)
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


extension AvatarCollectionViewModel {
    static var mock: AvatarCollectionViewModel = {
        let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
        return AvatarCollectionViewModel(images: images)
    }()
}

#Preview {
    UIViewControllerPreview {
        let vc = AvatarCollectionViewController()
        vc.setupViewModel(viewModel: AvatarCollectionViewModel.mock)
        return vc
    }
}
