//
//  NavigationTitleView.swift
//  Keep
//
//  Created by myung hoon on 20/02/2024.
//

import SwiftUI

struct NavigationTitleView: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .foregroundColor(.black)
    }
}

struct NavigationTitleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTitleView(title: "Keep!")
    }
}
