//
//  RecentChatTableViewCell.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 28/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}
class RecentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var messagesCounterLabel: UILabel!
    var indexPath: IndexPath!
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Generate Cell
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.messagesCounterLabel.text = recentChat[kCOUNTER] as? String
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messagesCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
        } else {
            self.messagesCounterLabel.isHidden = true
        }
        var date: Date!
        if let created = recentChat[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        self.dataLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }

}
