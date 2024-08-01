//
//  MessageSendingStatusView.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 01/08/2024.
//

import UIKit


class MessageSendingStatusView: UIView {
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        
        return activityIndicator
    }()
    
    private lazy var successView: UIImageView = {
        let successView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")!)
        successView.contentMode = .scaleAspectFit
        successView.tintColor = .systemGreen
        
        return successView
    }()
    
    private lazy var sendingMessageStatus: UITextView = {
        let sendingMessageStatus = UITextView()
        sendingMessageStatus.text = "Establishing connection with Apple Watch"
        sendingMessageStatus.textAlignment = .center
        sendingMessageStatus.font = UIFont.preferredFont(forTextStyle: .body)
        sendingMessageStatus.backgroundColor = .clear
        return sendingMessageStatus
    }()
    
    private lazy var sendingMessageStatusStackView: UIStackView = {
        
        sendingMessageStatusStackView = UIStackView(arrangedSubviews: [successView, activityIndicator, sendingMessageStatus])
        sendingMessageStatusStackView.translatesAutoresizingMaskIntoConstraints = false
        sendingMessageStatusStackView.axis = .vertical
        sendingMessageStatusStackView.spacing = 5
        sendingMessageStatusStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        sendingMessageStatusStackView.isLayoutMarginsRelativeArrangement = true
        
        sendingMessageStatusStackView.layer.cornerRadius = 10
        sendingMessageStatusStackView.layer.borderColor = UIColor.gray.cgColor
        sendingMessageStatusStackView.layer.borderWidth = 1
        sendingMessageStatusStackView.layer.masksToBounds = true
        
        return sendingMessageStatusStackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.addSubview(sendingMessageStatusStackView)
    }
    
    func constrain() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendingMessageStatusStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            sendingMessageStatusStackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            sendingMessageStatusStackView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.heightAnchor.constraint(equalToConstant: 100),
            
            successView.heightAnchor.constraint(equalToConstant: 30),
            successView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    var successId: UUID = UUID()
    
}

extension MessageSendingStatusView {
    
    func setNotRequested() {
        self.sendingMessageStatusStackView.isHidden = true
    }
    
    func setCreatingSession() {
        showView()
        self.successView.isHidden = true
        self.activityIndicator.startAnimating()
        self.sendingMessageStatus.text = "Creating session"
    }
    
    func setSendingMessage() {
        
        showView()
        self.successView.isHidden = true
        self.activityIndicator.startAnimating()
        self.sendingMessageStatus.text = "Sending message"
    }
    
    func setSuccess() {
        showView()
        self.successView.isHidden = false
        self.activityIndicator.stopAnimating()
        self.sendingMessageStatus.text = "Character sent successfully"
        
        self.successId = UUID()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [successId] in
            if successId == self.successId {
                self.hideView()
            }
        }
    }
}

extension MessageSendingStatusView {
    func showView() {
        if self.sendingMessageStatusStackView.isHidden {
            self.sendingMessageStatusStackView.transform = CGAffineTransform(translationX: -self.sendingMessageStatusStackView.frame.width, y: 0)
            self.sendingMessageStatusStackView.isHidden = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.sendingMessageStatusStackView.transform = .identity
            })
        }
        
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sendingMessageStatusStackView.transform = CGAffineTransform(translationX: self.sendingMessageStatusStackView.frame.width, y: 0)
        }) { _ in
            self.sendingMessageStatusStackView.isHidden = true
            self.sendingMessageStatusStackView.transform = .identity // Reset transform for future use
        }
    }
}
