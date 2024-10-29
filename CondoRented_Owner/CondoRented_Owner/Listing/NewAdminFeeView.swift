//
//  NewAdminFeeView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 24/04/24.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct NewAdminFeeView: View {
    
    @State private var tmpContext: ModelContext
    @Binding var path: NavigationPath
    @State private var listing: Listing
    @State private var adminFee: AdminFee
    @State private var selectedAdmin: Admin? = nil
    @State private var endDate: Date = .now
    @Query private var admins: [Admin]
    
    init(tmpContext: ModelContext, path: Binding<NavigationPath>, listing: Listing) {
        self._path = path
        self.tmpContext = tmpContext
        self.listing = listing
        self.adminFee = AdminFee(listing: nil, dateStart: .now, percent: 15)
        tmpContext.insert(self.adminFee)
    }
    
    private var saveButtonDisabled: Bool {
        selectedAdmin == nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Adding new admin fee to")
                        .font(.headline)
                    Text(listing.title)
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal)
                Spacer()
                
            }
            Form {
                Section {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Percent")
                            .font(.title2)
                        HStack {
                            Button(action: {
                                adminFee.percent = max(0, adminFee.percent - 1)
                            }, label: {
                                Text("-")
                                    .foregroundStyle(Color.primary)
                                    .font(.largeTitle)
                                    .frame(width: 30)
                            })
                            .buttonStyle(BorderedButtonStyle())
                            
                            HStack(spacing: 0) {
                                Text("\(adminFee.percent, specifier: "%.0f")")
                                    .font(.largeTitle)
                                
                                Text("%")
                                    .font(.headline)
                                    .padding(.leading, 2)
                            }
                            .frame(minWidth: 80)
                            Button(action: {
                                adminFee.percent = min(100, adminFee.percent + 1)
                            }, label: {
                                Text("+")
                                    .foregroundStyle(Color.primary)
                                    .font(.largeTitle)
                                    .frame(width: 30)
                            })
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section {
                    DatePicker(selection: $adminFee.dateStart, displayedComponents: [.date]) {
                        Text("Start Date")
                    }
                    DatePickerOptional("End Date", prompt: "add date", selection: $adminFee.dateFinish)
                }
                
                Section {
                    Picker(selection: $selectedAdmin) {
                        if adminFee.admin == nil {
                            Text("Select Admin")
                                .tag(nil as Admin?)
                        }
                        
                        ForEach(admins, id:\.self) {
                            Text($0.name)
                                .tag($0 as Admin?)
                        }
                    } label: {
                        Text("Admin")
                    }
                }
                
                Section {
                    Button(action: {
                        saveAction()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.headline)
                            Spacer()
                        }
                    })
                    .disabled(saveButtonDisabled)
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedAdmin) { oldValue, newValue in
            if let newValue = newValue {
                let id = newValue.id
                
                let descriptor = FetchDescriptor<Admin>(predicate: #Predicate {$0.id == id})
                do {
                    let existElement = try tmpContext.fetch(descriptor)
                    if let value = existElement.first {
                        adminFee.admin = value
                    }
                } catch {
                    print("busta error: \(error)")
                }
                
//                adminFee.admin = newValue
            }
        }
        
        
    }
    
    func saveAction() {
        
        listing.adminFees?.append(adminFee)
        if !path.isEmpty {
            path.removeLast()
        }
        
        let db = Firestore.firestore()
        Task {
            await db.insert(adminFee)
            await db.insert(listing)
        }
        
//        try? tmpContext.save()
//        print(adminFee.admin?.name)
//        let id = listing.id
//        let descriptor = FetchDescriptor<Listing>(predicate: #Predicate {$0.id == id})
//        
//        do {
//            let existElement = try modelContext.fetch(descriptor)
//            if let listing = existElement.first {
//                listing.title = self.listing.title
//                try? modelContext.save()
//            } else {
//                modelContext.insert(listing)
//            }
//        } catch {
//            modelContext.insert(listing)
//        }
//        if !path.isEmpty {
//            path.removeLast()
//        }
        
    }
}

#Preview {
    let container = ModelContainer.sharedInMemoryModelContainer
    let admin = Admin(name: "Pedro")
    let admin2 = Admin(name: "juanito")
    container.mainContext.insert(admin)
    container.mainContext.insert(admin2)
    
    return NewAdminFeeView(tmpContext: container.mainContext, path: .constant(NavigationPath()), listing: Listing(title: "Distrito Vera"))
        .modelContainer(container)
}


struct DatePickerOptional: View {
    
    let label: String
    let prompt: String
    @Binding var date: Date?
    @State private var hidenDate: Date = Date()
    @State private var showDate: Bool = false
    
    init(_ label: String, prompt: String, selection: Binding<Date?>) {
        self.label = label
        self.prompt = prompt
        self._date = selection
    }
    
    var body: some View {
        ZStack {
            HStack {
                Text(label)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showDate {
                    Button {
                        showDate = false
                        date = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .tint(.primary)
                    }
                    DatePicker(
                        label,
                        selection: $hidenDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .onChange(of: hidenDate) { (_, newValue) in
                        date = newValue
                    }
                    
                } else {
                    Button {
                        showDate = true
                        date = hidenDate
                    } label: {
                        Text(prompt)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 105, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
