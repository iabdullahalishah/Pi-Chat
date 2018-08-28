//
//  ProfileTableViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 28/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var cellNumberLabel: UILabel!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockUserOutlet: UIButton!
    @IBOutlet weak var avatarImageOutlet: UIImageView!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IBActions
    
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func blockUserTapped(_ sender: UIButton) {
        var currentBlockedUsers = FUser.currentUser()!.blockedUsers
        if currentBlockedUsers.contains(user!.objectId) {
            let index = currentBlockedUsers.index(of: user!.objectId)!
            currentBlockedUsers.remove(at: index)
        } else {
            currentBlockedUsers.append(user!.objectId)
        }
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedUsers]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                self.updateBlockStatus()
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    //MARK: Setup UI
    
    func setUpUi(){
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            cellNumberLabel.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage  != nil {
                    self.avatarImageOutlet.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        if user!.objectId != FUser.currentId() {
            blockUserOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockUserOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId){
            blockUserOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockUserOutlet.setTitle("Block User", for: .normal)
        }
    }

    

}
