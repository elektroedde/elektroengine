import MetalKit

struct Background: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var vertices: [Vertex] = [
        Vertex(x: -50, y:  50, z: 0),
        Vertex(x:  50, y:  50, z: 0),
        Vertex(x: -50, y: -50, z: 0),
        Vertex(x:  50, y: -50, z: 0)
    ]

    var indices: [UInt16] = [0, 3, 2, 0, 1, 3]


    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createBackgroundPSO()
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }

        guard let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count, options: []) else {
            fatalError("Could not create index buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        uniforms.modelMatrix = transform.modelMatrix
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(indexBuffer, offset: 0, index: 1)

        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
}
