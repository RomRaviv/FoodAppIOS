import Foundation


protocol Delegate_Data {
    func dataRecieved(model: MyData)
}

class DataManager {
    
    var delegate: Delegate_Data?
    var data: MyData?
    
    let LAST_SCORE_PREF_KEY = "lastScore"
    
    func setData(data: MyData?){
        if let d = data {
            self.data = d
        }
    }
    
    func fetchFromServer(url: String, delegate: Delegate_Data) {
        self.delegate = delegate
        performRequest(fullUrl: url)
    }
    
    func performRequest(fullUrl: String) {
        if let url: URL = URL(string: fullUrl) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if let e = error {
                    print("error:\(e)")
                    return
                }
                
                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    print("dataString:\(dataString!)")
                    self.parseJSON(data: safeData)
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(MyData.self, from: data)
            
            DispatchQueue.main.sync {
                self.delegate?.dataRecieved(model: model)
            }
            
        } catch {
            print("Error: \(error)")
        }
    }

}


