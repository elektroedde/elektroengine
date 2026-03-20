import SwiftUI

struct ContentView: View {
    @State var options = Options()

    var body: some View {
        VStack {
            ApplicationPicker(options: $options)

            MetalView(options: options)
                .frame(width: Settings.width, height: Settings.height)

            HStack {
                switch options.applicationChoice {
                case .FEM2D:
                    FEM2DControlPanel(options: $options)
                case .FEM3D:
                    EmptyView()
                case .Graphing2D:
                    Graphing2DControlPanel(options: $options)
                case .Graphing3D:
                    Graphing3DControlPanel(options: $options)
                case .RayMarching:
                    EmptyView()
                case .Particles:
                    EmptyView()
                }
            }
            .frame(width: Settings.width, height: Settings.interfaceHeight)
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
        Picker(selection: $options.applicationChoice, label: Text("Application Choice")) {
            ForEach(ApplicationWindow.allCases, id: \.self) { app in
                Text(app.label).tag(app)
            }
        }
        .frame(width: Settings.width, height: Settings.interfaceHeight)
        .pickerStyle(SegmentedPickerStyle())
    }
}
