//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Nitish Solanki on 26/04/22.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var showingConfirmation = false
    @State private var sorting = false
    
    let filter: FilterType
    
    var body: some View {
        NavigationView{
            List {
                if(sorting == true){
                    ForEach(filteredProspects.sorted()) { prospect in
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                            if filter == .none {
                                    if prospect.isContacted {
                                        Image(systemName: "person.crop.circle.fill.badge.checkmark" )
                                    }
                                }
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(.blue)
                            } else {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                                }
                                .tint(.green)
                                
                                Button {
                                    addNotifications(for: prospect)
                                } label: {
                                    Label("Remind me", systemImage: "bell")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                } else{
                    ForEach(filteredProspects) { prospect in
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                            if filter == .none {
                                    if prospect.isContacted {
                                        Image(systemName: "person.crop.circle.fill.badge.checkmark" )
                                    }
                                }
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(.blue)
                            } else {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                                }
                                .tint(.green)
                                
                                Button {
                                    addNotifications(for: prospect)
                                } label: {
                                    Label("Remind me", systemImage: "bell")
                                }
                                .tint(.orange)
                            }
                        }
                    }

                }
                
                                
            }
            .confirmationDialog("How to Sort", isPresented: $showingConfirmation) {
                Button("By name"){
                    sorting = true
                }
                Button("Most recent"){
                    sorting = false
                }
            }

                .navigationTitle(title)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button {
                                    isShowingScanner = true
                                } label: {
                                    Label("Scan", systemImage: "qrcode.viewfinder")
                                }
                                
                                Button {
                                        showingConfirmation = true
                                    } label: {
                                        Label("View", systemImage: "note")
                                    }

                            }
                        }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Nitish Solanki\nnitishsolanki888@gmail.com", completion: handleScan)
                }
            }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
        
    }
    
    
    
//    var sortedProspects: [Prospect] {
//        switch sort {
//        case .name:
//            return
//        case .recent:
//            return
//        }
//    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotifications(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh!")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
