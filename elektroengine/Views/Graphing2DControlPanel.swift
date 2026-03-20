import SwiftUI

struct Graphing2DControlPanel: View {
    @Binding var options: Options

    var body: some View {
        Picker(selection: $options.equationChoice, label: Text("Equation Choice")) {
            ForEach(EquationChoice.allCases, id: \.self) { eq in
                Text(eq.label).tag(eq)
            }
        }
        .frame(width: Settings.width, height: Settings.interfaceHeight)
        .pickerStyle(SegmentedPickerStyle())
    }
}
