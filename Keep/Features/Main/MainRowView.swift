//
//  MainRowView.swift
//  Keep
//
//  Created by myung hoon on 20/02/2024.
//

import SwiftUI

struct MainRowView: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(16)
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 10) {
                Image("naver")
                    .resizable()
                    .cornerRadius(8)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MainRowView_Previews: PreviewProvider {
    static var previews: some View {
        MainRowView(title: "Row")
    }
}
