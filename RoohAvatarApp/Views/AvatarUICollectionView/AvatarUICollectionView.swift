//
//  AvatarUICollectionView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI
import UIKit
import Combine

class AvatarCollectionViewController: UIViewController {
    
    private var viewModel: AvatarCollectionViewModel!
    private var collectionView: UICollectionView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private let cellWidth: CGFloat = 250
    private let cellHeight: CGFloat = 250
    
    private func setupCollectionView() {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
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
        ])
    }
    
    
}

// MARK: Scroll behavior

extension AvatarCollectionViewController {
    private func scrollToSelectedItem() {
        collectionView.scrollToItem(at: viewModel.selectedIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func itemIndexClosestToCenter() -> IndexPath? {
        let centerPoint = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
        
        var closestCellIndex: IndexPath?
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        
        for cell in collectionView.visibleCells {
            let cellCenter = cell.frame.midX
            let distance = abs(centerPoint.x - cellCenter)
            
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = collectionView.indexPath(for: cell)
            }
        }
        return closestCellIndex
    }
    
    private func selectItemClosestToCenter() {
        
        if let indexPath = itemIndexClosestToCenter() {
            withAnimation {
                viewModel.selectItem(at: indexPath)
            }
        } else {
            print("Warning: index path for closest cell not found")
        }
    }
}

// MARK: View Model

extension AvatarCollectionViewController {
    func setupViewModel(viewModel: AvatarCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    func setupSubscriptions() {
        self.viewModel.$selectedIndexPath
            .sink { [weak self] index in
                self?.collectionView.scrollToItem(at: index,
                                                  at: .centeredHorizontally, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: View Cycle

extension AvatarCollectionViewController {
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.scrollToItem(at: self.viewModel.selectedIndexPath,
                                         at: .centeredHorizontally, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension AvatarCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCollectionViewCell.identifier, for: indexPath) as? AvatarCollectionViewCell else {
            return UICollectionViewCell()
        }
        let image = viewModel.image(for: indexPath)
        let isSelected = viewModel.isSelectedItem(at: indexPath)
        cell.configure(with: image, isSelected: isSelected)
        return cell
    }
    
}

// MARK: UIScrollViewDelegate
extension AvatarCollectionViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectItemClosestToCenter()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectItemClosestToCenter()
        }
    }
    
}

// MARK: UICollectionViewDelegate
extension AvatarCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        collectionView.reloadData()
        scrollToSelectedItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = (collectionView.frame.width - 100) / 2
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
}

extension AvatarCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

#Preview {
    UIViewControllerPreview {
        let vc = AvatarCollectionViewController()
        vc.setupViewModel(viewModel: AvatarCollectionViewModel.mock)
        return vc
    }
    .frame(height: 300)
}
