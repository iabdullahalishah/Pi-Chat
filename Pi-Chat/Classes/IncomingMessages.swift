//
//  IncomingMessages.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 29/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            message = createVideoMessage(messageDictionary: messageDictionary)
        case kAUDIO:
            message = createAudioMessage(messageDictionary: messageDictionary)
        case kLOCATION:
            message = createLocationMessage(messageDictionary: messageDictionary)
        default:
            print("Unknown message type")
        }
        
        if message != nil {
            return message
        }
        return nil
    }
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        var date: Date!
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let text = messageDictionary[kMESSAGE] as! String
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
   func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
       
        var date: Date!
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        downloadImage(imageURL: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image
                self.collectionView.reloadData()
            }
            
        }
    return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let videoUrl = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        
        let mediaItem = VideoMessage(withFileUrl: videoUrl, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        downloadVideo(videoURL: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in
                if image != nil {
                mediaItem.image = image!
                self.collectionView.reloadData()
                }
            })
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        /*if senderId == FUser.currentId() {
            return true
        } else {
            return false
        }*/
        // same as above
        return senderId == FUser.currentId()
    }
    
    func createAudioMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        var date: Date!
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        let audioMessage = JSQMessage(senderId: userId!, displayName: name!, media: audioItem)
        downloadAudio(audioURL: messageDictionary[kAUDIO] as! String) { (fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            let audioData = try? Data(contentsOf: url as URL)
            audioItem.audioData = audioData
            self.collectionView.reloadData()
        }
        return  audioMessage!
    }
    
    func createLocationMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        var date: Date!
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let text = messageDictionary[kMESSAGE] as! String
        let lat = messageDictionary[kLATITUDE] as? Double
        let long = messageDictionary[kLONGITUDE] as? Double
        let mediaItem = JSQLocationMediaItem(location: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        let location = CLLocation(latitude: lat!, longitude: long!)
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
}
