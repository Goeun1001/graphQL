//
//  ContentView.swift
//  ProductUI
//
//  Created by GoEun Jeong on 2021/03/20.
//

import SwiftUI

struct ProductCell: View {
    @GraphQL(LOCAL.ProductType.name)
    var name
    
    @GraphQL(LOCAL.ProductType.price)
    var price
    
    var body: some View {
        VStack {
            Text(name ).bold()
            Text(price )
        }
    }
}

struct ContentView: View {
    @GraphQL(LOCAL.allProducts)
    var products: [ProductCell.ProductType]?
    
    var body: some View {
        products.map { news in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center) {
                    Spacer()

                    ForEach(news, id: \.name) { news in
                        ProductCell(productType: news)
//                        ProductCell(newsStory: news).frame(width: 280, height: 340).padding(.vertical, 16).padding(.horizontal, 8)
                    }
                }
            }
        }
    }
}

struct ProductRow: View {
    let api: LOCAL
    
    @GraphQL(LOCAL.product.name)
    var name: String?
    
    @GraphQL(LOCAL.product.price)
    var price: String?
    
    var body: some View {
        HStack {
            name.map { Text($0) }
            price.map { Text($0) }
        }
    }
}




//struct Test: View {
//    @GraphQL(TMDB.movies.movie(id: .value(11)))
//    var starWars: MovieCell.IMovie
//
//    @GraphQL(TMDB.movies.movie(id: .value(12)))
//    var findingNemo: MovieCell.IMovie
//
//    var body: some View {
//        HStack(spacing: 32) {
//            MovieCell(iMovie: starWars)
//
//            MovieCell(iMovie: findingNemo)
//        }
//        .padding()
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
