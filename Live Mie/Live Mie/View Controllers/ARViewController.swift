//
//  ARViewController.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/10/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ARCoreLocation
import CoreLocation
import FirebaseFirestore

class ARViewController: UIViewController {
        
    @IBOutlet weak var arView: UIView!
    
    var scene: InteractiveScene!
    var arSKView: ARSKView!
    var landmarker: ARLandmarker!
    var locationsListener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        scene = InteractiveScene()
        arSKView = ARSKView()        
        arSKView.delegate = self
        arSKView.presentScene(scene)
        
        
        landmarker = ARLandmarker(view: arSKView, scene: scene, locationManager: CLLocationManager())
        landmarker.maximumVisibleDistance = 30_000 // 30 KM
        landmarker.minViewScale = 0.5 // Shrink distant landmark views to half size
        landmarker.maxViewScaleDistance = 1_000 // Show landmarks 1km or further at the smallest size
        landmarker.worldRecenteringThreshold = 1 // Recalculate the landmarks whenever the user moves 30 meters.
        landmarker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        landmarker.overlappingLandmarksStrategy = .showAll // You'll usually want the best accuracy you can get.
        landmarker.beginEvaluatingOverlappingLandmarks(atInterval: 1.0) // Set how often to check for overlapping landmarks.
        landmarker.view.frame = self.view.bounds
        landmarker.scene.size = self.view.bounds.size
        landmarker.delegate = self
        self.arView.addSubview(landmarker.view)
//        self.arView.addSubview(arSKView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        arSKView?.session.run(configuration, options: [.resetTracking])
        addLocationsListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSKView.session.pause()
        removeLocationsListener()
    }
    
    func initScene() {
        
    }
    @IBAction func onLogOutClick(_ sender: Any) {
        FIRAuthHelper.signout(success: {
            AppUtils.showLoginView(controller: self)
        }) { (message) in
            Log(message: message ?? "Failed to logout")
        }
    }
}

// MARK: AR Processing
extension ARViewController: ARSKViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ARViewController: ARLandmarkerDelegate {
    
    func addLandmarker(location: Location) {
        
        let view = StatusARView.fromNib()
        view.set(name: location.name, status: location.status)
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        landmarker.addLandmark(view: view, at: location, completion: nil)
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) {
        
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didFailWithError error: Error) {
        
    }
    
    func redrawLocations(locations: [Location]) {
        landmarker.removeAllLandmarks()
        locations.forEach { (location) in
            print(location)
            addLandmarker(location: location)
        }
    }
    
}

// MARK: Location Handling
extension ARViewController {
    func addLocationsListener() {
        FIRDatabaseHelper.shared.listenLocationsUpdates(success: { (locations) in
            self.redrawLocations(locations: locations)
        }, failure: { (error) in
            Log(message: error ?? "Unable to get locations")
        })
    }
    
    func removeLocationsListener() {
        FIRDatabaseHelper.shared.removeLocation()
    }
}
