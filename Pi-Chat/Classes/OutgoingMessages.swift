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
    
    //for audio
    init(message: String, audioLink: String, SenderId: String, senderName: String, date: Date, status: String, type: String){
        messageDictionary = NSMutableDictionary(objects: [message, audioLink, SenderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kAUDIO as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying,kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //for video
    init(message: String, videoLink: String, thumbNail: NSData, SenderId: String, senderName: String, date: Date, status: String, type: String){
        let videoThumb = thumbNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, videoLink, videoThumb, SenderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying,kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //for location
    init(message: String, lat: NSNumber, long: NSNumber, SenderId: String, senderName: String, date: Date, status: String, type: String){
        messageDictionary = NSMutableDictionary(objects: [message, lat, long, SenderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kLATITUDE as NSCopying, kLONGITUDE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying,kSTATUS as NSCopying, kTYPE as NSCopying])
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
    
    class func deleteMessage(withId: String, chatRoomId: String) {
        
    }
    
    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        let readDate = dateFormatter().string(from: Date())
        let values = [kSTATUS : kREAD, kREADDATE: readDate]
        for userId in memberIds {
            reference(.Message).document(userId).collection(chatRoomId).document(withId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if snapshot.exists {
                    reference(.Message).document(userId).collection(chatRoomId).document(withId).updateData(values)
                }
            }
        }
    }
    
}
