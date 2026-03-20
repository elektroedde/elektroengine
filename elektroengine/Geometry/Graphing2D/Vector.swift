import MetalKit

struct VectorInstance_Swift {
    var position: SIMD2<Float>
    var rotation: Float
}

struct VectorField {
    var pipelineState: MTLRenderPipelineState!
    let vertexBuffer: MTLBuffer
    let instanceBuffer: MTLBuffer
    let vertexCount: Int
    let instanceCount: Int

    var instancePointer: UnsafeMutablePointer<VectorInstance_Swift>

    init(device: MTLDevice, count: Int, l: Float = 0.5) {
        let w: Float = 0.05
        let head: Float = 0.2

        var vertices: [Vertex] = [
            Vertex(x: 0, y:  w, z: 0),
            Vertex(x: 0, y: -w, z: 0),
            Vertex(x: l-head, y: -w, z: 0),

            Vertex(x: l-head, y: -w, z: 0),
            Vertex(x: l-head, y:  w, z: 0),
            Vertex(x: 0, y:  w, z: 0),

            Vertex(x: l-head, y:  2*w, z: 0),
            Vertex(x: l-head, y: -2*w, z: 0),
            Vertex(x: l, y: 0, z: 0)
        ]
        vertexCount = vertices.count
        instanceCount = count

        pipelineState = PipelineStates.createVectorPSO()

        guard let vb = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertexCount, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        self.vertexBuffer = vb

        guard let ib = device.makeBuffer(length: MemoryLayout<VectorInstance_Swift>.stride * instanceCount, options: .storageModeShared) else {
            fatalError("Could not create instance buffer")
        }
        self.instanceBuffer = ib
        self.instancePointer = ib.contents().bindMemory(to: VectorInstance_Swift.self, capacity: instanceCount)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        uniforms.modelMatrix = matrix_identity_float4x4

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: InstanceBuffer.index)
        renderEncoder.setTriangleFillMode(.lines)

        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: instanceCount)
    }
}

