

import SwiftUI

struct ContentView: View {
    
    @State var loginSuccess = false
    var body: some View {
        VStack {
            if loginSuccess{
                Location()
            }
            else{
                Login(loginSuccess: $loginSuccess)
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
