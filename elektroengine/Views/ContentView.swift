import SwiftUI

struct ContentView: View {
    @State var options = Options()

    var body: some View {
        
        
            
            VStack(spacing: 0) {
                //ApplicationPicker(options: options)
                ModelInfoBar(options: options)

                MetalView(options: options)
                    .frame(width: Settings.width, height: Settings.height)

                HStack {
                    switch options.applicationChoice {
                    case .FEM2D:
                        FEM2DControlPanel(options: options)
                    case .FEM3D:
                        FEM3DControlPanel(options: options)
                    case .Graphing2D:
                        Graphing2DControlPanel(options: options)
                    case .Graphing3D:
                        Graphing3DControlPanel(options: options)
                    case .RayMarching:
                        RayMarchingControlPanel(options: options)
                    case .Particles:
                        EmptyView()
                    }
                }
                .frame(width: Settings.width, height: Settings.interfaceHeight)
            }
            
    
        
    }
}

#Preview {
    ContentView()
}

struct ModelInfoBar: View {
    @Bindable var options: Options

    var body: some View {
        HStack(spacing: 0) {
            // Info on the plot
            VStack(alignment: .leading, spacing: 2) {
                Text(options.fem2D.quantity)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                Text(options.applicationChoice.label)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Model-specific details
            VStack(alignment: .center, spacing: 2) {
                switch options.applicationChoice {
                case .FEM2D:
                    if options.fem2D.femChoice == .rectangularEigenmodes || options.fem2D.femChoice == .circularEigenmodes {
                        Text("Cut-off frequency = \(String(format: "%.3g", options.fem2D.displayFrequency)) MHz")
                            .font(.system(size: 12, design: .monospaced))
                    } else {
                        Text(options.fem2D.femChoice.label)
                            .font(.system(size: 12, design: .monospaced))
                    }
                case .FEM3D:
                    Text("3D Solver")
                        .font(.system(size: 12, design: .monospaced))
                case .Graphing2D:
                    Text(options.graphing2D.equationChoice.label)
                        .font(.system(size: 12, design: .monospaced))
                case .Graphing3D:
                    Text(options.graphing3D.surface.label)
                        .font(.system(size: 12, design: .monospaced))
                    if options.graphing3D.surface == .waveguide {
                        Text(options.graphing3D.tmMode.label)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                case .RayMarching:
                    Text("Ray Marching")
                        .font(.system(size: 12, design: .monospaced))
                case .Particles:
                    Text("Particles")
                        .font(.system(size: 12, design: .monospaced))
                }
            }

            Spacer()

            // Min/max values
            if options.applicationChoice == .FEM2D || options.applicationChoice == .FEM3D {
                
            }
        }
        .padding(.horizontal, 12)
        .frame(width: Settings.width, height: Settings.interfaceHeight)
        .background(.black)
        .foregroundStyle(.white)
    }

    private var modelName: String {
        switch options.applicationChoice {
        case .FEM2D: options.fem2D.femChoice.label
        case .FEM3D: "Cube"
        case .Graphing2D: options.graphing2D.equationChoice.label
        case .Graphing3D: options.graphing3D.surface.label
        case .RayMarching: "Ray Marching"
        case .Particles: "Particles"
        }
    }
}

struct ApplicationPicker: View {
    @Bindable var options: Options

    var body: some View {
        Picker(selection: $options.applicationChoice, label: Text("Application Choice")) {
            ForEach(ApplicationWindow.allCases, id: \.self) { app in
                Text(app.label).tag(app)
            }
        }
        .frame(width: Settings.width, height: Settings.interfaceHeight)
        .pickerStyle(SegmentedPickerStyle())
    }
}
