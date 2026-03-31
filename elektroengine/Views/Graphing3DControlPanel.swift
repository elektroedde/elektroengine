import SwiftUI

struct Graphing3DControlPanel: View {
    @Bindable var options: Options

    var body: some View {
        VStack {
            Text("Select Surface")
            Menu(options.graphing3D.surface.label) {
                ForEach(SurfaceChoice.allCases, id: \.self) { surface in
                    Button(surface.label) {
                        options.graphing3D.surface = surface
                    }
                }
            }
        }

        Spacer()

        if options.graphing3D.surface == .waveguide {
            VStack {
                Text("Select TM Mode:")
                Menu(options.graphing3D.tmMode.label) {
                    ForEach(TMMode.allCases, id: \.self) { mode in
                        Button(mode.label) {
                            options.graphing3D.tmMode = mode
                        }
                    }
                }
            }
        }

        Menu {
            ForEach(Colormap.allCases, id: \.self) { colormap in
                Button(colormap.label) {
                    options.colormap = colormap
                }
            }
        } label: {
            Text(options.colormap.label)
        }

        Toggle("Render wireframe", isOn: $options.drawWireframe)

        Spacer()
    }
}
