
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
struct RestService {
    func uploadRest(caption:String, completion: @escaping(Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let data = ["uid":uid,
                    "caption": caption,
                    "likes": 0,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        Firestore.firestore().collection("Rests")
            .document().setData(data){ error in
                if let error = error {
                    print("Debug: Failed To Upload Rest.. \(error.localizedDescription)")
                    completion(false)
                }
                completion(true)
                print("Debug: Did Upload Rest..")
                
            }
    }
    
    func fetchRests(completion: @escaping([Rest])-> Void){
        Firestore.firestore().collection("Rests").order(by: "timestamp",descending: true).getDocuments{ snapshot, _ in
            guard let documents = snapshot?.documents else { return}
            
            let Rests = documents.compactMap({try? $0.data(as: Rest.self)})
            completion(Rests)
            
        }
    }
    
    func fetchRests(forUid uid: String,completion: @escaping([Rest])-> Void){
        Firestore.firestore().collection("rests").whereField("uid", isEqualTo: uid).getDocuments{ snapshot, _ in
            guard let documents = snapshot?.documents else { return}
            
            var rests = documents.compactMap({try? $0.data(as: Rest.self)})
            
            completion(Rests.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
            
        }
    }
   
}
// Marks - Likes
extension RestService{
    func likeRest(_ rest: Rest,completion: @escaping()-> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let restId = rest.id else{return}
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        
        Firestore.firestore().collection("rests").document(restId)
            .updateData(["likes": rest.likes + 1]) { _ in
                userLikesRef.document(restId).setData([:]){ _ in
                    completion()
                }
            }
    }
    
    func unlikeRest(_ rest: Rest,completion: @escaping()-> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let restId = rest.id else{return}
        guard rest.likes > 0 else{return}
        
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        
        Firestore.firestore().collection("rests").document(restId)
            .updateData(["likes": rest.likes - 1]) { _ in
                userLikesRef.document(restsId).delete() { _ in
                    completion()
                }
            }
    }
    
    func checkIfUserLikedRest(_ rest: Rest,completion: @escaping(Bool)-> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let restId = rest.id else{return}
        Firestore.firestore().collection("users").document(uid).collection("user-likes").document(restId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else {return}
            completion(snapshot.exists)
        }
    }
    func fetchLikedRests(forUid uid: String,completion: @escaping([Rest])-> Void){
        
        var rests = [Rest]()
        Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-likes")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else{return}
                
                documents.forEach{ doc in
                    let tweedID = doc.documentID
                    
                    Firestore.firestore().collection("rests")
                        .document(tweedID)
                        .getDocument { snapshot, _ in
                            
                            guard let rest = try? snapshot?.data(as: Rest.self) else{return}
                            rests.append(rest)
                            completion(rests)
                        }
                }
            }
    }
}
