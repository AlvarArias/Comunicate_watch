//
//  ContentView.swift
//  Comunicate_watch Watch App
//
//  Created by Alvar Arias on 2024-12-05.
//

import SwiftUI

struct ContentView: View {

    @State private var messages: [String] = []
    @State private var newMessage = ""



    var body: some View {
     
            VStack {
               List(messages, id: \.self) { message in
                Text(message)
            }
            HStack {
                TextField("Message", text: $newMessage)
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .padding()
                    
            }
        }   
    
    
    func sendMessage() {
        if !newMessage.isEmpty {
            messages.append(newMessage)
            newMessage = ""
          // Add code to send message to the other device here
          /*
          guard !newMessage.isEmpty else { return }
    let db = Firestore.firestore()
    db.collection("messages").addDocument(data: ["text": newMessage, "timestamp": Timestamp()]) { error in
        if let error = error {
            print("Error adding document: \(error)")
        } else {
            messages.append(newMessage)
            newMessage = ""
        }
    }
    */  
            }
        }
    
      func fetchMessages() {
        let db = Firestore.firestore()
        db.collection("messages").order(by: "timestamp").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            messages = documents.map { $0["text"] as? String ?? "" }
        }
    }

    
    }
       

  /*
  4. Handle notifications
Implement push notifications to alert users of new messages. 
Follow the Apple Push Notification Service guide to set up push notifications.
*/

#Preview {
    ContentView()
}


