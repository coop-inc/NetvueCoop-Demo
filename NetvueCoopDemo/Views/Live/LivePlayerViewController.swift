//
//  LivePlayerViewController.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/16/22.
//

import Foundation
import SwiftUI
import NetvueSDK


class PlayerView: UIView {
    var player: LiveMediaPlayer?
    
}

struct LivePlayer: UIViewControllerRepresentable {
    typealias UIViewType = PlayerView
    var device: DeviceNode
    
    func updateUIViewController(_ uiViewController: LivePlayerViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> LivePlayerViewController {
        let livePlayer =  LivePlayerViewController()
        livePlayer.delegate = context.coordinator
        return livePlayer
    }
    
    func makeCoordinator() -> LivePlayer.Coordinator {
        return Coordinator(self)
    }
    
}


extension LivePlayer {
    class Coordinator: NSObject, MediaPlayerDelegate {
        func onMediaPlayerError(mediaPlayer: MediaPlayer, error: MediaPlayerError) {
            
        }
        
        func onMediaPlayerReportNetworkSpeed(mediaPlayer: MediaPlayer, byteSizePerSecond: Int64) {
            
        }
        
        func onMediaPlayerStateChanged(mediaPlayer: MediaPlayer, state: MediaPlayerState) {

        }
        
        func onMediaPlayerVideoRendered(pts: Int64) {
            
        }
        
        var parent: LivePlayer

        init(_ parent: LivePlayer) {
            self.parent = parent
        }
    }
}


class LivePlayerViewController: UIViewController {
    var renderer: MediaPlayerRenderer?
    var player: LiveMediaPlayer?
    weak var delegate: MediaPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderer = MediaPlayerDarwinRendererBuilder.init().buildUIViewRenderer(drawable: view)
    }
    
    deinit {
        renderer?.dispose()
    }
}


class LivePlayerViewController2: UIViewController, MediaPlayerDelegate {
    
    var deviceNode: DeviceNode?
    
    var player: LiveMediaPlayer?

    @IBOutlet weak var renderView: UIView!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var btnSpeak: UIButton!
    
    @IBOutlet weak var btnLight: UIButton!
    
    var renderer: MediaPlayerRenderer?
    
    var playerState: MediaPlayerState = MediaPlayerState.idle
    
    var isRecording: Bool = false
    
    var isSpeaking: Bool = false
    
    var isLightOn: Bool = false;
    
    deinit {
        renderer?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Live"
        
        // The player will draw the image on the drawable view.
        renderer = MediaPlayerDarwinRendererBuilder.init().buildUIViewRenderer(drawable: renderView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (playerState != MediaPlayerState.idle ||
            playerState != MediaPlayerState.disconnected ||
            playerState != MediaPlayerState.error) {
            
            player?.stopLive(completionHandler: { error in
                
            })
        }
    }
    
    @IBAction func onBtnPlayClicked(_ sender: Any) {
        
        if (playerState == MediaPlayerState.buffering ||
            playerState == MediaPlayerState.connecting ||
            playerState == MediaPlayerState.streaming ||
            playerState == MediaPlayerState.connected) {
            
            player?.stopLive(completionHandler: { error in
                
            })
            
            btnPlay.setTitle("Play", for: UIControl.State.normal)
            
        } else {
            
            deviceNode?.online.getValue(completionHandler: { online, error in

                if (online == true) {
                    if (self.player == nil) {
                        self.player = LiveMediaPlayer(render: self.renderer!,
                                                      deviceNode: self.deviceNode!,
                                                      delegate: self,
                                                      permissionManager: nil)
                        
                    }
                    
                    // Due to the limitation of KMM coroutines, all asynchronous interfaces need to be called by the MAIN thread.
                    DispatchQueue.main.async {
                        /**
                         During initialization, the player can specify whether to enable the speaker and microphone,
                         or call the interface after playing.
                         */
                        self.player?.playLive(resolution: MediaPlayerVideoResolution.auto_, enableLocalSpeaker: true, enableLocalMicrophone: false, completionHandler: { error in
                            
                        })
                    }
                    
                }

            })
        }
        
    }
    @IBAction func onSelectHD(_ sender: Any) {
        if (self.playerState == MediaPlayerState.streaming) {
            self.player?.changeVideoResolution(resolution: MediaPlayerVideoResolution.hd, completionHandler: { error in
                
            })
        }
    }
    
    @IBAction func onSelectSD(_ sender: Any) {
        if (self.playerState == MediaPlayerState.streaming) {
            self.player?.changeVideoResolution(resolution: MediaPlayerVideoResolution.sd, completionHandler: { error in
                
            })
        }
    }
    @IBAction func onBtnScreenshotClicked(_ sender: Any) {
        if (self.playerState == MediaPlayerState.streaming) {
            /**
             You need to determine whether you have access to the photo album before saving the screenshot.
             */
            self.player?.screenshot(completionHandler: { screenshotFilePath, error in
                if (screenshotFilePath != nil) {
                    NSLog("ScreenShot save to \(String(screenshotFilePath ?? ""))")
                    AlbumAccessor.init().saveImageToAlbum(imageFilePath: screenshotFilePath!) { path, error in
                        // After the file is saved to the album, it is recommended to delete the Temp file.
                    }
                }
            })
        }
    }
    
    @IBAction func onBtnRecordClicked(_ sender: Any) {
        if (self.playerState == MediaPlayerState.streaming) {
            if (!isRecording) {
                self.player?.startRecord(completionHandler: { error in

                })
                self.isRecording = true
                self.btnRecord.setTitle("Stop Record", for: UIControl.State.normal)
                
            } else {
                self.player?.stopRecord(completionHandler: { recordFilePath, error in
                    if (recordFilePath != nil) {
                        NSLog("Record save to \(String(recordFilePath ?? ""))")
                        AlbumAccessor.init().saveVideoToAlbum(videoFilePath: recordFilePath!) { path, error in
                            // After the file is saved to the album, it is recommended to delete the Temp file.
                        }
                    }
                })
                self.isRecording = false
                self.btnRecord.setTitle("Record", for: UIControl.State.normal)
            }
        }
    }
    func onMediaPlayerError(mediaPlayer: MediaPlayer, error: MediaPlayerError) {
        NSLog("Received player error: \(error.errorType.name)")
    }
    
    /**
     The player callback the current network speed.
     */
    func onMediaPlayerReportNetworkSpeed(mediaPlayer: MediaPlayer, byteSizePerSecond: Int64) {
        NSLog("Needwork Speed: \(String(byteSizePerSecond)) bytes/s")
    }
    
    func onMediaPlayerStateChanged(mediaPlayer: MediaPlayer, state: MediaPlayerState) {
        self.playerState = state
        
        if (state == MediaPlayerState.connecting ||
            state == MediaPlayerState.connected ||
            state == MediaPlayerState.streaming) {
            self.btnPlay.setTitle("Stop", for: UIControl.State.normal)
        }
    }
    
    func onMediaPlayerVideoRendered(pts: Int64) {
        
    }
    
    @IBAction func onBtnSpeakClicked(_ sender: Any) {
        if (playerState == MediaPlayerState.streaming) {
            if (!isSpeaking) {
                self.player?.enableLocalMicrophone(enable: true, completionHandler: { error in
                    
                })
                isSpeaking = true
                self.btnSpeak.setTitle("Stop Speak", for: UIControl.State.normal)
            } else {
                self.player?.enableLocalMicrophone(enable: false, completionHandler: { error in
                    
                })
                isSpeaking = false
                self.btnSpeak.setTitle("Start Speak", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func onMuteClicked(_ sender: Any) {
        if (playerState == MediaPlayerState.streaming) {
            self.player?.enableLocalSpeaker(enable: false, completionHandler: { error in
                
            })
        }
    }
    
    @IBAction func onUnmuteClicked(_ sender: Any) {
        if (playerState == MediaPlayerState.streaming) {
            self.player?.enableLocalSpeaker(enable: true, completionHandler: { error in
                
            })
        }
    }
    
    @IBAction func onBtnSirenClicked(_ sender: Any) {
        if (playerState == MediaPlayerState.streaming) {
            self.deviceNode?.controller.sendBuzzerCommand(request: DeviceControlSendBuzzerCommandRequest(enable: true, duration: 5000), timeoutMs: 5000, completionHandler: { error in
                
            })
        }
    }
    
    @IBAction func onBtnLightClicked(_ sender: Any) {
        if (playerState == MediaPlayerState.streaming) {
            if (!isLightOn) {
                self.player?.enableWhiteLight(enable: true, completionHandler: { error in
                    
                })
                isLightOn = true
                self.btnLight.setTitle("Light Off", for: UIControl.State.normal)
            } else {
                self.player?.enableWhiteLight(enable: false, completionHandler: { error in
                    
                })
                isLightOn = false
                self.btnLight.setTitle("Light On", for: UIControl.State.normal)
            }
        }
    }
}
