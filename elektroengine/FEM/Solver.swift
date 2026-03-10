import Accelerate

// This class sends the problem to be solved to the appropriate solver
class Solver {
    static func solve(model: FEM_Model, complex: Bool = false, printDebug: Bool = false) -> [Float] {
        if complex {
            return ComplexSolver.solve(model: model, printDebug: printDebug)
        }
        return RealSolver.solve(model: model, printDebug: printDebug)
    }

    static func solveEigen(model: FEM_Model, numModes: Int = 10, printDebug: Bool = false) -> (eigenvalues: [Float], eigenvectors: [[Float]])? {
        return EigenSolver.solve(model: model, numModes: numModes, printDebug: printDebug)
    }
}
