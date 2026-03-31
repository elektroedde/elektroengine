import SwiftUI

struct FEM2DControlPanel: View {
    @Bindable var options: Options

    var body: some View {
        HStack(spacing: 16) {
            // Model picker
            Menu {
                ForEach(FemChoice.allCases, id: \.self) { femChoice in
                    Button(femChoice.label) {
                        options.fem2D.femChoice = femChoice
                    }
                }
            } label: {
                Label(options.fem2D.femChoice.label, systemImage: "cube")
                    .font(.system(size: 11, design: .monospaced))
            }

            Divider()

            // Solve button
            Button {
                options.fem2D.solveFunction = true
            } label: {
                Label("Solve", systemImage: "play.fill")
                    .font(.system(size: 11, design: .monospaced))
            }
            .buttonStyle(.plain)

            // Eigenmode picker (conditional)
            if options.fem2D.femChoice == .rectangularEigenmodes || options.fem2D.femChoice == .circularEigenmodes {
                Divider()

                Menu {
                    ForEach(EigenmodeNumber.allCases, id: \.self) { mode in
                        Button(mode.label) {
                            options.fem2D.eigenmodeNumber = mode
                        }
                    }
                } label: {
                    Label("Mode \(options.fem2D.eigenmodeNumber.label)", systemImage: "waveform")
                        .font(.system(size: 11, design: .monospaced))
                }
            }

            Divider()

            // Toggles
            

            Toggle(isOn: $options.fem2D.showMesh) {
                Text("Show mesh")
                    .font(.system(size: 11, design: .monospaced))
            }
            .toggleStyle(.checkbox)

            Divider()

            // Colormap picker
            Menu {
                ForEach(Colormap.allCases, id: \.self) { colormap in
                    Button(colormap.label) {
                        options.colormap = colormap
                    }
                }
            } label: {
                Label(options.colormap.label, systemImage: "paintpalette")
                    .font(.system(size: 11, design: .monospaced))
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .foregroundStyle(.white)
    }
}
