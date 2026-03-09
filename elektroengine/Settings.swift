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

enum FemChoice: CaseIterable {
    case rectangle, chargedCylinder, waveguide, eigenmode
    
    var label: String {
        switch self {
        case .rectangle: "Rectangle"
        case .chargedCylinder: "Charged Cylinder"
        case .waveguide: "Waveguide"
        case .eigenmode: "Eigenmode"
        }
    }
}

enum EigenmodeNumber: CaseIterable {
    case one, two, three, four, five, six, seven
    
    var label: String {
        switch self {
        case .one: "1"
        case .two: "2"
        case .three: "3"
        case .four: "4"
        case .five: "5"
        case .six: "6"
        case .seven: "7"
        }
    }
}

@Observable
class Options {
    var equationChoice = EquationChoice.sin
    var femChoice = FemChoice.eigenmode
    var applicationChoice = ApplicationWindow.FEM2D
    var colormap = Colormap.jet
    var drawWireframe: Bool = false
    var showContours: Bool = false
    var eigenmodeNumber = EigenmodeNumber.one
}
