import Accelerate

class RealSolver {
    static var printDebug: Bool = false
    
    static func solve3D(model: FEM_Model, printDebug: Bool = false) -> [Float] {
        let N = model.N3D
        let M = model.M3D
        
        printDebug ? print("=== Starting 3D Real Solver ===") : ()
        
        var K = [Float](repeating: 0, count: N * N)
        var b = [Float](repeating: 0, count: N)
        
        assemble3D(model: model, N: N, M: M, K: &K, b: &b)
        
        setRobin3D(model: model, N: N, K: &K, b: &b)
        
        setDirichlet3D(model: model, N: N, K: &K, b: &b)
        
        return solveLAPACK(&K, b, N: N)!
    }
    
    static func assemble3D(model: FEM_Model, N: Int, M: Int, K: inout [Float], b: inout [Float]) {
        
        for element in 0..<M {
            let n0 = model.nodes[element * 4 + 0]
            let n1 = model.nodes[element * 4 + 1]
            let n2 = model.nodes[element * 4 + 2]
            let n3 = model.nodes[element * 4 + 3]
            let nodes = [n0, n1, n2, n3]
            
            let x = [model.nodeCoords[n0].x, model.nodeCoords[n1].x, model.nodeCoords[n2].x, model.nodeCoords[n3].x]
            let y = [model.nodeCoords[n0].y, model.nodeCoords[n1].y, model.nodeCoords[n2].y, model.nodeCoords[n3].y]
            let z = [model.nodeCoords[n0].z, model.nodeCoords[n1].z, model.nodeCoords[n2].z, model.nodeCoords[n3].z]
            
            let volume = float4x4([1,    1,    1,    1],
                                [x[0], x[1], x[2], x[3]],
                                [y[0], y[1], y[2], y[3]],
                                [z[0], z[1], z[2], z[3]]).determinant / 6
            let alphax: Float = 1.0
            let alphay: Float = 1.0
            let alphaz: Float = 1.0
            let f: Float = 0.0
            
            let b_e: [Float] = [
                 det3(SIMD3(y[1],y[2],y[3]), SIMD3(z[1],z[2],z[3]), SIMD3(1,1,1)),
                -det3(SIMD3(y[0],y[2],y[3]), SIMD3(z[0],z[2],z[3]), SIMD3(1,1,1)),
                 det3(SIMD3(y[0],y[1],y[3]), SIMD3(z[0],z[1],z[3]), SIMD3(1,1,1)),
                -det3(SIMD3(y[0],y[1],y[2]), SIMD3(z[0],z[1],z[2]), SIMD3(1,1,1)),
            ]
            
            let c_e: [Float] = [
                 det3(SIMD3(x[1],x[2],x[3]), SIMD3(z[1],z[2],z[3]), SIMD3(1,1,1)),
                -det3(SIMD3(x[0],x[2],x[3]), SIMD3(z[0],z[2],z[3]), SIMD3(1,1,1)),
                 det3(SIMD3(x[0],x[1],x[3]), SIMD3(z[0],z[1],z[3]), SIMD3(1,1,1)),
                -det3(SIMD3(x[0],x[1],x[2]), SIMD3(z[0],z[1],z[2]), SIMD3(1,1,1)),
            ]
            
            let d_e: [Float] = [
                 det3(SIMD3(x[1],x[2],x[3]), SIMD3(y[1],y[2],y[3]), SIMD3(1,1,1)),
                -det3(SIMD3(x[0],x[2],x[3]), SIMD3(y[0],y[2],y[3]), SIMD3(1,1,1)),
                 det3(SIMD3(x[0],x[1],x[3]), SIMD3(y[0],y[1],y[3]), SIMD3(1,1,1)),
                -det3(SIMD3(x[0],x[1],x[2]), SIMD3(y[0],y[1],y[2]), SIMD3(1,1,1)),
            ]
            
            for i in 0..<4 {
                //b[nodes[i]] += f * area / 3
                b[nodes[i]] += f * volume / 4
                for j in 0..<4 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let K_eij = (alphax * b_e[i] * b_e[j] + alphay * c_e[i] * c_e[j] + alphaz * d_e[i] * d_e[j])/(36*volume)// 1/36volume * (alphax bi bj + alphay ci cj + alphaz di dj) + volume*beta/20 * (1+ delta_ij)
                    K[nodes[j] * N + nodes[i]] += K_eij
                }
            }
            
        }
    }

    static func det3(_ c0: SIMD3<Float>, _ c1: SIMD3<Float>, _ c2: SIMD3<Float>) -> Float {
        return float3x3(c0, c1, c2).determinant
    }
    
    static func setRobin3D(model: FEM_Model, N: Int, K: inout [Float], b: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for k in 0..<model.robinElements.count {
            let node1 = model.robinNodes[3 * k]
            let node2 = model.robinNodes[3 * k + 1]
            let node3 = model.robinNodes[3 * k + 2]
            let nodes = [node1, node2, node3]

            let p0 = model.nodeCoords[node1]
            let p1 = model.nodeCoords[node2]
            let p2 = model.nodeCoords[node3]

            // Triangle area in 3D via cross product
            let e1 = p1 - p0
            let e2 = p2 - p0
            let crossProduct = SIMD3<Float>(e1.y * e2.z - e1.z * e2.y,
                                            e1.z * e2.x - e1.x * e2.z,
                                            e1.x * e2.y - e1.y * e2.x)
            let area = length(crossProduct) / 2

            let qr = model.q[k]
            let gr = model.gamma[k]

            for i in 0..<3 {
                b[nodes[i]] += qr * area / 3
                for j in 0..<3 {
                    let dirac: Float = (i == j) ? 1 : 0
                    let scale = (1 + dirac) * area / 12
                    K[nodes[j] * N + nodes[i]] += gr * scale
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Robin setup took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    static func setDirichlet3D(model: FEM_Model, N: Int, K: inout [Float], b: inout [Float]) {
        setDirichlet(model: model, N: N, K: &K, b: &b)
    }
    static func solve(model: FEM_Model, printDebug: Bool = false) -> [Float] {
        self.printDebug = printDebug
        let N = model.N
        let M = model.M

        printDebug ? print("=== Starting Real Solver ===") : ()

        var K = [Float](repeating: 0, count: N * N)
        var b = [Float](repeating: 0, count: N)

        assemble(model: model, N: N, M: M, K: &K, b: &b)

        if model.robinElements.count > 0 {
            setRobin(model: model, N: N, K: &K, b: &b)
        }
        setDirichlet(model: model, N: N, K: &K, b: &b)

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

            
            let area = float3x3([1, x[0], y[0]],
                                [1, x[1], y[1]],
                                [1, x[2], y[2]]).determinant / 2
            
    
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
