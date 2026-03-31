import SwiftUI

struct RayMarchingControlPanel: View {
    @Bindable var options: Options
    @State private var numberText: String = ""

    var body: some View {
        HStack {
            TextField("Enter a number", text: $numberText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

            Button("Print") {
                print(numberText)
            }
        }
        .frame(width: Settings.width, height: Settings.interfaceHeight)
    }
}
