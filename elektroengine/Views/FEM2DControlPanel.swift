import SwiftUI

struct FEM2DControlPanel: View {
    @Binding var options: Options

    var body: some View {
        VStack {
            Text("Select FEM Model")
            Menu(options.femChoice.label) {
                ForEach(FemChoice.allCases, id: \.self) { femChoice in
                    Button(femChoice.label) {
                        options.femChoice = femChoice }}}
            .padding(.leading, 10)
        }

        Spacer()

        if options.femChoice == .eigenmode {
            VStack {
                Text("Select eigenmode:")
                Menu(options.eigenmodeNumber.label) {
                    ForEach(EigenmodeNumber.allCases, id: \.self) { eigenmodeNumber in
                        Button(eigenmodeNumber.label) {
                            options.eigenmodeNumber = eigenmodeNumber }}}}} //Is this fine?

        Toggle("Show contours", isOn: $options.showContours)
        Toggle("Render wireframe", isOn: $options.drawWireframe)

        Menu {
            ForEach(Colormap.allCases, id: \.self) { colormap in
                Button(colormap.label) {
                    options.colormap = colormap }}
        } label: {
            Text(options.colormap.label)
        }

        Spacer()
    }
}
