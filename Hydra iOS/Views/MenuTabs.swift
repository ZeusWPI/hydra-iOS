//
//  MenuTabView.swift
//  Hydra
//
//  Created by Ieben Smessaert on 27/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import SwiftUI

struct MenuTab {
    var title: String
}
struct MenuTabs: View {
    var fixed = true
    var blueColor = Color(#colorLiteral(red: 0.118, green: 0.392, blue: 0.784, alpha: 1))
    var tabs: [MenuTab]
    var geoWidth: CGFloat
    @Binding var selectedTab: Int
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(0 ..< tabs.count + 1, id: \.self) { row in
                            Button(action: {
                                withAnimation {
                                    selectedTab = row
                                }
                            }, label: {
                                VStack(spacing: 0) {
                                    HStack {
                                        if row != 0 {
                                            // Text
                                            Text(tabs[row - 1].title)
                                                .font(Font.system(size: 18, weight: .semibold))
                                                .foregroundColor(Color.white)
                                                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                        } else {
                                            Image(systemName: "info.square").foregroundColor(Color.white)
                                        }
                                    }
                                    .frame(width: fixed ? (geoWidth / CGFloat(tabs.count + 1)) : .none, height: 52)
                                    // Bar Indicator
                                    Rectangle().fill(selectedTab == row ? Color.white : Color.clear)
                                        .frame(height: 3)
                                }.fixedSize()
                                    .background(blueColor)
                            })
                            .accentColor(Color.white)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onChange(of: selectedTab) { target in
                        withAnimation {
                            proxy.scrollTo(target)
                        }
                    }
                }
            }
        }
    }
}
struct MenuTabs_Previews: PreviewProvider {
    static var previews: some View {
        MenuTabs(fixed: true,
             tabs: [.init(title: "Ma 1"),
                    .init(title: "Di 2"),
                    .init(title: "Wo 3"),
                    .init(title: "Do 4"),
                    .init(title: "Vr 5"),
             ],
             geoWidth: 375,
             selectedTab: .constant(0))
    }
}
