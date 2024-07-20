//
//  ViewController.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 18/07/2024.
//

import UIKit
import SwiftUI
import Combine

struct CharacterModel: Codable {
    var avatarModel: AvatarModel
    var age: Int
    var height: Int
    var weight: Int
}

enum WatchConnectionError: Error {
    case sessionNotSupported
}

class MainViewModel: ObservableObject {
    @Published var age: Int = 0
    @Published var height: Int = 0
    @Published var weight: Int = 0
    
    @Published var sendingMessageStatusVisible: Bool = false
    
    var avatarCollectionViewModel: AvatarCollectionViewModel
    
    var alertPublisher = PassthroughSubject<WatchConnectionError, Never>()
    let watchService: WatchConnectivityServiceProtocol
    
    init(watchService: WatchConnectivityService = WatchConnectivityService()) {
        self.watchService = watchService
        self.avatarCollectionViewModel = AvatarCollectionViewModel.mock
    }
    
    func sendAvatarToAppleWatch() {
        
        sendingMessageStatusVisible = true
//        guard self.watchService.setupWCSession() else {
//            alertPublisher.send(.sessionNotSupported)
//            return
//        }
//        
//        let avatarModel = CharacterModel(avatarModel: avatarCollectionViewModel.avatarModel,
//                                         age: age, height: height, weight: weight)
//        
//        guard let encodedModel = try? JSONEncoder().encode(avatarModel) else {
//            print("Encoding failed")
//            return
//        }
//        
//        let message = ["characterModel": encodedModel]
//        
//        Task {
//            try await watchService.sendMessageToWatch(data: message)
//        }
        
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
    
    private var sendingMessageStatus: UITextView!
    private var sendingMessageStatusStackView: UIStackView!
    
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
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        sendingMessageStatusStackView = UIStackView(arrangedSubviews: [activityIndicator, sendingMessageStatus])//[activityIndicator, sendingMessageStatus])
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
            
            sendingMessageStatus.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let filledButton = UIButton(type: .system)
        
        // Set button title and appearance
        filledButton.setTitle("Filled Button", for: .normal)
        filledButton.setTitleColor(.white, for: .normal)
        filledButton.backgroundColor = UIColor.systemBlue
        filledButton.layer.cornerRadius = 10
        filledButton.layer.masksToBounds = true
        filledButton.translatesAutoresizingMaskIntoConstraints = false
        
        filledButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        self.view.addSubview(filledButton)
        
        NSLayoutConstraint.activate([
            sendingMessageStatusStackView.bottomAnchor.constraint(equalTo: filledButton.topAnchor, constant: -20),
            filledButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filledButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            filledButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            filledButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            filledButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
    }
    
    @objc func buttonTapped() {
        viewModel.sendAvatarToAppleWatch()
    }
    
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
        viewModel.$sendingMessageStatusVisible.sink { showSendingStatusView in
            UIView.transition(with: self.sendingMessageStatusStackView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.sendingMessageStatusStackView.isHidden = !showSendingStatusView
            })
        }
        .store(in: &cancellables)

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


