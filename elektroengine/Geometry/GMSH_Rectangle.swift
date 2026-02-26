import MetalKit

import Accelerate

struct GMSH_Rectangle: Transformable {

    //var hitbox: BoundingSphere = BoundingSphere(center: [0,0,0], radius: 1)


    var pipelineState: MTLRenderPipelineState!

    var transform = Transform()
    var vertices: [Vertex] = []

    var flatIndices: [UInt16] = []

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let femBuffer: MTLBuffer


    var highlighted: Bool = false


    var dirichlet1: [UInt16] = []
    var dirichlet0: [UInt16] = []

    var femValues: [Float] = []


    init(device: MTLDevice) {
        pipelineState = PipelineStates.createFEMPSO()
        let test = getMeshPoints()

        for v in test.nTags {
            flatIndices.append(UInt16(v-1))
        }



        for val in test.n_cord {
            vertices.append(Vertex(x: Float(val[0]), y: Float(val[1]), z: Float(val[2])))
        }

        for node in test.physicalGroup1_nodes {
            dirichlet1.append(UInt16(node-1))
        }

        for node in test.physicalGroup2_nodes {
            dirichlet0.append(UInt16(node-1))
        }

        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }


        guard let indexBuffer = device.makeBuffer(bytes: flatIndices, length: MemoryLayout<UInt16>.stride * flatIndices.count, options:[]) else {
            fatalError("Could not create index buffer")
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        femValues = GMSH_Rectangle.solve(vertices: vertices, flatIndices: flatIndices, dirichlet1: dirichlet1, dirichlet0: dirichlet0)
        let endTime = CFAbsoluteTimeGetCurrent()
        print("The solver took \(String(format: "%.0f", (endTime - startTime)*1000))ms")
        guard let femBuffer = device.makeBuffer(bytes: &femValues, length: MemoryLayout<Float>.stride * femValues.count, options:[]) else {
            fatalError("Could not create index buffer")
        }






        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.femBuffer = femBuffer




    }


    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        //let fillMode: MTLTriangleFillMode = highlighted ? .lines : .fill
        renderEncoder.setTriangleFillMode(.fill)

        uniforms.modelMatrix = transform.modelMatrix

        //params.colormap = highlighted ? 1 : 0

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBuffer(femBuffer, offset: 0, index: FEMBuffer.index)


        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: flatIndices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}


extension GMSH_Rectangle {
    static func solve(vertices: [Vertex],
                      flatIndices: [UInt16],
                      dirichlet1: [UInt16],
                      dirichlet0: [UInt16]) -> [Float] {
        let N = vertices.count
        let M = flatIndices.count / 3  // Number of triangles

        var K: [[Float]] = Array(repeating: Array(repeating: 0, count: N), count: N)

        var b: [Float] = Array(repeating: 0, count: N)

        for element in 0..<M {


            var K_e: [[Float]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)
            var b_e: [Float] = Array(repeating: 0, count: 3)
            let i: Int = Int(flatIndices[element * 3 + 0])
            let j: Int = Int(flatIndices[element * 3 + 1])
            let k: Int = Int(flatIndices[element * 3 + 2])
            let nodes = [i, j, k]
            let xi: Float = vertices[i].x
            let xj: Float = vertices[j].x
            let xk: Float = vertices[k].x

            let yi: Float = vertices[i].y
            let yj: Float = vertices[j].y
            let yk: Float = vertices[k].y


            let area = 0.5 * (xi*(yj - yk) + xj*(yk - yi) + xk*(yi - yj) )

            let beta = [yj-yk, yk-yi, yi-yj]
            let alpha = [xk-xj, xi-xk, xj-xi]



            for m in 0..<3 {
                for n in 0..<3 {
                    var dirac = 0
                    if(m == n) {
                        dirac = 1
                    }

                    K_e[m][n] = (beta[m]*beta[n] + alpha[m]*alpha[n])/(4*area)
                    K[nodes[m]][nodes[n]] += K_e[m][n]
                }
            }
        }

        for ii in dirichlet1 {
            let i = Int(ii)
            for j in 0..<N {
                if(j == i) {
                    K[j][j] = 1
                    b[j] = 1
                }
                else {
                    b[j] -= K[j][i] * 1
                    K[i][j] = 0
                    K[j][i] = 0

                }
            }
        }

        for ii in dirichlet0 {
            let i = Int(ii)
            for j in 0..<N {
                if(j == i) {
                    K[j][j] = 1
                    b[j] = 0
                }
                else {
                    b[j] -= K[j][i] * 0
                    K[i][j] = 0
                    K[j][i] = 0

                }
            }
        }


        let phi = solveLAPACK(K, b)
        return phi!
    }

    static func linearSolver(_ A_in: [[Float]], _ b_in: [Float]) -> [Float] {
        // Utilizes PA = LU factorization

        let n = A_in.count
        var L = Array(repeating: Array(repeating: Float(0), count: n), count: n)
        var U = A_in
        var b = b_in



        for i in 0..<n-1 {
            var maxRow = i
            for j in i+1..<n {
                if abs(U[j][i]) > abs(U[maxRow][i]) {
                    maxRow = j
                }
            }

            if i != maxRow {
                U.swapAt(i, maxRow)
                L.swapAt(i, maxRow)
                b.swapAt(i, maxRow)
            }

            for k in i+1..<n {
                let factor = U[k][i] / U[i][i]
                L[k][i] = factor

                for o in i..<n {
                    U[k][o] -= factor * U[i][o]
                }
            }
        }

        for i in 0..<n {
            L[i][i] = 1
        }

        // Solve Lc = Pb for c
        var c: [Float] = Array(repeating: 0, count: n)

        for i in 0..<n {
            for j in 0..<i {
                b[i] -= L[i][j] * c[j]
            }
            c[i] = b[i]/L[i][i]
        }


        // Solve Ux = c for x
        var x: [Float] = Array(repeating: 0, count: n)

        for i in (0..<n).reversed() {
            for j in i..<n {
                c[i] -= U[i][j] * x[j]
            }
            x[i] = c[i]/U[i][i]
        }
        return x
    }

    static func solveLAPACK(_ A: [[Float]], _ b: [Float]) -> [Float]? {
        let n = b.count

        // Convert to column-major format for LAPACK
        var A_flat = [Float](repeating: 0, count: n*n)
        for i in 0..<n {
            for j in 0..<n {
                A_flat[j * n + i] = A[i][j] // column-major order
            }
        }

        var b_copy = b
        var n_int32 = Int32(n)
        var lda = Int32(n)  // Leading dimension of A
        var ldb = Int32(n)  // Leading dimension of b
        var nrhs = Int32(1)  // Number of right-hand sides
        var ipiv = [Int32](repeating: 0, count: n)
        var info: Int32 = 0

        // sgesv solves Ax = b using LU decomposition with partial pivoting
        sgesv_(&n_int32, &nrhs, &A_flat, &lda, &ipiv, &b_copy, &ldb, &info)

        if info == 0 {
            return b_copy
        } else {
            print("LAPACK sgesv failed with info = \(info)")
            return nil
        }
    }
}
