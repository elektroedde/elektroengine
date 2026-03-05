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

        }
        for val in mesh.allNodeCoords {
            femObject.vertices.append(Vertex(x: Float(val[0]), y: Float(val[1]), z: Float(val[2])))

        }

        for v in mesh.allElementTags {
            femObject.allElements.append(Int(v-1))
        }

        for element in mesh.cylinderElementTags {
            femObject.chargeElements.append(Int(element-1))
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
        femValues = Solver.solve(femObject: femObject)
        let endTime = CFAbsoluteTimeGetCurrent()
        print("The solver took \(String(format: "%.0f", (endTime - startTime)*1000))ms")

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
        renderEncoder.setTriangleFillMode(.fill)
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

