import Accelerate

class ComplexSolver {
    static var printDebug: Bool = false

    static func solve(model: FEM_Model, printDebug: Bool = false) -> [Float] {
        self.printDebug = printDebug
        let N = model.N
        let M = model.M

        printDebug ? print("=== Starting Complex Solver ===") : ()

        var K = [Float](repeating: 0, count: 2 * N * N)
        var b = [Float](repeating: 0, count: 2 * N)

        assemble(model: model, N: N, M: M, K: &K, b: &b)
        setDirichlet(model: model, N: N, K: &K, b: &b)
        setRobin(model: model, N: N, K: &K, b: &b)

        let H_z = solveCLAPACK(&K, b, N: N)!

        var real: [Float] = []
        var imag: [Float] = []
        var mag: [Float] = []
        for i in 0..<N {
            real.append(H_z[2 * i])
            imag.append(H_z[2 * i + 1])
            mag.append(sqrt(real[i]*real[i] + imag[i]*imag[i]))
        }
        return imag
    }

    // MARK: - Assembly

    static func assemble(model: FEM_Model, N: Int, M: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for element in 0..<M {
            let n0 = model.nodes[element * 3 + 0]
            let n1 = model.nodes[element * 3 + 1]
            let n2 = model.nodes[element * 3 + 2]
            let nodes = [n0, n1, n2]

            let x = [model.vertices[n0].x, model.vertices[n1].x, model.vertices[n2].x]
            let y = [model.vertices[n0].y, model.vertices[n1].y, model.vertices[n2].y]

            let area = 0.5 * (x[0]*(y[1] - y[2]) + x[1]*(y[2] - y[0]) + x[2]*(y[0] - y[1]))

            let b_e  = [y[1] - y[2], y[2] - y[0], y[0] - y[1]]
            let c_e = [x[2] - x[1], x[0] - x[2], x[1] - x[0]]

            let material: Float = model.material.count > 0 ? model.material[element] : 1
            let f: Float = model.f[element]

            for i in 0..<3 {
                b[2 * nodes[i]] += f * area / 3
                for j in 0..<3 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let K_e = (material*b_e[i]*b_e[j] + material*c_e[i]*c_e[j]) / (4*area) + area*model.beta*(1+dirac)/12
                    K[2 * (nodes[j] * N + nodes[i])] += K_e
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Assembly took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    // MARK: - Boundary Conditions

    static func setDirichlet(model: FEM_Model, N: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for (i, k) in model.dirichletNodes.enumerated() {
            let val = Float(model.dirichletValues[i])

            // Real part
            for j in 0..<N {
                if k == j {
                    K[2 * (j * N + j)] = 1
                    b[2 * j] = val
                } else {
                    let kr = K[2 * (k * N + j)]
                    b[2 * j] -= kr * val
                    K[2 * (j * N + k)] = 0
                    K[2 * (k * N + j)] = 0
                }
            }

            // Imaginary part
            for j in 0..<N {
                if k == j {
                    K[2 * (j * N + j) + 1] = 0
                    b[2 * j + 1] = 0
                } else {
                    let ki = K[2 * (k * N + j) + 1]
                    b[2 * j + 1] -= ki * val
                    K[2 * (j * N + k) + 1] = 0
                    K[2 * (k * N + j) + 1] = 0
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Dirichlet setup took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    static func setRobin(model: FEM_Model, N: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for k in 0..<model.robinElements.count {
            let node1 = model.robinNodes[k * 2]
            let node2 = model.robinNodes[k * 2 + 1]
            let nodes = [node1, node2]

            let dx = model.vertices[node2].x - model.vertices[node1].x
            let dy = model.vertices[node2].y - model.vertices[node1].y
            let length = sqrt(dx*dx + dy*dy)

            let qr = model.q[2 * k]
            let gr = model.gamma[2 * k]
            let qi = model.q[2 * k + 1]
            let gi = model.gamma[2 * k + 1]

            for i in 0..<2 {
                b[2 * nodes[i]]     += qr * length / 2
                b[2 * nodes[i] + 1] += qi * length / 2

                for j in 0..<2 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let scale = (1 + dirac) * length / 6

                    let idx = 2 * (nodes[j] * N + nodes[i])
                    K[idx]     += gr * scale
                    K[idx + 1] += gi * scale
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Robin setup took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    // MARK: - LAPACK

    /// Solves a complex linear system using LAPACK cgesv_.
    /// A: interleaved [real, imag] column-major matrix (2*n*n floats).
    /// b: interleaved [real, imag] RHS vector (2*n floats).
    static func solveCLAPACK(_ A: inout [Float], _ b: [Float], N: Int) -> [Float]? {
        let t1 = CFAbsoluteTimeGetCurrent()
        var x = b
        let n = b.count / 2

        var lda = Int32(n)
        var ldb = Int32(n)
        var ipiv = [__LAPACK_int](repeating: 0, count: n)
        var info: Int32 = 0

        A.withUnsafeMutableBufferPointer { aBuf in
            x.withUnsafeMutableBufferPointer { bBuf in
                let aPtr = OpaquePointer(aBuf.baseAddress!)
                let bPtr = OpaquePointer(bBuf.baseAddress!)
                withUnsafePointer(to: __LAPACK_int(n)) { nPtr in
                    withUnsafePointer(to: __LAPACK_int(1)) { nrhsPtr in
                        cgesv_(nPtr, nrhsPtr,
                               UnsafeMutablePointer(aPtr), &lda,
                               &ipiv,
                               UnsafeMutablePointer(bPtr), &ldb,
                               &info)
                    }
                }
            }
        }

        if info != 0 {
            print("LAPACK cgesv_ error \(info)")
            return nil
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ LAPACK cgesv_ took: [%.0fms]", (t2 - t1)*1000)) : ()
        return x
    }
}
