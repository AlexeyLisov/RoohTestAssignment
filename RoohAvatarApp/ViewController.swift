//
//  ViewController.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 18/07/2024.
//

import UIKit
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var age: String = ""
    @Published var height: String = ""
    @Published var weight: String = ""
    
    func sendAvatarToAppleWatch() {
        
    }
}


import UIKit
import Combine

class ViewController: UIViewController {
    
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
    
    private var ageTextField: UITextField!
    private var heightTextField: UITextField!
    private var weightTextField: UITextField!
    
    private var ageLabel: UILabel!
    private var heightLabel: UILabel!
    private var weightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        
        let collectionViewController = ImageCollectionViewController()
        
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
            .assign(to: \.age, on: viewModel)
            .store(in: &cancellables)
        
        heightTextField.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.height, on: viewModel)
            .store(in: &cancellables)
        
        weightTextField.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.weight, on: viewModel)
            .store(in: &cancellables)

    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text
        
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
        let vc = ViewController()
        return vc
    }
})


