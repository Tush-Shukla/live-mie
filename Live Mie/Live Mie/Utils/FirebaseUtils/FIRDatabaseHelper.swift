//
//  FIRDatabaseHelper.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/19/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum DBType {
    case realtime
    case firestore
}

enum DBCollection: String {
    case users = "users"
    case locations = "locations"
}

class FIRDatabaseHelper {
    
    static let shared = FIRDatabaseHelper()
    var dbType = DBType.firestore
    var db: Firestore!
    fileprivate var locationUpdatesListener: ListenerRegistration?
    
    private init(){
        db = Firestore.firestore()
    }
    
    func writeData(ref: DocumentReference,
                   data: [String: Any],
                   success: @escaping ()->Void,
                   failure: @escaping (_ message: String?)->Void) {
        ref.setData(data) { (error) in
            if let err = error {
                failure(err.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func updateData(ref: DocumentReference,
                   data: [String: Any],
                   success: @escaping ()->Void,
                   failure: @escaping (_ message: String?)->Void) {
        ref.updateData(data) { (error) in
            if let err = error {
                failure(err.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func readDataOnce(ref: DocumentReference,
                      success: @escaping (_ snapshot: DocumentSnapshot)->Void,
                      failure: @escaping (_ message: String?)->Void) {
        ref.getDocument { (snapshot, error) in
            if let err = error {
                return failure(err.localizedDescription)
            }
            guard let snapshot = snapshot else {return failure("Data Snapshot is null")}
            success(snapshot)
        }
    }
    
    
    
    func listenForUpdates(ref: DocumentReference, success: @escaping (_ snapshot: DocumentSnapshot)->Void,
                          failure: @escaping (_ message: String?)->Void) {
        ref.addSnapshotListener { (snapshot, error) in
            if let error = error {
                return failure(error.localizedDescription)
            }
            guard let snapshot = snapshot else {return failure("Data Snapshot is null")}
            success(snapshot)
        }
    }
    
    func listenForUpdates(ref: CollectionReference, success: @escaping (_ snapshot: QuerySnapshot)->Void,
                          failure: @escaping (_ message: String?)->Void) -> ListenerRegistration {
        return ref.addSnapshotListener { (snapshot, error) in
            if let error = error {
                return failure(error.localizedDescription)
            }
            guard let snapshot = snapshot else {return failure("Data Snapshot is null")}
            success(snapshot)
        }
    }
    
}

// MARK: Project Methods
extension FIRDatabaseHelper {
    
    // MARK: Write Methods
    func updateUserInfo(id: String?, name: String, success: @escaping ()->Void,
                        failure: @escaping (_ message: String? )->Void) {
        guard let uid = FIRAuthHelper.getUser()?._id ?? id else {return failure("uid can't be nuil")}
        var data: [String: Any] = [:]
        data["name"] = name
        let ref = db.collection(DBCollection.users.rawValue).document(uid)
        writeData(ref: ref, data: data, success: success, failure: failure)
    }
    
    // MARK: Write Methods
    func updateUserProfileUrl(id: String?, url: String, success: @escaping ()->Void,
                              failure: @escaping (_ message: String? )->Void) {
        guard let uid = FIRAuthHelper.getUser()?._id ?? id else {return failure("uid can't be nuil")}
        var data: [String: Any] = [:]
        data["imageUrl"] = url
        let ref = db.collection(DBCollection.users.rawValue).document(uid)
        updateData(ref: ref, data: data, success: success, failure: failure)
    }
    
    func updateUserStatus(id: String?, status: String, success: @escaping ()->Void,
                              failure: @escaping (_ message: String? )->Void) {
        guard let uid = FIRAuthHelper.getUser()?._id ?? id else {return failure("uid can't be nuil")}
        var data: [String: Any] = [:]
        data["status"] = status
        let ref = db.collection(DBCollection.users.rawValue).document(uid)
        updateData(ref: ref, data: data, success: success, failure: failure)
    }
    
    func updateUserLocation(id: String?, latitude: Double, longitude: Double, success: @escaping ()->Void,
                            failure: @escaping (_ message: String? )->Void) {
        let user = FIRAuthHelper.getUser()
        guard let uid = user?._id ?? id else {return failure("uid can't be nuil")}
        var data: [String: Any] = [:]
        data["name"] = user?.name ?? "No Name"
        data["latitude"] = latitude
        data["longitude"] = longitude
        data["status"] = user?.status ?? "No Status"
        let ref = db.collection(DBCollection.locations.rawValue).document(uid)
        writeData(ref: ref, data: data, success: success, failure: failure)
    }
    
    
    // MARK: Read Methods
    func listenLocationsUpdates(success: @escaping (_ locations: [Location])->Void,
                                failure: @escaping (_ message: String? )->Void) {
        guard let currentUser = FIRAuthHelper.getUser() else {return}
        let ref = db.collection(DBCollection.locations.rawValue)
        self.locationUpdatesListener = listenForUpdates(ref: ref, success: { (snapshot) in
            var locations: [Location] = []
            snapshot.documents.forEach({ (document) in
                let id = document.documentID
                if id != currentUser._id {
                    let name = document.data()["name"] as? String ?? "No Name"
                    let lat = document.data()["latitude"] as? Double ?? 0.0
                    let lng = document.data()["longitude"] as? Double ?? 0.0
                    let status = document.data()["status"] as? String ?? "No Status"
                    locations.append(Location(id: id, name: name, status: status,latitude: lat, longitude: lng))
                }
            })
            success(locations)
        }) { (error) in
            failure(error)
        }
    }
    
    func getUserInfo(id: String?,
                     success: @escaping (_ user: User)->Void,
                     failure: @escaping (_ message: String? )->Void) {
        guard let uid = FIRAuthHelper.getUser()?._id ?? id else {return failure("uid can't be nuil")}
        let ref = db.collection(DBCollection.users.rawValue).document(uid)
        readDataOnce(ref: ref, success: { (snapshot) in
            if snapshot.exists, let data = snapshot.data() {
                guard let user = User(dictionary: data as NSDictionary) else {
                    return failure("User parse error")
                }
                user._id = uid
                success(user)
            }
        }) { (message) in
            failure(message)
        }
    }
    
    func removeLocation() {
        self.locationUpdatesListener?.remove()
    }
    
    
}


