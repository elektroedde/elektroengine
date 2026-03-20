import Accelerate

class RealSolver {
    static var printDebug: Bool = false

    static func solve(model: FEM_Model, printDebug: Bool = false) -> [Float] {
        self.printDebug = printDebug
        let N = model.N
        let M = model.M

        printDebug ? print("=== Starting Real Solver ===") : ()

        var K = [Float](repeating: 0, count: N * N)
        var b = [Float](repeating: 0, count: N)

        assemble(model: model, N: N, M: M, K: &K, b: &b)
        setDirichlet(model: model, N: N, K: &K, b: &b)

        if model.robinElements.count > 0 {
            setRobin(model: model, N: N, K: &K, b: &b)
        }

        return solveLAPACK(&K, b, N: N)!
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
                b[nodes[i]] += f * area / 3
                for j in 0..<3 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let K_e = (material*b_e[i]*b_e[j] + material*c_e[i]*c_e[j]) / (4*area) + area*model.beta*(1+dirac)/12
                    K[nodes[j] * N + nodes[i]] += K_e
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Assembly took: [%.0fms]", (t2 - t1)*1000)) : ()
    }
    
    static func assembleQuadratic(model: FEM_Model, N: Int, M: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for element in 0..<M {
            let n0 = model.nodes[element * 3 + 0]
            let n1 = model.nodes[element * 3 + 1]
            let n2 = model.nodes[element * 3 + 2]
            let nodes = [n0, n1, n2]

            let x = [model.vertices[n0].x, model.vertices[n1].x, model.vertices[n2].x]
            let y = [model.vertices[n0].y, model.vertices[n1].y, model.vertices[n2].y]
            if(element == 12310) {
                print("=== Node 1: ", x[0], y[0])
                print("=== Node 2: ", x[1], y[1])
                print("=== Node 3: ", x[2], y[2])
                print("Now adding quadratic elements")
                print("=== Node 4: ", (x[0]+x[1])/2, (y[0]+y[1])/2)
                print("=== Node 5: ", (x[1]+x[2])/2, (y[1]+y[2])/2)
                print("=== Node 6: ", (x[2]+x[0])/2, (y[2]+y[0])/2)




            }

            let area = 0.5 * (x[0]*(y[1] - y[2]) + x[1]*(y[2] - y[0]) + x[2]*(y[0] - y[1]))

            let b_e  = [y[1] - y[2], y[2] - y[0], y[0] - y[1]]
            let c_e = [x[2] - x[1], x[0] - x[2], x[1] - x[0]]

            let material: Float = model.material.count > 0 ? model.material[element] : 1
            let f: Float = model.f[element]
            let beta: Float = 0
            
            var A_e = [Float](repeating: 0, count: 6*6)
            var B_e = [Float](repeating: 0, count: 6*6)

            for i in 0..<3 {
                
                for j in 0..<3 {
                    let dirac: Float = (i == j) ? 1 : 0
                    A_e[j * 6 + i] = (4*dirac - 1)/(12*area)*(b_e[i]*b_e[j] + c_e[i]*c_e[j])
                }
            }
            
            A_e[0*6 + 3] = -4*A_e[0*6 + 1]
            A_e[1*6 + 3] = -4*A_e[0*6 + 1]
            
            A_e[0*6 + 5] = -4*A_e[2]
            A_e[2*6 + 5] = -4*A_e[2]
            
            A_e[1*6 + 4] = -4*A_e[1*6 + 2]
            A_e[2*6 + 4] = -4*A_e[1*6 + 2]
            
            A_e[4] = 0
            A_e[1*6 + 5] = 0
            A_e[2*6 + 3] = 0
            
            //Heres supposed to be alphax alphay later
            A_e[3*6 + 3] = 2/(3*area)*(b_e[0]*b_e[0] + b_e[0]*b_e[1] + b_e[1]*b_e[1] + c_e[0]*c_e[0] + c_e[0]*c_e[1] + c_e[1]*c_e[1])
            A_e[4*6 + 4] = 2/(3*area)*(b_e[1]*b_e[1] + b_e[1]*b_e[2] + b_e[2]*b_e[2] + c_e[1]*c_e[1] + c_e[1]*c_e[2] + c_e[2]*c_e[2])
            A_e[5*6 + 5] = 2/(3*area)*(b_e[2]*b_e[2] + b_e[2]*b_e[0] + b_e[0]*b_e[0] + c_e[2]*c_e[2] + c_e[2]*c_e[0] + c_e[0]*c_e[0])
            
            A_e[3*6 + 4] = 1/(3*area)*(b_e[1]*b_e[2] + 2*b_e[0]*b_e[2] + b_e[0]*b_e[1] + b_e[1]*b_e[1] + c_e[1]*c_e[2] + 2*c_e[0]*c_e[2]+c_e[0]*c_e[1]+c_e[1]*c_e[1])
            A_e[3*6 + 5] = 1/(3*area)*(b_e[0]*b_e[2] + 2*b_e[1]*b_e[2] + b_e[0]*b_e[1] + b_e[0]*b_e[0] + c_e[0]*c_e[2] + 2*c_e[1]*c_e[2]+c_e[0]*c_e[1]+c_e[0]*c_e[0])
            A_e[4*6 + 5] = 1/(3*area)*(b_e[2]*b_e[0] + 2*b_e[1]*b_e[0] + b_e[1]*b_e[2] + b_e[2]*b_e[2] + c_e[2]*c_e[0] + 2*c_e[1]*c_e[0]+c_e[1]*c_e[2]+c_e[2]*c_e[2])

            let bmat: [Float] = [6, -1, -1, 0, -4, 0,
                                 -1, 6, -1, 0, 0, -4,
                                 -1, -1, 6, -4, 0, 0,
                                 0, 0, -4, 32, 16, 16,
                                 -4, 0, 0, 16, 32, 16,
                                 0, -4, 0, 16, 16, 32]
            for i in 0..<6*6 {
                B_e[i] = beta*area/180 * bmat[i]
            }


            //Now need to assemble K and b i think
            // Get the 6 global node indices for this element
            let localNodes = (0..<6).map { model.nodes[element * 6 + $0] }

            for i in 0..<6 {
                b[localNodes[i]] = 0  // appropriate quadratic load vector
                for j in 0..<6 {
                    K[localNodes[j] * N + localNodes[i]] += material * A_e[j * 6 + i] + B_e[j * 6 + i]
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
            for j in 0..<N {
                if k == j {
                    K[j * N + j] = 1
                    b[j] = val
                } else {
                    let kr = K[k * N + j]
                    b[j] -= kr * val
                    K[j * N + k] = 0
                    K[k * N + j] = 0
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Dirichlet setup took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    static func setRobin(model: FEM_Model, N: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for k in 0..<model.robinElements.count {
            let node1 = model.robinNodes[k]
            let node2 = model.robinNodes[k + 1]
            let nodes = [node1, node2]

            let dx = model.vertices[node2].x - model.vertices[node1].x
            let dy = model.vertices[node2].y - model.vertices[node1].y
            let length = sqrt(dx*dx + dy*dy)

            let qr = model.q[k]
            let gr = model.gamma[k]

            for i in 0..<2 {
                b[nodes[i]] += qr * length / 2
                for j in 0..<2 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let scale = (1 + dirac) * length / 6
                    K[nodes[j] * N + nodes[i]] += gr * scale
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Robin setup took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    // MARK: - LAPACK

    static func solveLAPACK(_ A_flat: inout [Float], _ b: [Float], N: Int) -> [Float]? {
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
            print("LAPACK sgesv_ error \(info)")
            return nil
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ LAPACK sgesv_ took: [%.0fms]", (t2 - t1)*1000)) : ()
        return b_copy
    }
}
