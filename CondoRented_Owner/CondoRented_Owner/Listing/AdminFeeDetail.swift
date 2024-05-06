//
//  AdminFeeDetail.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 24/04/24.
//

import SwiftUI
import SwiftData

struct AdminFeeDetail: View {
    
    @State var adminFee: AdminFee
    var isActive: Bool {
        (adminFee.dateFinish == nil)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if isActive {
                    Text("active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                Text(adminFee.admin?.name ?? "-")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 5)
            HStack {
                Text("\(adminFee.percent, specifier: "%.0f")%")
                    .font(.largeTitle)
                Spacer()
                VStack (alignment:.leading) {
                    Text("From")
                        .font(.headline)
                    Text(adminFee.dateStart, style: .date)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    let container = ModelContainer.sharedInMemoryModelContainer
    let adminFee = AdminFee(id: "", listing: nil, dateStart: .now, percent: 15, admin: Admin(name: "pepe perez"))
    container.mainContext.insert(adminFee)
    return AdminFeeDetail(adminFee: adminFee)
        .modelContainer(container)
}
