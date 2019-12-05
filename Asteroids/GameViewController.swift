//
//  GameViewController.swift
//  Asteroids
//
//  Created by Shawky on 11/11/2019.
//  Copyright © 2019 Sorbonne. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation


class GameViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate{
    
    // Global visibles
    var audioplayer: AVAudioPlayer?
    var scene: SKScene?
    var picker: UIPickerView = UIPickerView()
    var scores: ScoresManager = ScoresManager()
    var diff = 0
    var diffView = UIView()
    var mainMenuView = UIView()
    var mutelbl = UILabel()
    var gameScence : MyScene?
     let defaults = UserDefaults.standard
    
    // Custom Tapper
    class MyTapGesture: UITapGestureRecognizer {
        var value = 0
    }
    
    // Launch Main Menu
    override func viewDidLoad() {
        super.viewDidLoad()
        // Clear old views
         diffView = UIView()
         mainMenuView = UIView()
         mutelbl = UILabel()
        picker = UIPickerView()
        // Make a new one
        self.modalPresentationStyle = .fullScreen
        mainMenuView.frame = view.frame
        // Load Difficulty
        diff = defaults.integer(forKey: "diff")
        
        // Create Menu
        let astlbl = UILabel()
        astlbl.text = "Asteroids"
        astlbl.textColor = .white
        astlbl.font = UIFont(name: astlbl.font.fontName, size: 80)
    
        mutelbl = UILabel()
        mutelbl.text = "🔇"
        mutelbl.textColor = .white
        mutelbl.font = UIFont(name: astlbl.font.fontName, size: 70)
        let tapMute = UITapGestureRecognizer(target: self, action: #selector(muteMusic))
        mutelbl.isUserInteractionEnabled = true
        mutelbl.addGestureRecognizer(tapMute)
        picker.dataSource = self
        picker.delegate = self
        picker.alpha = 1
        let min = CGFloat(-40)
        let max = CGFloat(-10)
        
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion,yMotion]
        let omage = UIImage(named: "saturn-rings")
        let oview = UIImageView(image: omage)
        oview.translatesAutoresizingMaskIntoConstraints = false
        oview.addMotionEffect(motionEffectGroup)
        picker.layer.borderWidth = 0.0
        mainMenuView.addSubview(oview)
        mainMenuView.addSubview(astlbl)
        mainMenuView.addSubview(picker)
        mainMenuView.addSubview(mutelbl)
        view.addSubview(mainMenuView)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        picker.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        picker.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        astlbl.translatesAutoresizingMaskIntoConstraints = false
        astlbl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        astlbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: 20).isActive = true
        mutelbl.translatesAutoresizingMaskIntoConstraints = false
        mutelbl.centerXAnchor.constraint(equalTo: astlbl.centerXAnchor, constant: 300).isActive = true
        mutelbl.topAnchor.constraint(equalTo: astlbl.bottomAnchor , constant: -80).isActive = true
        picker.layer.borderWidth = 0
        let tapToSelect = UITapGestureRecognizer(target: self, action: Selector(("tappedMenu")))
        tapToSelect.delegate = self
        picker.addGestureRecognizer(tapToSelect)
        for p in picker.subviews
        {
            p.translatesAutoresizingMaskIntoConstraints = false
            p.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            p.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            p.isHidden = p.frame.height <= 1.0
        }
        // Play 8 bit background music
        let data = NSDataAsset(name: "DataChild")!
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly */
            audioplayer = try AVAudioPlayer(data: data.data)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = audioplayer else { return }
            player.numberOfLoops = 3
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Mute 8 bit Music
    @objc func muteMusic()
    {
        if(audioplayer!.isPlaying)
        {
        audioplayer!.pause()
        mutelbl.text = "🔊"
        }
        else
        {
        mutelbl.text = "🔇"
        audioplayer!.play()
        }
    }
    
    // Start using SpriteKit
    func loadGameScene() {
        
        let sceneView = SKView(frame: view.frame)
        view.addSubview(sceneView)

        if let view = sceneView as SKView? {
            // Load the SKScene from 'MyScene.sks'
            scene = MyScene(size: CGSize(width: 1920, height: 1080))
            // Set the scale mode to scale to fit the window
            scene!.scaleMode = .resizeFill
            self.modalPresentationStyle = .fullScreen
            view.isMultipleTouchEnabled = true
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            // Present the scene
            view.presentScene(scene)
            gameScence = scene as? MyScene
            gameScence!.viewController = self
        }
     
    }
    
    // Auto Rotate Activation
    override var shouldAutorotate: Bool {
        return true
    }
    // Declare only Landscape supported
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
    // Disable Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // PickerView Menu of one section
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerView number of items in menu
    // Updated manually on change
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    // Menu Item height
    func pickerView(_: UIPickerView, rowHeightForComponent : Int) -> CGFloat
    {
        return 50
    }
    // Menu Items
    func pickerView(_ picker : UIPickerView, viewForRow: Int, forComponent: Int, reusing: UIView?) -> UIView {
        picker.subviews[1].isHidden = true
        picker.subviews[2].isHidden = true
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: lbl.font.fontName, size: 50)
        //lbl.frame.integral
        lbl.textAlignment = .center
        // lbl.translatesAutoresizingMaskIntoConstraints = false
        switch viewForRow {
        case 0:
            lbl.text = "Play"
            return lbl
        case 1:
            lbl.text = "Difficulty"
            return lbl
        case 2:
            lbl.text = "High Scores"
            return lbl
        case 3:
            lbl.text = "About"
            return lbl
        default:
            return lbl
        }
    }
    

    // Make High Score Input Screen when Game ends
    func askHighScoreName(score: Int)
    {
       
        if (scores.isHighScore(score: score))
        {
             scores.showHighScores(view: view)
            scores.inputName(score: score, uv: self)
        }
        else
        {
             scores.showHighScores(view: view)
        }
    }
    
    // Make Difficulty Selection Screen
    func showGameDifficulty()
    {
         diffView = UIView(frame: view.frame)
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            diffView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            diffView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            diffView.alpha = 0.9
            diffView.backgroundColor = .white
        }
        let diffLbl = UILabel()
        diffLbl.textColor = .white
        diffLbl.font = UIFont(name: diffLbl.font.fontName, size: 50)
        diffLbl.text = "Select Game Difficulty:"
        diffLbl.textAlignment = .center
        diffLbl.translatesAutoresizingMaskIntoConstraints = false
        diffView.addSubview(diffLbl)
        view.addSubview(diffView)
        diffLbl.centerXAnchor.constraint(equalTo: diffView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        diffLbl.topAnchor.constraint(equalTo: diffView.safeAreaLayoutGuide.topAnchor , constant: 20).isActive = true
        let diffs = ["Easy","Medium","Hard","Jedi"]
       let diffViewStack = UIStackView()
        diffView.addSubview(diffViewStack)
        for s in diffs
        {
            let slbl = UILabel()
            let ifselected = diffs.firstIndex(of: s) == diff ? "=> " : ""
            slbl.font = UIFont(name: diffLbl.font.fontName, size: 40)
            slbl.textColor = .white
            slbl.text = ifselected + s
            slbl.textAlignment = .center
            diffViewStack.addArrangedSubview(slbl)
            slbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            slbl.isUserInteractionEnabled = true
            let tapAction = MyTapGesture(target: self, action: #selector(selectDiff))
            tapAction.value = diffs.firstIndex(of: slbl.text!) ?? 0
            slbl.addGestureRecognizer(tapAction)
        }
        diffViewStack.translatesAutoresizingMaskIntoConstraints = false
        diffViewStack.topAnchor.constraint(equalTo: diffLbl.bottomAnchor, constant:  20).isActive = true
        diffViewStack.centerXAnchor.constraint(equalTo: diffLbl.centerXAnchor).isActive = true
        diffViewStack.axis = .vertical
        // Add Return Button
        let rlbl = UILabel()
        rlbl.font = UIFont(name: diffLbl.font.fontName, size: 35)
        rlbl.textColor = .white
        rlbl.text = "<="
        rlbl.textAlignment = .left
        rlbl.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(hideDiffView))
        rlbl.addGestureRecognizer(tapAction)
        diffView.addSubview(rlbl)
        rlbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -120).isActive = true
        rlbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
        rlbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Set Difficulty and Save to Defaults
    @objc func selectDiff(sender : Any)
    {
        let s = sender as! MyTapGesture
        diff = s.value
        defaults.set(diff, forKey: "diff")
        hideDiffView()
        showGameDifficulty()
    }
    
    // Hide Difficulty Screen
    @objc func hideDiffView()
    {
        diffView.removeFromSuperview()
    }
    
    // Menu Dispatcher
    @objc func tappedMenu() {
        switch picker.selectedRow(inComponent: 0) {
        case 0:
            startNewGame()
            return
        case 1:
            showGameDifficulty()
            return
        case 2:
            scores.showHighScores(view: view)
            return
        case 3:
            showGameAbout()
            return
        default:
            return
        }
    }
    
    // Let taps be Recognised on UIPickerViews
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    // New Game
    func startNewGame()
    {
        mainMenuView.removeFromSuperview()
        audioplayer?.stop()
        loadGameScene()
    }
    
    // Make About Screen
    func showGameAbout()
    {
        diffView = UIView(frame: view.frame)
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            diffView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            diffView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            diffView.alpha = 0.9
            diffView.backgroundColor = .white
        }
        let diffLbl = UILabel()
        diffLbl.textColor = .white
        diffLbl.font = UIFont(name: diffLbl.font.fontName, size: 50)
        diffLbl.text = "About:"
        diffLbl.textAlignment = .center
        diffLbl.translatesAutoresizingMaskIntoConstraints = false
        diffView.addSubview(diffLbl)
        view.addSubview(diffView)
        diffLbl.centerXAnchor.constraint(equalTo: diffView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        diffLbl.topAnchor.constraint(equalTo: diffView.safeAreaLayoutGuide.topAnchor , constant: 20).isActive = true
        let diffs = ["Controls:","Place both thumbs on screen", "first thumb moves your ship, second thumb shoots","Music:","Main Menu by DataChild of SAE","Game Music by Luka (Interstellar 8bit Cover)","Graphics:","Prof. Fabrice Kordon"]
        let diffViewStack = UIStackView()
        diffView.addSubview(diffViewStack)
        for s in diffs
        {
            let slbl = UILabel()
            slbl.font = UIFont(name: diffLbl.font.fontName, size: 40)
            slbl.textColor = .white
            slbl.text = s
            slbl.textAlignment = .center
            diffViewStack.addArrangedSubview(slbl)
            slbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        }
        diffViewStack.translatesAutoresizingMaskIntoConstraints = false
        diffViewStack.topAnchor.constraint(equalTo: diffLbl.bottomAnchor, constant:  20).isActive = true
        diffViewStack.centerXAnchor.constraint(equalTo: diffLbl.centerXAnchor).isActive = true
        diffViewStack.axis = .vertical
        // Add Return Button
        let rlbl = UILabel()
        rlbl.font = UIFont(name: diffLbl.font.fontName, size: 35)
        rlbl.textColor = .white
        rlbl.text = "<="
        rlbl.textAlignment = .left
        rlbl.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(hideDiffView))
        rlbl.addGestureRecognizer(tapAction)
        diffView.addSubview(rlbl)
        rlbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -120).isActive = true
        rlbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120).isActive = true
        rlbl.translatesAutoresizingMaskIntoConstraints = false
    }
}
