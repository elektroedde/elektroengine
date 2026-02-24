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

@Observable
class Options {
  var equationChoice = EquationChoice.sin
}
