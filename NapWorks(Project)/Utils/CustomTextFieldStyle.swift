import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            .font(.body)
    }
}

struct CustomTextFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TextField("Email", text: .constant(""))
                .textFieldStyle(CustomTextFieldStyle())
            
            SecureField("Password", text: .constant(""))
                .textFieldStyle(CustomTextFieldStyle())
        }
        .padding()
    }
}
