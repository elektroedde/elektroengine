import Accelerate

// This class sends the problem to be solved to the appropriate solver
class Solver3D {
    static func solve(model: FEM_Model, printDebug: Bool = false) -> [Float] {
        return RealSolver.solve3D(model: model, printDebug: printDebug)
    }
}

