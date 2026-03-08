
import SwiftUI

let interfaceHeight: CGFloat = 50
let width: CGFloat = 2420/2
let height: CGFloat = 1668/2 - 2*interfaceHeight

struct ContentView: View {
    @State var options = Options()
    var body: some View {
        VStack {
            
            ApplicationPicker(options: $options)
            
            MetalView(options: options)
                .frame(width: width, height: height)
            HStack {
                Spacer()

                switch options.applicationChoice {
                case .FEM2D:
                    FEMControlPanel(options: $options)
                case .FEM3D:
                    EmptyView()
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

struct ApplicationPicker: View {
    @Binding var options: Options

    
    var body: some View {
        Picker(
            selection: $options.applicationChoice,
            label: Text("Application Choice")) {
                Text("FEM2D").tag(ApplicationWindow.FEM2D)
                Text("FEM3D").tag(ApplicationWindow.FEM3D)
                Text("Graphing2D").tag(ApplicationWindow.Graphing2D)
                Text("Graphing3D").tag(ApplicationWindow.Graphing3D)
            }
            .frame(width: width, height: interfaceHeight)

            .pickerStyle(SegmentedPickerStyle())
    }
}

struct FEMControlPanel: View {
    @Binding var options: Options

    var body: some View {
        Picker(
            selection: $options.femChoice,
            label: Text("FEM Model")) {
                Text("Rectangle").tag(FemChoice.rectangle)
                Text("Charged Cylinder").tag(FemChoice.chargedCylinder)
                Text("Waveguide").tag(FemChoice.waveguide)

            }

            .pickerStyle(SegmentedPickerStyle())
        Toggle("Show contours", isOn: $options.showContours)

        Toggle("Render wireframe", isOn: $options.drawWireframe)
        Menu {
            ForEach(Colormap.allCases, id: \.self) { colormap in
                Button(colormap.label) {
                    options.colormap = colormap
                }
            }
        } label: {
            Text(options.colormap.label)
        }
        Spacer()
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
