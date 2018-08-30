//
//  OutgoingMessages.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 29/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation
class OutgoingMessages {
    let messageDictionary: NSMutableDictionary
    // for text message
    init(message: String, SenderId: String, senderName: String, date: Date, status: String, type: String){
        messageDictionary = NSMutableDictionary(objects: [message, SenderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying,kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //for picture
    init(message: String, pictureLink: String, SenderId: String, senderName: String, date: Date, status: String, type: String){
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, SenderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying,kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: Send Message
    func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, memberIDs: [String], membersToPush: [String]){
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIDs {
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String : Any])
        }
        // Update recent chat
        
        //send push notification
    }
    
    
    
    
    
}
