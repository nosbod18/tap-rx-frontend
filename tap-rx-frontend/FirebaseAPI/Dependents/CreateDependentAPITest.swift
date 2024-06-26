//
//  CreateDependantAPITest.swift
//  tap-rx-frontend
//
//  Created by Drew Clutes on 4/9/24.
//

import SwiftUI
import FirebaseAuth

struct CreateDependantAPITest: View {
    @State private var email: String = "drewclutes@gmail.com"
    @State private var password: String = "123456"
    @State private var userID: String = ""
    
    
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var phone: String = ""
    
    
    
    func create_dependant() {
        Auth.auth().signIn(withEmail: self.email, password: self.password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }
            
            if let user = result?.user {
                self.userID = user.uid
                let postData: [String: Any] = [
                    "first_name": self.first_name,
                    "last_name": self.last_name,
                    "phone": self.phone,
                ]
                
                user.getIDToken { (idToken, error) in
                    //guard let self = self else { return }
                    
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let idToken = idToken else {
                        print("Failed to retrieve ID token.")
                        return
                    }
                    
                    let url = URL(string: "https://taprx.xyz/users/\(self.userID)/dependants")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue(idToken, forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: postData)
                        request.httpBody = jsonData
                        
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Network error: \(error.localizedDescription)")
                                } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                                    print("Response String: \(responseString)")
                                    do {
                                        let response = try JSONDecoder().decode(CreateDependant.self, from: data)
                                        print(response)
                                    } catch {
                                        print("Decoding error: \(error)")
                                    }
                                }
                            }
                        }
                        task.resume()
                    } catch {
                        print("Error serializing JSON: \(error.localizedDescription)")
                    }
                }
            
            }
        }
    }
    
    var body: some View {
        VStack {
            
            
            TextField(
                    "first name",
                    text: $first_name
                ).padding([.top,.bottom],20)
            TextField(
                    "last name",
                    text: $last_name
                ).padding([.top,.bottom],20)
            TextField(
                    "phone",
                    text: $phone
                ).padding([.top,.bottom],20)
            
            
            Button(action: create_dependant) {
                Label("Create Dependant", systemImage: "folder.badge.plus")
            }.padding([.top,.bottom],20)
        }
            .background(.gray)
            .padding(10)
        
    }
}

#Preview {
    CreateDependantAPITest()
}
