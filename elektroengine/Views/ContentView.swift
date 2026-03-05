
import SwiftUI

let interfaceHeight: CGFloat = 50
let width: CGFloat = 2420/2
let height: CGFloat = 1668/2 - interfaceHeight

struct ContentView: View {
    @State var options = Options()
    var body: some View {
        VStack {
            MetalView(options: options).border(Color.black, width: 2)
                .frame(width: width, height: height)
            HStack {

                Picker(
                    selection: $options.applicationChoice,
                    label: Text("Application choice")) {
                        Text("FEM").tag(ApplicationWindow.FEM)
                        Text("Graphing2D").tag(ApplicationWindow.Graphing2D)
                        Text("Graphing3D").tag(ApplicationWindow.Graphing3D)
                    }

                    .pickerStyle(SegmentedPickerStyle())

                Spacer()

                switch options.applicationChoice {
                case .FEM:
                    FEMControlPanel(options: $options)
                case .Graphing2D:
                    TempControl(options: $options)
                case .Graphing3D:
                    EmptyView()
                }

            }.frame(width: width, height: interfaceHeight)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

struct FEMControlPanel: View {
    @Binding var options: Options

    var body: some View {
        Menu {
            ForEach(Colormap.allCases, id: \.self) { colormap in
                Button(colormap.label) {
                    options.colormap = colormap
                }
            }
        } label: {
            Text(options.colormap.label)
        }

        Button() {
            print("SOlved")
        } label: {
            Text("Solve")
        }
    }
}

struct TempControl: View {
    @Binding var options: Options
    var body: some View {
        Picker(
            selection: $options.equationChoice,
            label: Text("Render Options")) {
                Text("sin").tag(EquationChoice.sin)
                Text("cos").tag(EquationChoice.cos)
                Text("exp").tag(EquationChoice.exp)
                Text("vector").tag(EquationChoice.vector)
            }

            .pickerStyle(SegmentedPickerStyle())
    }
}
