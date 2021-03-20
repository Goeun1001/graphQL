//
//  ProductUIApp.swift
//  ProductUI
//
//  Created by GoEun Jeong on 2021/03/20.
//

import SwiftUI

@main
struct ProductUIApp: App {
    let api = LOCAL()
    
    var body: some Scene {
        WindowGroup {
            api.contentView()
            api.productRow(id: "2")
        }
    }
}
