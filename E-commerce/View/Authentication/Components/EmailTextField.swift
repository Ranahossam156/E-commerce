//
//  EmailTextField.swift
//  E-commerce
//
//  Created by Macos on 28/05/2025.
//

import SwiftUI

struct CustomTextField: View {
    var label: String
    var placeholder: String
    var iconName: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(Color("myBlack"))
            HStack {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                    .frame(width: 32, height: 32)
                
                Spacer().frame(width: 18)
                
                TextField(placeholder, text: $text)
                    .foregroundColor(Color("myGray"))
            }
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
            )
            .padding(.horizontal, 4)
        }
    }
}


struct CustomTextField_Previews: PreviewProvider {
    @State static var previewText = ""
    
    static var previews: some View {
        CustomTextField(label: "Email", placeholder: "Enter your email", iconName: "mail2", text: $previewText)
    }
}

