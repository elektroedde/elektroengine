enum Settings {
    static var rotationSpeed: Float { 2.0 }
    static var translationSpeed: Float { 3.0 }
    static var mouseScrollSensitivity: Float { 0.1 }
    static var mousePanSensitivity: Float { 0.008 }
    static var touchPanSensitivity: Float { 0.05 }
    static var touchZoomSensitivity: Float { 5.0 }
}

import SwiftUI
import Observation

enum EquationChoice {
  case sin, cos, exp, vector
}

enum ApplicationWindow {
    case FEM2D, FEM3D, Graphing2D, Graphing3D
}
enum Colormap: Int32, CaseIterable {
    case jet = 0
    case viridis = 1
    case inferno = 2
    case plasma = 3
    case cividis = 4
    case magma = 5
    case turbo = 6

    var label: String {
        switch self {
        case .jet: "Jet"
        case .viridis: "Viridis"
        case .inferno: "Inferno"
        case .plasma: "Plasma"
        case .cividis: "Cividis"
        case .magma: "Magma"
        case .turbo: "Turbo"
        }
    }
}

enum FemChoice {
    case rectangle, chargedCylinder, waveguide
}

@Observable
class Options {
    var equationChoice = EquationChoice.sin
    var femChoice = FemChoice.rectangle
    var applicationChoice = ApplicationWindow.FEM2D
    var colormap = Colormap.jet
    var drawWireframe: Bool = false
    var showContours: Bool = false
}
