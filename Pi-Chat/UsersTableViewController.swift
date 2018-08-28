//
//  UsersTableViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 28/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTableViewController: UITableViewController, UISearchResultsUpdating, UserTableViewCellDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentedController: UISegmentedControl!
    var allUsers: [FUser] = []
    var filterUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: kCITY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return allUsersGroupped.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterUsers.count
        } else {
            // find section title
            let sectionTitle = self.sectionTitleList[section]
            // users for given title
            let users = self.allUsersGroupped[sectionTitle]
            return users!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
        }else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
            user = users![indexPath.row]
        }
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        cell.delegate = self
        return cell 
    }
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func loadUsers(filter: String) {
        ProgressHUD.show()
        var query: Query!
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapShot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapShot = snapShot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapShot.isEmpty {
                for userDictionary in snapShot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                // split groups
                self.splitDataIntoSections()
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    //MARK: Search Controller Functions
    
    func filterContent(searchText: String, scope: String = "All") {
        filterUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: searchController.searchBar.text!)
    }

    @IBAction func filterSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    //MARK: Helper functions
    
    fileprivate func splitDataIntoSections(){
        var sectionTitle = ""
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            let firstCharacter = currentUser.firstname.first!
            let firstCharString = "\(firstCharacter)"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.allUsersGroupped[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            self.allUsersGroupped[firstCharString]?.append(currentUser)
        }
    }
    
    //MARK: User TableView Cell Delegate
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
        }else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
            user = users![indexPath.row]
        }
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

}
