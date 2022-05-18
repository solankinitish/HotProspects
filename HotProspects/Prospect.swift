//
//  Prospect.swift
//  HotProspects
//
//  Created by Nitish Solanki on 26/04/22.
//

import SwiftUI

class Prospect: Identifiable, Codable, Comparable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    
    static func <(lhs: Prospect, rhs: Prospect) -> Bool {
            return lhs.name < rhs.name
        }
    
    static func ==(lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.name == rhs.name
    }
    
}

@MainActor class Prospects: ObservableObject {
    
    @Published private(set) var people: [Prospect]
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("People")
    
   
    
    init() {
        do{
            let data = try Data(contentsOf: savePath)
            people = try JSONDecoder().decode([Prospect].self, from: data)
        } catch {
            people = []
        }
    }
    
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
 
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
