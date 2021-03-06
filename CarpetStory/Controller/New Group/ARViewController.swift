//
//  ViewController.swift
//  CarpetStory
//
//  Created by Aashrit Garg on 21/07/2018.
//  Copyright © 2018 Aashrit Garg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Alamofire
import SVProgressHUD

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var path : String?
    
    var textureURL : String?
    var length : Float?
    var breadth : Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                
                // Create a new scene
                SVProgressHUD.show()
                
                let carpetScene = SCNScene(named: "art.scnassets/PersianCarpet.scn")!
                
                if let carpetNode = carpetScene.rootNode.childNode(withName: "PersianCarpet", recursively: true) {
                    
                    carpetNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    carpetNode.scale = SCNVector3(x: length!, y: breadth!, z: 0.01)
                    
                    Alamofire.request(textureURL!).responseImage { response in
                        debugPrint(response)
                        
                        if let image = response.result.value {
                            let material = SCNMaterial()
                            material.isDoubleSided = false
                            material.diffuse.contents = image
                            carpetNode.geometry?.materials = [material]
                            self.sceneView.scene.rootNode.addChildNode(carpetNode)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            
        } else {
            
            return
            
        }
        
    }
    
}
