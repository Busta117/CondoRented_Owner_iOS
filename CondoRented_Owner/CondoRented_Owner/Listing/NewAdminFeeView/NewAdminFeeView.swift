//
//  NewAdminFeeView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 24/04/24.
//

import SwiftUI
import FirebaseFirestore

struct NewAdminFeeView: View {
    
    @State var viewModel: NewAdminFeeViewModel
    @State private var showingNewAdminAlert: Bool = false
    @State var newAdminName: String = ""
    
    init(viewModel: NewAdminFeeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigatorBar(title: "")
                .navigatorBackButton(title: "") {
                    viewModel.output(.backDidSelect)
                }
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.isEditing ? "Editing admin fee of" : "Adding new admin fee to")
                        .font(.headline)
                    Text(viewModel.listing.title)
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
                                viewModel.adminFee.percent = max(0, viewModel.adminFee.percent - 1)
                            }, label: {
                                Text("-")
                                    .foregroundStyle(Color.primary)
                                    .font(.largeTitle)
                                    .frame(width: 30)
                            })
                            .buttonStyle(BorderedButtonStyle())
                            
                            HStack(spacing: 0) {
                                Text("\(viewModel.adminFee.percent, specifier: "%.0f")")
                                    .font(.largeTitle)
                                
                                Text("%")
                                    .font(.headline)
                                    .padding(.leading, 2)
                            }
                            .frame(minWidth: 80)
                            Button(action: {
                                viewModel.adminFee.percent = min(100, viewModel.adminFee.percent + 1)
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
                    DatePicker(selection: $viewModel.adminFee.dateStart, displayedComponents: [.date]) {
                        Text("Start Date")
                    }
                    DatePickerOptional("End Date", prompt: "add date", selection: $viewModel.adminFee.dateFinish)
                }
                
                Section {
                    Picker(selection: $viewModel.selectedAdmin) {
                        if viewModel.adminFee.adminId.isEmpty {
                            Text("Select Admin")
                                .tag(nil as Admin?)
                        }
                        
                        ForEach(viewModel.admins, id:\.self) {
                            Text($0.name)
                                .tag($0 as Admin?)
                        }
                    } label: {
                        Text("Admin")
                    }
                } header: {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingNewAdminAlert.toggle()
                        }, label: {
                            Text("add new")
                                .font(.caption)
                                .bold()
                        })
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
                    .disabled(viewModel.saveButtonDisabled)
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Create new Admin!", isPresented: $showingNewAdminAlert) {
            TextField(text: $newAdminName) {}
            Button("Cancel") {
                // nothing
            }
            Button("Create") {
                viewModel.createNewAdmin(name: newAdminName)
            }
        } message: {
            Text("Enter admin name")
        }
    }
    
    func saveAction() {
        viewModel.save()
    }
}
//
//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    let admin = Admin(name: "Pedro")
//    let admin2 = Admin(name: "juanito")
//    container.mainContext.insert(admin)
//    container.mainContext.insert(admin2)
//    
//    return NewAdminFeeView(tmpContext: container.mainContext, path: .constant(NavigationPath()), listing: Listing(title: "Distrito Vera"))
//        .modelContainer(container)
//}


struct DatePickerOptional: View {
    
    let label: String
    let prompt: String
    @Binding var date: Date?
    @State private var hiddenDate: Date
    @State private var showDate: Bool = false
    
    init(_ label: String, prompt: String, selection: Binding<Date?>) {
        self.label = label
        self.prompt = prompt
        self._date = selection
        if let existingDate = selection.wrappedValue {
            hiddenDate = existingDate
        } else {
            hiddenDate = Date()
        }
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
                        selection: $hiddenDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .onChange(of: hiddenDate) { (_, newValue) in
                        date = newValue
                    }
                    
                } else {
                    Button {
                        showDate = true
                        date = hiddenDate
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
        .onAppear {
            if _date.wrappedValue != nil {
                showDate = true
            }
        }
    }
}
