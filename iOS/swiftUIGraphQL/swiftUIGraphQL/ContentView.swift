//
//  ContentView.swift
//  swiftUIGraphQL
//
//  Created by GoEun Jeong on 2021/03/20.
//

import SwiftUI

struct Product {
    var id: Int
    var name: String
    var price: Float
}

struct ContentView: View {
    @GraphQL(LOCAL.product.name)
    var name: String?
    
    var body: some View {
        Text(name ?? "Empty")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
