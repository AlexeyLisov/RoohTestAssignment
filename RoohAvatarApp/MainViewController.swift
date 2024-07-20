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

struct CharacterModel: Codable {
    var avatarModel: AvatarModel
    var age: Int
    var height: Int
    var weight: Int
}


enum SendingMessageStatus {
    case notRequested
    case creatingSession
    case sendingMessage
    case error(WCError)
    case success
}

class MainViewModel: ObservableObject {
    @Published var age: Int = 0
    @Published var height: Int = 0
    @Published var weight: Int = 0
    
    @Published var sendingMessageStatus: SendingMessageStatus = .notRequested
    
    var avatarCollectionViewModel: AvatarCollectionViewModel
    
//    var alertPublisher = PassthroughSubject<SendingMessageStatus, Never>()
    let watchService: WatchConnectivityServiceProtocol
    
    init(watchService: WatchConnectivityService = WatchConnectivityService()) {
        self.watchService = watchService
        self.avatarCollectionViewModel = AvatarCollectionViewModel.mock
    }
    
    func sendAvatarToAppleWatch() {
        
        sendingMessageStatus = .creatingSession
        guard self.watchService.setupWCSession() else {
            sendingMessageStatus = .error(.init(.sessionNotSupported))
//            alertPublisher.send(.error(.sessionNotSupported))
            sendingMessageStatus = .notRequested
            return
        }
        
        let avatarModel = CharacterModel(avatarModel: avatarCollectionViewModel.avatarModel,
                                         age: age, height: height, weight: weight)
        
        guard let encodedModel = try? JSONEncoder().encode(avatarModel) else {
            print("Encoding failed")
            return
        }
        
        let message = ["characterModel": encodedModel]
        
        Task {
            await self.watchService.activateSession()
            
            await MainActor.run {
                sendingMessageStatus = .sendingMessage
            }
            
            do {
                try await self.watchService.sendMessageToWatch(data: message)
            } catch let error as WCError {
//                alertPublisher.send(.error(error.code))
                sendingMessageStatus = .error(error)
                return
            }
            
            await MainActor.run {
                sendingMessageStatus = .success
            }
        }
        
    }
}


import UIKit
import Combine

class MainViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    func generateDoneToolbar(textfield: UITextField) -> UIToolbar {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.barStyle = .default
        
        return doneToolbar
    }
    
    @objc func doneButtonAction() {
        
        if ageTextField.isFirstResponder {
            heightTextField.becomeFirstResponder()
        } else if heightTextField.isFirstResponder {
            weightTextField.becomeFirstResponder()
        } else if weightTextField.isFirstResponder {
            weightTextField.resignFirstResponder()
        }
    }
    

    private func generateTextField(placeHolder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeHolder
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.inputAccessoryView = generateDoneToolbar(textfield: textField)
        textField.delegate = self
        return textField
    }
    
    private func generateTextLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private var collectionViewController = AvatarCollectionViewController()
    
    private var ageTextField: UITextField!
    private var heightTextField: UITextField!
    private var weightTextField: UITextField!
    
    private var ageLabel: UILabel!
    private var heightLabel: UILabel!
    private var weightLabel: UILabel!
    
    private var activityIndicator: UIActivityIndicatorView!
    private var successView: UIImageView!
    private var sendingMessageStatus: UITextView!
    private var sendingMessageStatusStackView: UIStackView!
    
    private var sendCharacterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupViewModels()
    }
    
    private func setupViewModels() {
        self.collectionViewController.setupViewModel(viewModel: viewModel.avatarCollectionViewModel)
    }
    
    private func setupUI() {
        
        self.addChild(collectionViewController)
        collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionViewController.view)
        collectionViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            collectionViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            collectionViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionViewController.view.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        self.ageLabel = generateTextLabel(text: "Age")
        self.heightLabel = generateTextLabel(text: "Height")
        self.weightLabel = generateTextLabel(text: "Weight")
        
        self.ageTextField = generateTextField(placeHolder: "Age")
        self.heightTextField = generateTextField(placeHolder: "Height")
        self.weightTextField = generateTextField(placeHolder: "Weight")
        
        view.backgroundColor = .white
        
        let ageStackView = UIStackView(arrangedSubviews: [ageLabel, ageTextField])
        ageStackView.axis = .horizontal
        ageStackView.spacing = 10
        ageStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightStackView = UIStackView(arrangedSubviews: [heightLabel, heightTextField])
        heightStackView.axis = .horizontal
        heightStackView.spacing = 10
        heightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let weightStackView = UIStackView(arrangedSubviews: [weightLabel, weightTextField])
        weightStackView.axis = .horizontal
        weightStackView.spacing = 10
        weightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStackView = UIStackView(arrangedSubviews: [ageStackView, heightStackView, weightStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ageTextField.widthAnchor.constraint(equalToConstant: 100),
            heightTextField.widthAnchor.constraint(equalToConstant: 100),
            weightTextField.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        sendingMessageStatus = UITextView()
        sendingMessageStatus.text = "Establishing connection with Apple Watch"
        sendingMessageStatus.textAlignment = .center
        sendingMessageStatus.font = UIFont.preferredFont(forTextStyle: .body)
        sendingMessageStatus.backgroundColor = .clear
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        successView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")!)
        successView.contentMode = .scaleAspectFit
        successView.tintColor = .systemGreen
        
        successView.isHidden = true
        
        sendingMessageStatusStackView = UIStackView(arrangedSubviews: [successView, activityIndicator, sendingMessageStatus])
        sendingMessageStatusStackView.translatesAutoresizingMaskIntoConstraints = false
        sendingMessageStatusStackView.axis = .vertical
        sendingMessageStatusStackView.spacing = 5
        sendingMessageStatusStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        sendingMessageStatusStackView.isLayoutMarginsRelativeArrangement = true
        
        sendingMessageStatusStackView.isHidden = true
        
        sendingMessageStatusStackView.layer.cornerRadius = 10
        sendingMessageStatusStackView.layer.borderColor = UIColor.gray.cgColor
        sendingMessageStatusStackView.layer.borderWidth = 1
        sendingMessageStatusStackView.layer.masksToBounds = true
        
        sendingMessageStatusStackView.isHidden = true
        view.addSubview(sendingMessageStatusStackView)
        
        NSLayoutConstraint.activate([
            sendingMessageStatusStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sendingMessageStatusStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            sendingMessageStatusStackView.heightAnchor.constraint(equalToConstant: 100),
            
            successView.heightAnchor.constraint(equalToConstant: 30),
            successView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        sendCharacterButton = UIButton(type: .system)
        
        // Set button title and appearance
        sendCharacterButton.setTitle("Filled Button", for: .normal)
        sendCharacterButton.setTitleColor(.white, for: .normal)
        sendCharacterButton.backgroundColor = UIColor.systemBlue
        sendCharacterButton.layer.cornerRadius = 10
        sendCharacterButton.layer.masksToBounds = true
        sendCharacterButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendCharacterButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        self.view.addSubview(sendCharacterButton)
        
        NSLayoutConstraint.activate([
            sendingMessageStatusStackView.bottomAnchor.constraint(equalTo: sendCharacterButton.topAnchor, constant: -20),
            sendCharacterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendCharacterButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            sendCharacterButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            sendCharacterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            sendCharacterButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
    }
    
    @objc func buttonTapped() {
        viewModel.sendAvatarToAppleWatch()
    }
    
//    private func
    
    private func setupBindings() {
        ageTextField.textPublisher
            .receive(on: RunLoop.main)
            .map({ Int($0) ?? 0 })
            .assign(to: \.age, on: viewModel)
            .store(in: &cancellables)
        
        heightTextField.textPublisher
            .receive(on: RunLoop.main)
            .map({ Int($0) ?? 0 })
            .assign(to: \.height, on: viewModel)
            .store(in: &cancellables)
        
        weightTextField.textPublisher
            .receive(on: RunLoop.main)
            .map({ Int($0) ?? 0 })
            .assign(to: \.weight, on: viewModel)
            .store(in: &cancellables)
        
        // TODO: check ref cycle
        
        viewModel.$sendingMessageStatus
            .debounce(for: 0.3, scheduler: RunLoop.main).sink { status in
            UIView.transition(with: self.sendingMessageStatusStackView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                switch status {
                case .notRequested:
                    self.sendingMessageStatusStackView.isHidden = true
                case .creatingSession:
                    self.sendCharacterButton.isEnabled = false
                    self.sendingMessageStatusStackView.isHidden = false
                    self.sendingMessageStatus.text = "Creating session"
                case .sendingMessage:
                    self.sendingMessageStatusStackView.isHidden = false
                    self.sendingMessageStatus.text = "Sending message"
                case .success:
                    self.sendingMessageStatusStackView.isHidden = false
                    self.sendingMessageStatus.text = "Character sent successfully"
                    self.sendCharacterButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.successView.isHidden = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.sendingMessageStatusStackView.isHidden = true
                    }
                case .error(let error):
                    self.handleError(error: error)
                }
            })
        }
        .store(in: &cancellables)
    }
    
    private func handleError(error: WCError) {
        presentAlert(message: error.localizedDescription)
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", 
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let first = string.first, first == "0", range.lowerBound == 0 {
            return false
        }
        
        return true
    }
}

private extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}


#Preview(body: {
    UIViewControllerPreview {
        let vc = MainViewController()
        return vc
    }
})


