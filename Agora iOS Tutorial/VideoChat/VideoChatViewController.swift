//
//  VideoChatViewController.swift
//  Agora iOS Tutorial
//
//  Created by James Fang on 7/14/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

import UIKit

class VideoChatViewController: UIViewController {
    @IBOutlet weak var localVideo: UIView!              // Tutorial Step 3
    @IBOutlet weak var remoteVideo: UIView!             // Tutorial Step 5
    @IBOutlet weak var controlButtons: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedBg: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIImageView!

    var agoraKit: AgoraRtcEngineKit!                    // Tutorial Step 1
    let localUid : String = {
        //获取当前时间
        let now = Date()
        
//        // 创建一个日期格式器
//        let dformatter = DateFormatter()
//        dformatter.dateFormat = "yyyyMMdd HH:mm:ss"
//        print("当前日期时间：\(dformatter.string(from: now))")
        
        //当前时间的时间戳
        let timeInterval:TimeInterval = now.timeIntervalSince1970
//        let timeStamp = Int(timeInterval)
        print("当前时间的时间戳：\(timeInterval)")
        return String(timeInterval)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupButtons()              // Tutorial Step 8
        hideVideoMuted()            // Tutorial Step 10
        initializeAgoraEngine()     // Tutorial Step 1
        setupVideo()                // Tutorial Step 2
        setupLocalVideo()           // Tutorial Step 3
        joinChannel()               // Tutorial Step 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Tutorial Step 1
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }

    // Tutorial Step 2
    func setupVideo() {
        agoraKit.enableVideo()  // Default mode is disableVideo
        agoraKit.setVideoProfile(._VideoProfile_360P, swapWidthAndHeight: false) // Default video profile is 360P
    }
    
    // Tutorial Step 3
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = localUid
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .render_Adaptive
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    // Tutorial Step 4
    func joinChannel() {
        agoraKit.joinChannel(byKey: nil, channelName: "demoChannel1", info:nil, uid:localUid) {[weak self] (sid, uid, elapsed) -> Void in
            // Join channel "demoChannel1"
            if let weakSelf = self {
                weakSelf.agoraKit.setEnableSpeakerphone(true)
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
    
    // Tutorial Step 6
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideControlButtons()   // Tutorial Step 8
        UIApplication.shared.isIdleTimerDisabled = false
        remoteVideo.removeFromSuperview()
        localVideo.removeFromSuperview()
        
        agoraKit = nil
    }
    
    // Tutorial Step 8
    func setupButtons() {
        perform(#selector(hideControlButtons), with:nil, afterDelay:3)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoChatViewController.ViewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    func hideControlButtons() {
        controlButtons.isHidden = true
    }
    
    func ViewTapped() {
        if (controlButtons.isHidden) {
            controlButtons.isHidden = false;
            perform(#selector(hideControlButtons), with:nil, afterDelay:3)
        }
    }
    
    func resetHideButtonsTimer() {
        VideoChatViewController.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideControlButtons), with:nil, afterDelay:3)
    }
    
    // Tutorial Step 9
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
        resetHideButtonsTimer()
    }
    
    // Tutorial Step 10
    @IBAction func didClickVideoMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        localVideo.isHidden = sender.isSelected
        localVideoMutedBg.isHidden = !sender.isSelected
        localVideoMutedIndicator.isHidden = !sender.isSelected
        resetHideButtonsTimer()
    }
    
    func hideVideoMuted() {
        remoteVideoMutedIndicator.isHidden = true
        localVideoMutedBg.isHidden = true
        localVideoMutedIndicator.isHidden = true
    }
    
    // Tutorial Step 11
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.switchCamera()
        resetHideButtonsTimer()
    }
}

extension VideoChatViewController: AgoraRtcEngineDelegate {
    // Tutorial Step 5
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:String, size:CGSize, elapsed:Int) {
        if (remoteVideo.isHidden) {
            remoteVideo.isHidden = false
        }
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .render_Adaptive
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    // Tutorial Step 7
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:String, reason:AgoraRtcUserOfflineReason) {
        self.remoteVideo.isHidden = true
    }
    
    // Tutorial Step 10
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:String) {
        remoteVideo.isHidden = muted
        remoteVideoMutedIndicator.isHidden = !muted
    }
}
