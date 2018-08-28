//
//  FinishRegisterationViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 21/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegisterationViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // MARK: Variables
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBFunctions
    @IBAction func canButtonTapped(_ sender: UIButton) {
        cleanTextFields()
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                self.registerUser()
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    //MARK: HelperFunctions
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    
    func registerUser() {
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        var tempDictionary: Dictionary = [
            kFIRSTNAME : nameTextField.text!,
            kLASTNAME : surnameTextField.text!,
            kFULLNAME : fullName,
            kCOUNTRY : countryTextField.text!,
            kCITY : cityTextField.text!,
            kPHONE : phoneTextField.text!
        ] as [String : Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text, lastName: surnameTextField.text) { (avatarInitials) in
                let avatarIMG = UIImageJPEGRepresentation(avatarInitials, 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                tempDictionary[kAVATAR] = avatar
                self.finishRegistration(withValues: tempDictionary)
            }
        } else {
            let avatarData = UIImageJPEGRepresentation(avatarImage!, 0.7)
            let avatar = avatarData!.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
            tempDictionary[kAVATAR]  = avatar
            self.finishRegistration(withValues: tempDictionary)
        }
    }
    
    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            // Go to app
            self.goToApp()
        }
    }
    
    func goToApp() {
        cleanTextFields()
        dismissKeyboard()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID  : FUser.currentId()])
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
}
