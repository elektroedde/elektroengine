import MetalKit

struct ChargedCylinder: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var highlighted: Bool = false
    var femObject: FEM_Model = FEM_Model()
    var femValues: [Float] = []

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let femBuffer: MTLBuffer

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createFEMPSO()
        let mesh = createChargeCylinder()

        // All vertices (GMSH node tags are 1-based)
        for val in mesh.allNodeTags {
            femObject.nodes.append(Int(val)-1)
            femObject.f.append(0)

        }
        for val in mesh.allNodeCoords {
            femObject.vertices.append(Vertex(x: Float(val[0]), y: Float(val[1]), z: Float(val[2])))

        }

        for v in mesh.allElementTags {
            femObject.allElements.append(Int(v-1))
            femObject.material.append(1)
        }

        let eps0: Float = 8.854187817e-12
        for (i, _) in mesh.cylinderElementTags.enumerated() {
            femObject.f[i] = 3/eps0

        }


        for v in mesh.boundaryNodes {
            femObject.dirichletNodes.append(Int(v-1))
            femObject.dirichletValues.append(0)
        }


        guard let vertexBuffer = device.makeBuffer(bytes: femObject.vertices, length: MemoryLayout<Vertex>.stride * femObject.vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }

        let indexData = femObject.nodes.map { UInt16($0) }
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.stride * indexData.count, options: []) else {
            fatalError("Could not create index buffer")
        }


        let startTime = CFAbsoluteTimeGetCurrent()
        femValues = Solver.solve(model: femObject, printDebug: true)
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Total time for the solver: \(String(format: "%.0f", (endTime - startTime)*1000))ms\n")

        // Gradient stuff
        // 1. Build node-to-element adjacency
        let nodeCount = femObject.N
        let elementCount = femObject.M
        var nodeToElements: [[Int]] = Array(repeating: [], count: nodeCount)
        for elem in 0..<elementCount {
            let n0 = femObject.nodes[3 * elem]
            let n1 = femObject.nodes[3 * elem + 1]
            let n2 = femObject.nodes[3 * elem + 2]
            nodeToElements[n0].append(elem)
            nodeToElements[n1].append(elem)
            nodeToElements[n2].append(elem)
        }
        
        // 2. Compute per-element gradient
        var elemGradX = [Float](repeating: 0, count: elementCount)
        var elemGradY = [Float](repeating: 0, count: elementCount)
        for elem in 0..<elementCount {
            let n0 = femObject.nodes[3 * elem]
            let n1 = femObject.nodes[3 * elem + 1]
            let n2 = femObject.nodes[3 * elem + 2]
            let x1 = femObject.vertices[n0].x, y1 = femObject.vertices[n0].y
            let x2 = femObject.vertices[n1].x, y2 = femObject.vertices[n1].y
            let x3 = femObject.vertices[n2].x, y3 = femObject.vertices[n2].y
            let u1 = femValues[n0], u2 = femValues[n1], u3 = femValues[n2]
            let twoA = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)
            elemGradX[elem] = (u1 * (y2 - y3) + u2 * (y3 - y1) + u3 * (y1 - y2)) / twoA
            elemGradY[elem] = (u1 * (x3 - x2) + u2 * (x1 - x3) + u3 * (x2 - x1)) / twoA
        }
        
        // 3. Average gradients to nodes and compute magnitude
        var gradientMagnitude = [Float](repeating: 0, count: nodeCount)
        for node in 0..<nodeCount {
            let adjElems = nodeToElements[node]
            var gx: Float = 0
            var gy: Float = 0
            for elem in adjElems {
                gx += elemGradX[elem]
                gy += elemGradY[elem]
            }
            if !adjElems.isEmpty {
                gx /= Float(adjElems.count)
                gy /= Float(adjElems.count)
            }
            gradientMagnitude[node] = sqrt(gx * gx + gy * gy)
        }
        
        // Use gradient magnitude as the displayed FEM values
        femValues = gradientMagnitude

        guard let femBuffer = device.makeBuffer(bytes: &femValues, length: MemoryLayout<Float>.stride * femValues.count, options: []) else {
            fatalError("Could not create FEM buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.femBuffer = femBuffer
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms, options: Options) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        params.minFem = femValues.min() ?? 0
        params.maxFem = femValues.max() ?? 1
        params.colormapChoice = options.colormap.rawValue
        var uniforms = vertex
        
        let fillMode: MTLTriangleFillMode = options.drawWireframe ? .lines : .fill
        renderEncoder.setTriangleFillMode(fillMode)
        
        uniforms.modelMatrix = transform.modelMatrix

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBuffer(femBuffer, offset: 0, index: FEMBuffer.index)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: femObject.nodes.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}

