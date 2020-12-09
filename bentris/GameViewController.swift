//
//  GameViewController.swift
//  bentris
//
//  Created by Ben Gross on 12/8/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()

      let skView = view as! SKView
      skView.isMultipleTouchEnabled = false

      scene = GameScene(size: skView.bounds.size)
      scene.scaleMode = .aspectFill

      skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
