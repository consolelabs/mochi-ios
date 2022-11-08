//
//  AppSidebarNavigation.swift
//  Bitsfi
//
//  Created by Oliver Le on 04/06/2022.
//

import SwiftUI

struct AppSidebarNavigation: View {

    enum NavigationItem {
        case dashboard
        case portfolio
        case performance
        case market
    }

    @State private var selection: NavigationItem? = .portfolio
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: NavigationItem.dashboard, selection: $selection) {
                    Text("Dashboard")
                } label: {
                    Label("Dashboard", systemImage: "list.bullet")
                }
                
                NavigationLink(tag: NavigationItem.portfolio, selection: $selection) {
                    Text("Portfolio")
                } label: {
                    Label("Portfolio", systemImage: "heart")
                }
            
              NavigationLink(tag: NavigationItem.performance, selection: $selection) {
                    Text("Performance")
                } label: {
                    Label("Performance", systemImage: "book.closed")
                }
              
              NavigationLink(tag: NavigationItem.market, selection: $selection) {
                    Text("Market")
                } label: {
                    Label("Market", systemImage: "book.closed")
                }
            }
            .navigationTitle("bits.fi")
            
            Text("Select a category")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background()
                .ignoresSafeArea()
          
          Text("Hello")
        }
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
    }
}

