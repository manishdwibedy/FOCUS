//
//  InterestsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKCoreKit
import Magnetic
import SpriteKit

class InterestsViewController: UIViewController{

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var interests = [Interest]()
    let backgroundColor = UIColor.init(red: 22/255, green: 42/255, blue: 64/255, alpha: 1)
    var filtered = [Interest]()
    var searching = false
    
    @IBOutlet weak var magneticView: MagneticView!{
        didSet {
            magnetic.magneticDelegate = self

        }
    }
    
    var magnetic: Magnetic {
        return magneticView.magnetic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.magnetic.backgroundColor = UIColor.lightGray
        for index in 1..<12 {
            add(name: "Interest \(index)")
        }
        
        if AuthApi.isNewUser(){
            saveButton.title = "Done"
        }
        
    }
    
    func add(name: String) {
        let name = name
        let color = UIColor.green
        let node = CustomNode(text: name.capitalized, image: UIImage(named: "addUser"), color: color, radius: 40)
        node.strokeColor = UIColor.black
        magnetic.addChild(node)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveInterests(_ sender: UIBarButtonItem) {
        if AuthApi.isNewUser(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            
            present(vc, animated: true, completion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - MagneticDelegate
extension InterestsViewController: MagneticDelegate {
    
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        print("didSelect -> \(node)")
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        print("didDeselect -> \(node)")
    }
    
}

// MARK: - ImageNode
class ImageNode: Node {
    override var image: UIImage? {
        didSet {
            sprite.texture = image.map { SKTexture(image: $0) }
        }
    }
    override func selectedAnimation() {}
    override func deselectedAnimation() {}
}

extension Magnetic{
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("begin touching")
        self.touchBegan = Date()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if can get last tap time
        if let lastTap = self.lastTapTime{
            let interval = Date().timeIntervalSince(lastTap)
            if Double(interval) < 0.2{
                print("double tap")
                print(interval)
                self.isDoubleTap = true
            }
            else{
                self.isDoubleTap = false
            }
        }
        
        // check for long hold
        
        let tapduration = Date().timeIntervalSince(self.touchBegan!)
        
        if Double(tapduration) > 0.5{
            print("long hold")
            self.isLongTap = true
        }
        else{
            self.isLongTap = false
            self.touchBegan = Date()
        }
        self.lastTapTime = Date()
        self.touchBegan = nil
        if let point = touches.first?.location(in: self), let node = atPoint(point) as? CustomNode {
            
            if isDoubleTap{
                node.setDoubleTap()
            }
            else{
                node.resetDoubleTap()
            }
            
            if isLongTap{
                node.setLongTap()
            }
            else{
                node.resetLongTap()
            }
            
            if node.isSelected {
                node.state = .normal
                magneticDelegate?.magnetic(self, didDeselect: node)
            } else {
                if !allowsMultipleSelection, let selectedNode = selectedChildren.first as? CustomNode {
                    selectedNode.state = .like
                    magneticDelegate?.magnetic(self, didDeselect: selectedNode)
                }
                
                node.state = .like
            }
        }
    }

}

enum State{
    case normal
    case like
    case love
    case hate
}

class CustomNode: Node{
    var isDoubleTap = false
    var isLongTap = false
    
    func setDoubleTap(){
        self.isDoubleTap = true
    }
    
    func resetDoubleTap(){
        self.isDoubleTap = false
    }
    
    func setLongTap(){
        self.isLongTap = true
    }
    
    func resetLongTap(){
        self.isLongTap = false
    }
    
    override var image: UIImage? {
        didSet {
            texture = image.map { SKTexture(image: $0) }
        }
    }
    
    var texture: SKTexture?
    
    var state: State = .normal {
        didSet {
            //guard state != oldValue else { return }
            switch(state){
                case .normal: fallthrough
                case .like: fallthrough
                case .hate: fallthrough
                case .love:
                    let selectionTask = DispatchWorkItem {
                        print(" show tap - \(Date().timeIntervalSince1970) \(self.isDoubleTap)")
                        if self.isLongTap{
                            self.hateInterest()
                        }
                        else if !self.isDoubleTap{
                            self.likeInterest()
                        }
                        else{
                            self.loveInterest()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: selectionTask)
                }
            
            
            }
    
    }
    
    
    
    func hateInterest(){
        if let texture = self.texture {
            self.sprite.run(.setTexture(texture))
        }
        self.run(.scale(to: 0.5, duration: 0.2))
    }
    
    func likeInterest(){
        if let texture = self.texture {
            sprite.run(.setTexture(texture))
        }
        run(.scale(to: 1.5, duration: 0.2))
    }
    
    func loveInterest(){
        if let texture = self.texture {
            sprite.run(.setTexture(texture))
        }
        run(.scale(to: 2, duration: 0.2))
    }
}
