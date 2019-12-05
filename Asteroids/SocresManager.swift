//
//  SocresManager.swift
//  Asteroids
//
//  Created by Shawky on 23/11/2019.
//  Copyright © 2019 Sorbonne. All rights reserved.
//

import Foundation
import UIKit

class ScoresManager
{
    var scores : [String : Int] = ["P1" : 2, "P2" : 4]
    var scoresView = UIView()
    // Save Scores
    func saveScores()
    {
        let defaults = UserDefaults.standard
        let sscores = scores.sorted{$0.1 > $1.1}
        let pscores = sscores.prefix(5)
        var dico : NSMutableDictionary = NSMutableDictionary()
        for p in pscores
        {
             dico.setValue(p.value, forKey: p.key)
        }
        defaults.set(dico, forKey: "Scores")
    }
    
    // Load Scores
    func loadScores()
    {
        let defaults = UserDefaults.standard
        let pscores = (defaults.object(forKey: "Scores") as! NSMutableDictionary?) ?? NSMutableDictionary()
        scores.removeAll()
        for p in pscores
        {
            let vscore = p.value as! NSNumber
            scores.updateValue( Int(vscore) , forKey: p.key as! String)
        }
    }
    
    // Updates player score
    func updateScore(player: String, score: Int)
    {
        scores.updateValue(score, forKey: player)
    }
    
    // Make Scores Screen
    func showHighScores(view: UIView)
    {
        loadScores()
        scoresView = UIView()
        scoresView.frame = view.frame
        // only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            scoresView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            scoresView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            scoresView.alpha = 0.9
            scoresView.backgroundColor = .white
        }
        // Setup Scores Layout
        let scoreslbl = UILabel()
        scoreslbl.textColor = .white
        scoreslbl.font = UIFont(name: scoreslbl.font.fontName, size: 50)
        scoreslbl.text = "High Scores:"
        scoreslbl.textAlignment = .center
        scoreslbl.translatesAutoresizingMaskIntoConstraints = false
        scoresView.addSubview(scoreslbl)
        view.addSubview(scoresView)
        scoreslbl.centerXAnchor.constraint(equalTo: scoresView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        scoreslbl.topAnchor.constraint(equalTo: scoresView.safeAreaLayoutGuide.topAnchor , constant: 20).isActive = true
        let scoresList = UIStackView()
        scoresView.addSubview(scoresList)
        // Add Scores from List
        let sscores = scores.sorted{$0.1 > $1.1}
        let pscores = sscores.prefix(5)
        for s in pscores
        {
            let slbl = UILabel()
            slbl.font = UIFont(name: scoreslbl.font.fontName, size: 40)
            slbl.textColor = .white
            slbl.text = s.key + " " + String(s.value)
            slbl.textAlignment = .center
            scoresList.addArrangedSubview(slbl)
            slbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        }
        if scoresList.subviews.count == 0
        {
            let slbl = UILabel()
            slbl.font = UIFont(name: scoreslbl.font.fontName, size: 40)
            slbl.textColor = .white
            slbl.text = "Be The First to Hit The Scores !"
            slbl.textAlignment = .center
            scoresList.addArrangedSubview(slbl)
            slbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        }
        scoresList.translatesAutoresizingMaskIntoConstraints = false
        scoresList.topAnchor.constraint(equalTo: scoreslbl.bottomAnchor, constant:  20).isActive = true
        scoresList.centerXAnchor.constraint(equalTo: scoreslbl.centerXAnchor).isActive = true
        scoresList.axis = .vertical
        // Add Return Button
        let rlbl = UILabel()
        rlbl.font = UIFont(name: scoreslbl.font.fontName, size: 35)
        rlbl.textColor = .white
        rlbl.text = "<="
        rlbl.textAlignment = .left
        rlbl.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(returnToMain))
        rlbl.addGestureRecognizer(tapAction)
        scoresView.addSubview(rlbl)
        rlbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -120).isActive = true
        rlbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
        rlbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func isHighScore(score: Int) -> Bool
    {
        if (scores.isEmpty)
        {
            return true
        }
        if (scores.max(by: {a,b in a.value < b.value})!.value > score &&
            scores.min(by: {a,b in a.value < b.value})!.value > score )
        {
            return false
        }
        return true
    }
    
    @objc func inputName(score: Int, uv : UIViewController) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Asteroids", message: "Enter your name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Player1"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.updateScore(player: textField!.text!, score: score)
            self.saveScores()
        }))
        
        // 4. Present the alert.
        uv.present(alert, animated: true, completion: nil)
    }
    @objc func returnToMain () {
        scoresView.removeFromSuperview()
    }
    
}
