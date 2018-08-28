//
//  WelcomeViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 21/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import ProgressHUD
class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    //MARK: IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != "" {
            loginUser()
        } else {
            ProgressHUD.showError("Email and Password is missing")
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != "" && rPasswordTextField.text != ""{
            if passwordTextField.text == rPasswordTextField.text {
            registerUser()
            } else {
                ProgressHUD.showError("Passwords Dont Match")
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        rPasswordTextField.text = ""
    }
    
    func loginUser() {
        ProgressHUD.show("Login...")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.show(error!.localizedDescription)
                return
            }
            self.goToApp()
        }
    }
    
    func registerUser() {
        print("Registerd Successfully")
        dismissKeyboard()
        performSegue(withIdentifier: "welcomeToFinishRegisteration", sender: self)
        cleanTextFields()
    }
    
    func goToApp() {
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID  : FUser.currentId()])
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishRegisteration" {
            let vc = segue.destination as! FinishRegisterationViewController
            vc.email = emailTextField.text
            vc.password = passwordTextField.text
        }
    }
    
}
