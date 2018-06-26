//
//  ViewController.swift
//  Drawing In 3D
//
//  Created by Justin Vallely on 6/26/18.
//  Copyright © 2018 Pajama Donkey. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPosition = orientation + location
        print(currentPosition)

        DispatchQueue.main.async {

            if self.drawButton.isHighlighted {
                let drawingNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                drawingNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                drawingNode.position = currentPosition
                self.sceneView.scene.rootNode.addChildNode(drawingNode)

            } else {
                //remove all old curser nodes
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "curserNode" {
                        node.removeFromParentNode()
                    }
                })

                //add a curser node at the current camera position
                let curserNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                curserNode.name = "curserNode"
                curserNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
                curserNode.position = currentPosition
                self.sceneView.scene.rootNode.addChildNode(curserNode)
            }
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
