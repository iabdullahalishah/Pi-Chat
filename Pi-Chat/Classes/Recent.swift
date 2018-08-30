//
//  Recent.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 28/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    var chatRoomId = ""
    let value = userId1.compare(userId2).rawValue
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    let members = [userId1, userId2]
    
    // Create recent chat
    createRecent(members: members, chatRoomId: chatRoomId, withUserName: "", type: kPRIVATE, users: [user1, user2], avatarOfGroup: nil)
    return chatRoomId
}

func createRecent(members: [String], chatRoomId: String, withUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    var tempMembers = members
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapShot, error) in
        guard let snapShot = snapShot else {return}
        if !snapShot.isEmpty {
            for recent in snapShot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserId = currentRecent[kUSERID] {
                    if tempMembers.contains(currentUserId as! String){
                        tempMembers.remove(at: tempMembers.index(of: currentUserId as! String)!)
                    }
                }
            }
        }
        for userId in tempMembers {
            // Create recent items
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserName: withUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
    }
}

func createRecentItems(userId: String, chatRoomId: String, members: [String], withUserUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    let date = dateFormatter().string(from: Date())
    var recent: [String : Any]!
    if type == kPRIVATE {
        var withUser: FUser?
        if users != nil && users!.count > 0 {
            if userId == FUser.currentId() {
                // for current user
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
        recent = [
            kRECENTID : recentId,
            kUSERID : userId,
            kCHATROOMID : chatRoomId,
            kMEMBERS : members,
            kMEMBERSTOPUSH : members,
            kWITHUSERFULLNAME : withUser!.fullname,
            kWITHUSERUSERID : withUser!.objectId,
            kLASTMESSAGE : "",
            kCOUNTER : 0,
            kDATE : date,
            kTYPE : type,
            kAVATAR : withUser!.avatar] as [String:Any]
    } else {
        if avatarOfGroup != nil {
            recent = [
                kRECENTID : recentId,
                kUSERID : userId,
                kCHATROOMID : chatRoomId,
                kMEMBERS : members,
                kMEMBERSTOPUSH : members,
                kWITHUSERUSERNAME : withUserUserName,
                kLASTMESSAGE : "",
                kCOUNTER : 0,
                kDATE : date,
                kTYPE : type,
                kAVATAR : avatarOfGroup!] as [String:Any]
        }
    }
    //save recent chat
    localReference.setData(recent)
}

    // Restart chat
func restartChat(recent: NSDictionary){
    if recent [kTYPE] as! String == kPRIVATE {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    
    if recent [kTYPE] as! String == kGROUP {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: recent[kWITHUSERUSERNAME] as! String, type: kGROUP , users: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
}

    //Delete Recent chat

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    if let recentID = recentChatDictionary[kRECENTID] {
        reference(.Recent).document(recentID as! String).delete()
    }
}
