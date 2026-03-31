import SwiftUI

// MARK: - App Settings

enum Settings {
    static let interfaceHeight: CGFloat = 50
    static let width: CGFloat = 2420 / 2
    static let height: CGFloat = 1668 / 2 - 2 * interfaceHeight
    
    static var rotationSpeed: Float { 2.0 }
    static var movementSpeed: Float { 10.0 }
    static var mouseScrollSensitivity: Float { 0.1 }
    static var mousePanSensitivity: Float { 0.008 }
    static var mouseLookSensitivity: Float { 0.005 }
    static var touchPanSensitivity: Float { 0.05 }
    static var touchZoomSensitivity: Float { 5.0 }
}

// MARK: - Enums

enum ApplicationWindow: CaseIterable {
    case FEM2D, FEM3D, Graphing2D, Graphing3D, RayMarching, Particles

    var label: String {
        switch self {
        case .FEM2D: "FEM2D"
        case .FEM3D: "FEM3D"
        case .Graphing2D: "Graphing2D"
        case .Graphing3D: "Graphing3D"
        case .RayMarching: "Ray Marching"
        case .Particles: "Particles"
        }
    }
}

enum EquationChoice: CaseIterable {
    case sin, vector

    var label: String {
        switch self {
        case .sin: "sin(x)"
        case .vector: "Vector"
        }
    }
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
    case square, chargedCylinder, waveguide, rectangularEigenmodes, circularEigenmodes

    var label: String {
        switch self {
        case .square: "Square"
        case .chargedCylinder: "Charged Cylinder"
        case .waveguide: "Waveguide"
        case .rectangularEigenmodes: "Rectangular Eigenmodes"
        case .circularEigenmodes: "Circular Eigenmodes"
        }
    }
}

enum SurfaceChoice: CaseIterable {
    case waveguide, gravity

    var label: String {
        switch self {
        case .waveguide: "Waveguide"
        case .gravity: "Gravity"
        }
    }
}

enum EigenmodeNumber: Int, CaseIterable {
    case one = 0, two, three, four, five, six, seven

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

    var index: Int { rawValue }
}

enum TMMode: CaseIterable {
    case TM11, TM12, TM21, TM22, TM1010

    var label: String {
        switch self {
        case .TM11: "TM11"
        case .TM12: "TM12"
        case .TM21: "TM21"
        case .TM22: "TM22"
        case .TM1010: "TM1010"
        }
    }
}

// MARK: - Options

@Observable
class Options {
    var applicationChoice = ApplicationWindow.FEM2D

    // MARK: Shared rendering
    var colormap = Colormap.jet
    var drawWireframe = false
    var showContours = false
    var displayMinValue: Float = 0
    var displayMaxValue: Float = 1

    // MARK: Per-scene settings
    var fem2D = FEM2DOptions()
    var graphing2D = Graphing2DOptions()
    var graphing3D = Graphing3DOptions()

    struct FEM2DOptions {
        var femChoice = FemChoice.rectangularEigenmodes
        var solveFunction = false
        var eigenmodeNumber = EigenmodeNumber.one
        var displayFrequency: Float = 0
        var quantity: String = ""
        var showMesh = false
    }

    struct Graphing2DOptions {
        var equationChoice = EquationChoice.vector
    }

    struct Graphing3DOptions {
        var surface = SurfaceChoice.gravity
        var tmMode = TMMode.TM11
    }
}
