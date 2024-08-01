//
//  CharacteristicView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 01/08/2024.
//

import UIKit
import Combine

class CharacteristicView: UIView {
    private (set) var textField: UITextField!
    private (set) var textLabel: UILabel!
    private (set) var errorLabel: UILabel!
    
    private var stackView: UIStackView!
    private var doneToolbar: UIToolbar!
    
    lazy var textFieldPublisher: AnyPublisher<String, Never> = {
        textField.textPublisher
    }()
    
    private func generateTextField(placeHolder: String) -> UITextField {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.placeholder = placeHolder
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.inputAccessoryView = doneToolbar
        textField.delegate = self
        return textField
    }
    
    private func generateTextLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func generateErrorLabel() -> UILabel {
        let label = UILabel()
        label.text = ""
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }
    
    convenience init(name: String, doneToolbar: UIToolbar) {
        self.init(frame: .zero)
        self.doneToolbar = doneToolbar
        
        textLabel = generateTextLabel(text: name)
        textField = generateTextField(placeHolder: name)
        errorLabel = generateErrorLabel()
        
        configure()
        constraint()
        
    }
    
    func configure(){
        stackView = UIStackView(arrangedSubviews: [textLabel, textField, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
    }
    
    
    func constraint() {
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 30),
            textField.heightAnchor.constraint(equalToConstant: 30),
            errorLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




// MARK: UITextFieldDelegate
extension CharacteristicView: UITextFieldDelegate {
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
