//
//  MainListView.swift
//  Keep
//
//  Created by myung hoon on 20/02/2024.
//

import SwiftUI

struct MainListView: View {
    let items = ["1",  "2", "3", "4", "5", "5", "5", "5", "5", "5"]
    
    @State private var searchText = ""

    init(searchText: String = "") {
        self.searchText = searchText
        UISearchBar.appearance().tintColor = .systemBlue
    }
    
    var body: some View {
        TransparenNavigationView {
            List(items, id: \.self) { item in
                MainRowView(title: item)
                    .listRowSeparator(.hidden)
                    .frame(height: 60)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .background(Color.mainGray)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack(content: {
                NavigationTitleView(title: "Keep!")
            }), trailing: HStack(content: {
                Button {
                    print("plus tap")
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(uiColor: UIColor.systemBlue))
                }
                
                Button {
                    print("settings tap")
                } label: {
                Image(systemName: "chevron.right")
                        .foregroundColor(.pink)
                }
            }))
            .listStyle(PlainListStyle())
            
        }
        .searchable(text: $searchText)
    }
}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}