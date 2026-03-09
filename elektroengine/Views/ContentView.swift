
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
        VStack {
            Text("Select FEM Model")
            Menu(options.femChoice.label) {
                ForEach(FemChoice.allCases, id: \.self) { femChoice in
                    Button(femChoice.label) {
                        options.femChoice = femChoice
                    }
                }
            }.padding(.leading, 10)
        }
        
        Spacer()

            
        if(options.femChoice == .eigenmode) {
            VStack {
                Text("Select eigenmode:")
                Menu(options.eigenmodeNumber.label) {
                    ForEach(EigenmodeNumber.allCases, id: \.self) { eigenmodeNumber in
                        Button(eigenmodeNumber.label) {
                            options.eigenmodeNumber = eigenmodeNumber
                        }
                    }
                }
            }
            
        }
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
