import SwiftUI

struct CustomPasswordField: View {
    var label: String
    var placeholder: String
    var iconName: String
    @Binding var text: String

    @State private var showPassword: Bool = false

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

                if showPassword {
                    TextField(placeholder, text: $text)
                        .foregroundColor(Color("myGray"))
                } else {
                    SecureField(placeholder, text: $text)
                }

                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(showPassword ? "hide" : "visible")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                }
                .padding(.trailing, 8)
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
struct CustomPasswordField_Previews: PreviewProvider {
    @State static var previewPassword = ""

    static var previews: some View {
        CustomPasswordField(label: "Password", placeholder: "Enter your password", iconName: "lock2", text: $previewPassword)
    }
}
