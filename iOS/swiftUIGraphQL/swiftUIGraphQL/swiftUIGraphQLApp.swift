//
//  swiftUIGraphQLApp.swift
//  swiftUIGraphQL
//
//  Created by GoEun Jeong on 2021/03/20.
//

import SwiftUI

@main
struct swiftUIGraphQLApp: App {
    let api = LOCAL()
    
    var body: some Scene {
        WindowGroup {
            api.contentView(id: "2")
        }
    }
}
