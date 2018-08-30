//
//  VideoMessage.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 30/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class VideoMessage: JSQMediaItem {
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileUrl: NSURL, maskOutgoing: Bool) {
        super.init(maskAsOutgoing: maskOutgoing)
        fileURL = withFileUrl
        videoImageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init is not implemented")
    }
    
    override func mediaView() -> UIView! {
        if let st = status {
            if st == 1 {
                return nil
            }
            if st == 2 && (self.videoImageView == nil) {
                let size = self.mediaViewDisplaySize()
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
                let iconview = UIImageView(image: icon)
                iconview.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                iconview.contentMode = .center
                let imageview = UIImageView(image: self.image!)
                imageview.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageview.contentMode = .scaleAspectFill
                imageview.clipsToBounds = true
                imageview.addSubview(iconview)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageview, isOutgoing: outgoing)
                self.videoImageView = imageview
            }
        }
        return self.videoImageView
    }
    
}
