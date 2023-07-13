
import Foundation
import FirebaseStorage
import UIKit

struct ImageUploader{
    
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void){
        guard let imageDate = image.jpegData(compressionQuality: 0.5) else {return}
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_image/\(filename)")
        
        ref.putData(imageDate,metadata: nil){ _, error in
            if let error = error{
                print("Debug: Failed to upload image with error: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { imageUrl, _ in
                guard let imageUrl = imageUrl?.absoluteString else {return }
                completion(imageUrl)
            }
            
        }
    }
}
