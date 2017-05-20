//
//  LoginViewController.swift
// Pearl
//
//  Created by Jasen Henderson on 5/16/17.
//  Copyright © 2017 Otter. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

// Keychain Configuration
struct KeychainConfiguration {
    static let serviceName = "OtterPearl"
    static let accessGroup: String? = nil
}




class TouchIDAuth {
    let context = LAContext()
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) { // 1
        // 2
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        // 3
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Logging in with Touch ID") { (success, evaluateError) in
                                // 4
                                if success {
                                    DispatchQueue.main.async {
                                        // User authenticated successfully, take appropriate action
                                        completion(nil)
                                    }
                                } else {
                                    // 1
                                    let message: String
                                    
                                    // 2
                                    switch evaluateError {
                                    // 3
                                    case LAError.authenticationFailed?:
                                        message = "There was a problem verifying your identity."
                                    case LAError.userCancel?:
                                        message = "You pressed cancel."
                                    case LAError.userFallback?:
                                        message = "You pressed password."
                                    default:
                                        message = "Touch ID may not be configured"
                                    }
                                    // 4
                                    completion(message)
                                }
        }
    }
}


class UserLoginViewController: UIViewController {
    
    @IBAction func loginUnwind(unwindSegue: UIStoryboardSegue) {}
    
    let touchMe = TouchIDAuth()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    @IBOutlet weak var createInfoLabel: UILabel!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    @IBOutlet weak var touchIDButton: UIButton!
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        
        loginButton.layer.cornerRadius = 10
        
        // 1
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        // 2
        if hasLogin {
            loginButton.setTitle("Login", for: .normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        } else {
            loginButton.setTitle("Create", for: .normal)
            loginButton.tag = createLoginButtonTag
            createInfoLabel.isHidden = false
        }
        
        // 3
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
    }
    
    
    @IBAction func loginAction1(_ sender: AnyObject) {
    
    
        
        
        // 1
        // Check that text has been entered into both the username and password fields.
        guard
            let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty &&
                !newPassword.isEmpty else {
                    
                    let alertView = UIAlertController(title: "Login Problem",
                                                      message: "Wrong username or password.",
                                                      preferredStyle:. alert)
                    let okAction = UIAlertAction(title: "Foiled Again!", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    present(alertView, animated: true, completion: nil)
                    return
        }
        
        // 2
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // 3
        if sender.tag == createLoginButtonTag {
            
            // 4
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(usernameTextField.text, forKey: "username")
            }
            
            // 5
            do {
                
                // This is a new account, create a new keychain item with the account name.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: newAccountName,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                
                // Save the password for the new item.
                try passwordItem.savePassword(newPassword)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            
            // 6
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            loginButton.tag = loginButtonTag
            
            performSegue(withIdentifier: "dismissLogin", sender: self)
            
        } else if sender.tag == loginButtonTag {
            
            // 7
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                performSegue(withIdentifier: "dismissLogin", sender: self)
            } else {
                // 8
                let alertView = UIAlertController(title: "Login Problem",
                                                  message: "Wrong username or password.",
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Foiled Again!", style: .default)
                alertView.addAction(okAction)
                present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    
    @IBAction func touchIDLoginAction(_ sender: Any) {
    
    
        
        // 1
        touchMe.authenticateUser() { message in
            
            // 2
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
                
            } else {
                // 3
                self.performSegue(withIdentifier: "dismissLogin", sender: self)
            }
        }
    }
    
    
    
    
    func checkLogin(username: String, password: String) -> Bool {
        
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        }
        catch {
            fatalError("Error reading password from keychain - \(error)")
        }
        
        return false
    }
    
}
