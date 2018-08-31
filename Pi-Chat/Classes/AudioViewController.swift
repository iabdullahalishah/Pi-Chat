//
//  AudioViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 31/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioViewController {
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController){
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        target.presentAudioRecorderViewControllerAnimated(controller)
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
