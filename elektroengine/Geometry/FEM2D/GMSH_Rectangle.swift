import MetalKit

struct GMSH_Rectangle: Transformable {
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
        let mesh = getRectangle(6, 6)
        

        for v in mesh.nodes {
            femObject.nodes.append(Int(v-1))
            femObject.f.append(0)

        }
        for i in stride(from: 0, to: mesh.nodeCoords.count, by: 3) {
            femObject.vertices.append(Vertex(x: Float(mesh.nodeCoords[i]), y: Float(mesh.nodeCoords[i+1]), z: Float(mesh.nodeCoords[i+2])))
        }

        for node in mesh.topBoundaryNodes {
            femObject.dirichletNodes.append(Int(node-1))
            femObject.dirichletValues.append(1)
        }
        for node in mesh.bottomBoundaryNodes {
            femObject.dirichletNodes.append(Int(node-1))
            femObject.dirichletValues.append(0)
        }

        for v in mesh.rightBoundaryElementTags {
            femObject.robinElements.append(Int(v-1))
            femObject.q.append(1)
            femObject.gamma.append(1)
        
        }
        for node in mesh.rightBoundaryElementNodes {
            femObject.robinNodes.append(Int(node-1))
            print(node)
        }
        
        print("now")
        for node in mesh.rightBoundaryNodes {
            print(node)
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
        var uniforms = vertex
        params.minFem = femValues.min() ?? 0
        params.maxFem = femValues.max() ?? 1
        params.colormapChoice = options.colormap.rawValue
        let fillMode: MTLTriangleFillMode = options.drawWireframe ? .lines : .fill
        params.showContours = options.showContours
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

