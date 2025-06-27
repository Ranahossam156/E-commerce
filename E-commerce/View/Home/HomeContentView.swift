//
//  HomeContent.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI

struct HomeContentView: View {

    var body: some View {
        ScrollView{
            VStack {
                PromoCarousel() 
                BrandsSectionView()
                Spacer()
            }
        }
    }
}


struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}

