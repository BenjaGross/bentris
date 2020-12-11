//
//  GameViewController.swift
//  bentris
//
//  Created by Ben Gross on 12/8/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {

  var scene: GameScene!
  var swiftris:Swiftris!
  var panPointReference:CGPoint?
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var levelLabel: UILabel!

  override func viewDidLoad() {
      super.viewDidLoad()

      let skView = view as! SKView
      skView.isMultipleTouchEnabled = false

      scene = GameScene(size: skView.bounds.size)
      scene.scaleMode = .aspectFill

      scene.tick = didTick

      swiftris = Swiftris()
      swiftris.delegate = self
      swiftris.beginGame()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

  @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
    let currentPoint = sender.translation(in: self.view)
    if let originalPoint = panPointReference {

      if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {

        if sender.velocity(in: self.view).x > CGFloat(0) {
          swiftris.moveShapeRight()
          panPointReference = currentPoint
        } else {
          swiftris.moveShapeLeft()
          panPointReference = currentPoint
        }
      }
    } else if sender.state == .began {
      panPointReference = currentPoint
    }
  }

  @IBAction func didTap(_ sender: UITapGestureRecognizer) {
    swiftris.rotateShape()
  }

  @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
    swiftris.dropShape()
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer is UISwipeGestureRecognizer {
      if otherGestureRecognizer is UIPanGestureRecognizer {
        return true
      }
    } else if gestureRecognizer is UIPanGestureRecognizer {
      if otherGestureRecognizer is UITapGestureRecognizer {
        return true
      }
    }
    return false
  }

  func didTick() {
    swiftris.letShapeFall()
  }

  func nextShape() {
    let newShapes = swiftris.newShape()
    guard let fallingShape = newShapes.fallingShape else {
      return
    }
    self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
    self.scene.movePreviewShape(shape: fallingShape) {
      self.view.isUserInteractionEnabled = true
      self.scene.startTicking()
    }
  }

  func gameDidEnd(swiftris: Swiftris) {
    view.isUserInteractionEnabled = false
    scene.stopTicking()
    scene.playSound(sound: "Sounds/gameover.mp3")
    scene.animateCollapsingLines(linesToRemove: swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
      swiftris.beginGame()
    }
  }

  func gameDidBegin(swiftris: Swiftris) {
    levelLabel.text = "\(swiftris.level)"
    scoreLabel.text = "\(swiftris.score)"
    scene.tickLengthMillis = TickLengthLevelOne

    if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
      scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
        self.nextShape()
      }
    } else {
      self.nextShape()
    }
  }

  func gameShapeDidLand(swiftris: Swiftris) {
    self.view.isUserInteractionEnabled = false

    let removedLines = swiftris.removeCompletedLines()
    if removedLines.linesRemoved.count > 0 {
      self.scoreLabel.text = "\(swiftris.score)"
      scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {

        self.gameShapeDidLand(swiftris: swiftris)
      }
      scene.playSound(sound: "Sounds/bomb.mp3")
    } else {
      nextShape()
    }
  }

  func gameShapeDidMove(swiftris: Swiftris) {
    scene.redrawShape(shape: swiftris.fallingShape!) {}
  }

  func gameShapeDidDrop(swiftris: Swiftris) {
    scene.stopTicking()
    scene.redrawShape(shape: swiftris.fallingShape!) {
      swiftris.letShapeFall()
    }
    scene.playSound(sound: "Sounds/drop.mp3")
  }

  func gameDidLevelUp(swiftris: Swiftris) {
    levelLabel.text = "\(swiftris.level)"
    if scene.tickLengthMillis >= 100 {
      scene.tickLengthMillis -= 100
    } else if scene.tickLengthMillis > 50 {
      scene.tickLengthMillis -= 50
    }
    scene.playSound(sound: "Sounds/levelup.mp3")
  }
}
