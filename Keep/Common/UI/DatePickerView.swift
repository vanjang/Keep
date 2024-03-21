//
//  DatePickerView.swift
//  Keep
//
//  Created by myung hoon on 21/03/2024.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.clear
            
            VStack {
                DatePicker("Select a date", selection: Binding<Date>(get: { selectedDate ?? Date() }, set: { selectedDate = $0 }), displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding()
                
                Button("Done") {
                    isPresented.toggle()
                }
            }
        }
    }
}
