import SwiftUI

struct FEM3DControlPanel: View {
    @Bindable var options: Options

    var body: some View {
        
        Toggle("Show mesh", isOn: $options.showContours)
        Toggle("Render wireframe", isOn: $options.drawWireframe)
    }
}
