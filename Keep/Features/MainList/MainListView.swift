//
//  MainListView.swift
//  Keep
//
//  Created by myung hoon on 20/02/2024.
//

import SwiftUI

struct MainListView: View {
    // MARK: - viewModel
    @StateObject private var viewModel = MainListViewModel()
    
    // MARK: - states
    @State private var selectedItem: MainListItem?
    @State private var presentAddItemView = false
    @State private var presentSettingsView = false
    @State private var searchText = ""
    
    // MARK: -
    @EnvironmentObject var authManager: AuthManager

    init(searchText: String = "") {
        self.searchText = searchText
        UISearchBar.appearance().tintColor = .systemBlue
        
        print("###local storage path(for debugging on simulator) : \(String(describing: try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)))")
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.items, id: \.self) { item in
                MainRowView(title: item.title)
                    .listRowSeparator(.hidden)
                    .frame(height: 60)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .onTapGesture {
                        selectedItem = item
                    }
                    .listRowBackground(Color.mainGray)
            }
            .fullScreenCover(item: $selectedItem, content: { item in
                CurrentItemView(id: item.id, itemType: item.itemType) {
                    viewModel.fetch.send(())
                }
            })
            .listStyle(PlainListStyle())
            .background(Color.mainGray)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: HStack(content: {
                NavigationTitleView(title: "Keep!")
            }), trailing: HStack(content: {
                Button {
                    authManager.isAuthenticated.toggle()
                } label: {
                    Image(systemName: "lock")
                        .foregroundColor(Color(uiColor: UIColor.systemBlue))
                }
                
                Button {
                    presentAddItemView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(uiColor: UIColor.systemBlue))
                }
                .fullScreenCover(isPresented: $presentAddItemView) {
                    AddItemView() {
                        viewModel.fetch.send(())
                    }
                }
                
                Button {
                    presentSettingsView.toggle()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.pink)
                        .padding(.trailing, -20)
                }
                
                NavigationLink(destination: SettingsView(), isActive: $presentSettingsView) {
                    EmptyView()
                }
                .hidden()
                
            }))
        }
        .onAppear(perform: {
            viewModel.fetch.send(())
        })
        .searchable(text: $searchText)

    }
}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
