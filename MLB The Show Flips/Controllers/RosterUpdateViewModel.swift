//
//  RosterUpdateDataController.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import Foundation
import Combine

class RosterUpdateViewModel: ObservableObject {
    @Published var updates: [Int: RosterUpdate] = [:]
    @Published var updateHistory: RosterUpdateHistory = RosterUpdateHistory(roster_updates: [])
    
    @Published var isFetching: Bool  = false
    
    func fetchUpdateHistory() async {
        if (!updates.isEmpty) {
            print("Updates cached")
            return
        }
        
        let updateEntriesURL = URL(string: "https://mlb22.theshow.com/apis/roster_updates.json")!
        do {
            DispatchQueue.main.async { [weak self] in  //publish on main thread, avoid retain cycle!
                guard let actualSelf = self else {
                    print("Self not in memory!")
                    return
                }
                actualSelf.isFetching = true
            }
            let (data, _) = try await URLSession.shared.data(from: updateEntriesURL)
            let decodedResult = try JSONDecoder().decode(RosterUpdateHistory.self, from: data)
            DispatchQueue.main.async { [weak self] in  //publish on main thread!
                guard let self = self else {
                    print("Self not in memory!")
                    return
                }
                self.updateHistory = decodedResult //publish on the main thread
                self.isFetching = false
            }
            print("Fetched roster update history")
        } catch {
            print(error)
        }
    }
    
    func fetchUpdateForID(_ id: Int) async {
        
        if (isFetching) {
            return //prevent making another request
        }
        
        guard let updateURL = URL(string: "https://mlb22.theshow.com/apis/roster_update.json?id=\(id)") else {
            print("Failed to generate URL")
            return
        }
        
        if updates[id] != nil { //already cached
            print("Found cached value")
            return
        }
        
        do {
            DispatchQueue.main.async { [weak self] in  //publish on main thread!
                self?.isFetching = true
            }
            let (data, _) = try await URLSession.shared.data(from: updateURL)
            let decodedResult:RosterUpdate = try JSONDecoder().decode(RosterUpdate.self, from: data)
            DispatchQueue.main.async { [weak self] in  //publish on main thread!
                guard let self = self else {
                    print("Self not in memory!")
                    return
                }
                self.updates.updateValue(decodedResult, forKey: id)
                self.isFetching = false
            }
            print("Fetched update with id: \(id)")
        } catch {
            print(error)
        }
    }
    
    func getCachedUpdateForID(_ id: Int) -> RosterUpdate? {
        if let update = updates[id] {
            return update
        }
        return nil
     }
    
}
