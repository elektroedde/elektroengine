import Accelerate

class Solver {
    static var N: Int = 0
    static var M: Int = 0
    static var model: FEM_Model!
    static var complex: Bool = false
    static var multiplier: Int!
    static var printDebug: Bool = false
    static func solve(model: FEM_Model, complex: Bool = false, printDebug: Bool = false) -> [Float] {
        self.model = model
        self.complex = complex
        N = self.model!.N
        M = self.model!.M
        multiplier = complex ? 2 : 1
        self.printDebug = printDebug

        if complex {
            return solveComplex()
        }
        return solveReal()
    }

    static func solveReal() -> [Float] {
        if(printDebug) { print("=== Starting Real Solver ===") }

        var K = [Float](repeating: 0, count: N * N)
        var b = [Float](repeating: 0, count: N)

        assembleMatrix(K: &K, b: &b)

        setDirichlet(K: &K, b: &b)

        if(model.robinElements.count > 0) { setRobin(K: &K, b: &b) }


        return solveLAPACK(&K, b)!
    }


    static func solveComplex() -> [Float] {
        if(printDebug) { print("=== Starting Complex Solver ===") }

        var K = [Float](repeating: 0, count: 2 * N * N)
        var b = [Float](repeating: 0, count: 2 * N)

        assembleMatrix(K: &K, b: &b)

        setDirichlet(K: &K, b: &b)

        setRobin(K: &K, b: &b)

        let H_z = solveCLAPACK(&K, b)!

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


    /// Assembles the matrices K and b to solve Kx=b for x.
    static func assembleMatrix(K: inout [Float], b: inout [Float]) {
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

            //Danger
            let material: Float = model.material.count > 0 ? model.material[element] : 1
            let f: Float = model.f[element]

            for i in 0..<3 {
                b[multiplier * nodes[i]] += f * area / 3
                for j in 0..<3 {
                    var dirac: Float = 0
                    if(i == j) {
                        dirac = 1
                    }
                    let K_e = (material*b_e[i]*b_e[j] + material*c_e[i]*c_e[j]) / (4*area) + area*model.beta*(1+dirac)/12
                    K[multiplier * (nodes[j] * N + nodes[i])] += K_e

                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        if(printDebug) {  print(String(format: "Assembly took: %.0f ms", (t2 - t1)*1000)) }

    }

    static func setDirichlet(K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()
        for (i, k) in model.dirichletNodes.enumerated() {
            let val = Float(model.dirichletValues[i])
            for j in 0..<N {
                if k == j {
                    K[multiplier * (j * N + j)] = 1
                    b[multiplier * j] = val

                } else {
                    let kr = K[multiplier * (k * N + j)]
                    b[multiplier * j]     -= kr * val
                    K[multiplier * (j * N + k)]     = 0
                    K[multiplier * (k * N + j)]     = 0
                }
            }

            if(complex) {
                for j in 0..<N {
                    if k == j {

                        K[multiplier * (j * N + j) + 1] = 0
                        b[multiplier * j + 1] = 0

                    } else {

                        let ki = K[multiplier * (k * N + j) + 1]
                        b[multiplier * j + 1] -= ki * val
                        K[multiplier * (j * N + k) + 1] = 0
                        K[multiplier * (k * N + j) + 1] = 0
                    }
                }
            }
        }
        let t2 = CFAbsoluteTimeGetCurrent()
        if(printDebug) {  print(String(format: "Dirichlet setup took: %.0f ms", (t2 - t1)*1000)) }
    }

    static func setRobin(K: inout [Float], b: inout [Float], ) {
        let t1 = CFAbsoluteTimeGetCurrent()
        for k in 0..<model.robinElements.count {
            let node1 = model.robinNodes[k*multiplier]
            let node2 = model.robinNodes[k*multiplier + 1]
            let nodes = [node1, node2]

            let dx = model.vertices[node2].x - model.vertices[node1].x
            let dy = model.vertices[node2].y - model.vertices[node1].y
            let length = sqrt(dx*dx + dy*dy)

            // Complex q and gamma: [real, imag] pairs
            let qr = model.qComplex[multiplier * k]
            let gr = model.gammaComplex[multiplier * k]


            var qi: Float = 0
            var gi: Float = 0
            if(complex) {
                qi = model.qComplex[multiplier * k + 1]
                gi = model.gammaComplex[multiplier * k + 1]
            }

            for i in 0..<2 {

                b[multiplier * nodes[i]]     += qr * length / 2

                if(complex) {
                    b[2 * nodes[i] + 1] += qi * length / 2
                }
                for j in 0..<2 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let scale = (1 + dirac) * length / 6

                    let idx = multiplier * (nodes[j] * N + nodes[i])
                    K[idx]     += gr * scale

                    if(complex) {
                        K[idx + 1] += gi * scale
                    }
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        if(printDebug) {  print(String(format: "Robin took: %.0f ms", (t2 - t1)*1000)) }

    }

    static func solveLAPACK(_ A_flat: inout [Float], _ b: [Float]) -> [Float]? {
        let t1 = CFAbsoluteTimeGetCurrent()

        let n = b.count

        var b_copy = b

        var lda = Int32(n)
        var ldb = Int32(n)
        var ipiv = [__LAPACK_int](repeating: 0, count: n)
        var info: Int32 = 0

        withUnsafePointer(to: __LAPACK_int(n)) { n in
            withUnsafePointer(to: __LAPACK_int(1)) { nrhs in
                sgesv_(n, nrhs, &A_flat, &lda, &ipiv, &b_copy, &ldb, &info)
            }
        }

        if info != 0 {
            print("LAPACK sgesv_ error \(info) ")
            return nil
        }
        let t2 = CFAbsoluteTimeGetCurrent()
        if(printDebug) {  print(String(format: "LAPACK sgesv_ took: %.0f ms", (t2 - t1)*1000)) }
        return b_copy
    }

    /// Solves a complex linear system using LAPACK cgesv_.
    /// A: interleaved [real, imag] column-major matrix (2*n*n floats).
    /// b: interleaved [real, imag] RHS vector (2*n floats).
    /// n: number of complex unknowns.
    static func solveCLAPACK(_ A: inout [Float], _ b: [Float]) -> [Float]? {
        let t1 = CFAbsoluteTimeGetCurrent()
        var x = b
        let n = b.count / 2

        var lda = Int32(n)
        var ldb = Int32(n)
        var ipiv = [__LAPACK_int](repeating: 0, count: n)
        var info: Int32 = 0

        // cgesv_ interprets Float arrays as interleaved complex pairs
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
        if(printDebug) {  print(String(format: "LAPACK cgesv_ took: %.0f ms", (t2 - t1)*1000)) }
        return x
    }
}
