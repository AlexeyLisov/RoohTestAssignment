//
//  ViewController.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 18/07/2024.
//

import UIKit
import SwiftUI
import Combine
import WatchConnectivity



class MainViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var ageStackView: CharacteristicView = {
        CharacteristicView(name: "Age", doneToolbar: generateDoneToolbar())
    }()
    
    private lazy var heightStackView: CharacteristicView = {
        CharacteristicView(name: "Height", doneToolbar: generateDoneToolbar())
    }()
    
    private lazy var weightStackView: CharacteristicView = {
        CharacteristicView(name: "Weight", doneToolbar: generateDoneToolbar())
    }()
    
    private var collectionViewController = AvatarCollectionViewController()
   
    private lazy var messageSendingStatusView: MessageSendingStatusView = {
        return MessageSendingStatusView()
    }()
    
    private var sendCharacterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModels()
        setupBindings()
    }
    
    private func setupViewModels() {
        self.collectionViewController.setupViewModel(viewModel: viewModel.avatarCollectionViewModel)
        
        self.viewModel.setInitialValues()
    }
    
    private func handleError(error: WCError) {
        presentAlert(message: error.localizedDescription)
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", 
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", 
                                                style: .default,
                                                handler: { _ in }))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: Button Actions
extension MainViewController {
    @objc func doneButtonAction() {
        if ageStackView.textField.isFirstResponder {
            heightStackView.textField.becomeFirstResponder()
        } else if heightStackView.textField.isFirstResponder {
            weightStackView.textField.becomeFirstResponder()
        } else if weightStackView.textField.isFirstResponder {
            weightStackView.textField.resignFirstResponder()
        }
    }
    
    @objc func buttonTapped() {
        viewModel.sendAvatarToAppleWatch()
    }
}

// MARK: Bindings
extension MainViewController {
    private var ageInteger: AnyPublisher<Int, Never> {
        ageStackView.textFieldPublisher
            .map({ Int($0) ?? 0 })
            .eraseToAnyPublisher()
    }
    
    private var ageOutOfRange: AnyPublisher<Bool, Never> {
        ageInteger
            .map({ !CharacterModel.ageAllowedRange.contains($0) })
            .eraseToAnyPublisher()
    }
    
    private var heightInteger: AnyPublisher<Int, Never> {
        heightStackView.textFieldPublisher
            .map({ Int($0) ?? 0 })
            .eraseToAnyPublisher()
    }
    
    private var heightOutOfRange: AnyPublisher<Bool, Never> {
        heightInteger
            .map({ !CharacterModel.heightAllowedRange.contains($0) })
            .eraseToAnyPublisher()
    }
    
    private var weightInteger: AnyPublisher<Int, Never> {
        weightStackView.textFieldPublisher
            .map({ Int($0) ?? 0 })
            .eraseToAnyPublisher()
    }
    
    private var weightOutOfRange: AnyPublisher<Bool, Never> {
        weightInteger
            .map({ !CharacterModel.weightAllowedRange.contains($0) })
            .eraseToAnyPublisher()
    }
    
    private func setupBindings() {
        collectionViewController.setupSubscriptions()
        
        ageInteger
            .receive(on: DispatchQueue.main)
            .assign(to: \.age, on: viewModel)
            .store(in: &cancellables)
        
        ageOutOfRange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outOfRange in
                self?.ageStackView.errorLabel.text = outOfRange ? "Age out of range: \( CharacterModel.ageAllowedRange)" : ""
            }
            .store(in: &cancellables)
        
        heightInteger
            .receive(on: DispatchQueue.main)
            .assign(to: \.height, on: viewModel)
            .store(in: &cancellables)
        
        heightOutOfRange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outOfRange in
                self?.heightStackView.errorLabel.text = outOfRange ? "Height out of range: \( CharacterModel.heightAllowedRange)" : ""
            }
            .store(in: &cancellables)
        
        weightInteger
            .receive(on: DispatchQueue.main)
            .assign(to: \.weight, on: viewModel)
            .store(in: &cancellables)
        
        weightOutOfRange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outOfRange in
                self?.weightStackView.errorLabel.text = outOfRange ? "Weight out of range: \( CharacterModel.weightAllowedRange)" : ""
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(ageOutOfRange.merge(with: Just(false)),
                                  weightOutOfRange.merge(with: Just(false)),
                                  heightOutOfRange.merge(with: Just(false)))
        .map { $0 || $1 || $2 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] anyValueOutOfRange in
            self?.sendCharacterButton.isEnabled = !anyValueOutOfRange
        }
        .store(in: &cancellables)
        
        viewModel.$age
            .map({String($0)})
            .assign(to: \.ageStackView.textField.text, on: self)
            .store(in: &cancellables)
        
        viewModel.$height
            .map({String($0)})
            .assign(to: \.heightStackView.textField.text, on: self)
            .store(in: &cancellables)
        
        viewModel.$weight
            .map({String($0)})
            .assign(to: \.weightStackView.textField.text, on: self)
            .store(in: &cancellables)
        
        viewModel.$sendingMessageStatus
            .debounce(for: 0.1, scheduler: DispatchQueue.main).sink { [weak self] status in
                
                guard let self else { return }
                
//                UIView.animate(withDuration: 0.2) {
                    switch status {
                    case .notRequested:
                        self.messageSendingStatusView.setNotRequested()
                    case .creatingSession:
                        self.messageSendingStatusView.setCreatingSession()
                        self.sendCharacterButton.isEnabled = false
                    case .sendingMessage:
                        self.messageSendingStatusView.setSendingMessage()
                        self.sendCharacterButton.isEnabled = false
                    case .success:
                        self.messageSendingStatusView.setSuccess()
                        self.sendCharacterButton.isEnabled = true
                        
                    case .error(let error):
                        self.sendCharacterButton.isEnabled = true
                        self.handleError(error: error)
                    }
//                }
            }
            .store(in: &cancellables)
    }
}

// MARK: UI
extension MainViewController {
    private func setup() {}
    private func setupUI() {
        
        self.addChild(collectionViewController)
        collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionViewController.view)
        collectionViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            collectionViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            collectionViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionViewController.view.heightAnchor.constraint(equalToConstant: 300),
        ])
        
        view.backgroundColor = .white
        
        
        let characteristicsStackView = UIStackView(arrangedSubviews: [ageStackView, heightStackView, weightStackView])
        characteristicsStackView.axis = .horizontal
        characteristicsStackView.spacing = 20
        characteristicsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(characteristicsStackView)
        
        NSLayoutConstraint.activate([
            characteristicsStackView.topAnchor.constraint(equalTo: collectionViewController.view.bottomAnchor, constant: 20),
            characteristicsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            characteristicsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            characteristicsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characteristicsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            characteristicsStackView.heightAnchor.constraint(equalToConstant: 110),
            
            ageStackView.widthAnchor.constraint(equalTo: heightStackView.widthAnchor),
            heightStackView.widthAnchor.constraint(equalTo: weightStackView.widthAnchor),
            
        ])
        
        setupUIForButtonAndMessageStatusView()
        
    }
    
    func setupUIForButtonAndMessageStatusView(){
        sendCharacterButton = UIButton(type: .system)
        
        // Set button title and appearance
        sendCharacterButton.setTitle("Send to Apple Watch", for: .normal)
        sendCharacterButton.setTitleColor(.white, for: .normal)
        sendCharacterButton.backgroundColor = UIColor.systemBlue
        sendCharacterButton.layer.cornerRadius = 10
        sendCharacterButton.layer.masksToBounds = true
        sendCharacterButton.translatesAutoresizingMaskIntoConstraints = false
        sendCharacterButton.setTitleColor(.lightGray, for: .disabled)
        
        sendCharacterButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        self.view.addSubview(sendCharacterButton)
        self.view.addSubview(messageSendingStatusView)
        
        NSLayoutConstraint.activate([
            messageSendingStatusView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            messageSendingStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageSendingStatusView.bottomAnchor.constraint(equalTo: sendCharacterButton.topAnchor, constant: -20),
            
            sendCharacterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendCharacterButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            sendCharacterButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            sendCharacterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendCharacterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
}

extension MainViewController {
    func generateDoneToolbar() -> UIToolbar {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done,
                                                    target: self,
                                                    action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.barStyle = .default
        
        return doneToolbar
    }
}


// MARK: View Cycle
extension MainViewController {
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await self.viewModel.watchService.activateSession()
        }
    }
}


#Preview(body: {
    UIViewControllerPreview {
        let vc = MainViewController()
        return vc
    }
})


