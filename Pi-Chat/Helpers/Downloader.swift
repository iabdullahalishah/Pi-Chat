//
//  Downloader.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 30/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//image
func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping(_ imageLink: String?) -> Void) {
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    let storageReference = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    let imageToStore = UIImageJPEGRepresentation(image, 0.7)
    var task: StorageUploadTask!
    task = storageReference.putData(imageToStore!, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        storageReference.downloadURL(completion: { (url, error) in
            guard let downloadURL = url else {completion(nil); return}
            completion(downloadURL.absoluteString)
        })
    })
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

func downloadImage(imageURL: String, completion: @escaping(_ image: UIImage?) -> Void) {
    let imageUrl = NSURL(string: imageURL)
    print("Image url is \(String(describing: imageUrl))")
    let imageFileName = (imageURL.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    print("Image filename \(imageFileName)")
    if fileExistsAtPath(path: imageFileName){
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)){
            completion(contentsOfFile)
        } else {
            completion(nil)
        }
    } else {
        //doesnt exist on phone
        let downloadQue = DispatchQueue(label: "imageDownloadQueue")
        downloadQue.async {
            let data = NSData(contentsOf: imageUrl! as URL)
            if data != nil {
                var docURL = getDocumentsUrl()
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                let imageToReturn = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    completion(imageToReturn!)
                }
            } else {
                DispatchQueue.main.async {
                    print(" No image in phone")
                    completion(nil)
                }
            }
        }
    }
}

//MARK: Video Section
func uploadVideo(video: NSData, chatRoomId: String, view: UIView, completion: @escaping(_ videoLink: String?) ->Void){
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    var task: StorageUploadTask!
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        if error != nil {
            print("Could upload video")
            return
        }
        storageRef.downloadURL(completion: { (url, error) in
        guard let downloadUrl = url else { completion(nil); return }
        completion(downloadUrl.absoluteString)
            
        })
    })
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

func videoThumbNail(video: NSURL) -> UIImage {
    let asset = AVURLAsset(url: video as URL, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, 1000)
    var actualTime = kCMTimeZero
    var image: CGImage?
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    let thumbNail = UIImage(cgImage: image!)
    return thumbNail
}

func fileInDocumentsDirectory(filename: String) -> String {
    let fileUrl = getDocumentsUrl().appendingPathComponent(filename)
    return fileUrl.path
}

func getDocumentsUrl() -> URL {
    let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documentUrl!
}

func fileExistsAtPath(path: String) -> Bool {
    var doesexist = false
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath){
        doesexist = true
    } else {
        doesexist = false
    }
    return doesexist
}

func downloadVideo(videoURL: String, completion: @escaping(_ isReadyToPlay: Bool,_ videoFileName: String) -> Void) {
    let videoUrl = NSURL(string: videoURL)
    let videoFileName = (videoURL.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    if fileExistsAtPath(path: videoFileName){
        completion(true, videoFileName)
    } else {
        //doesnt exist on phone
        let downloadQue = DispatchQueue(label: "videoDownloadQueue")
        downloadQue.async {
            let data = NSData(contentsOf: videoUrl! as URL)
            if data != nil {
                var docURL = getDocumentsUrl()
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                DispatchQueue.main.async {
                    completion(true, videoFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print(" No image in phone")
                }
            }
        }
    }
}
