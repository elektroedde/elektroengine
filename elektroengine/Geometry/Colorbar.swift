import MetalKit

struct Colorbar: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var outlinePipelineState: MTLRenderPipelineState!
    var transform = Transform()

    let border: Float = 0.01

    var vertices: [Vertex] = [
        Vertex(x: 0.85, y: -0.9, z: 0),
        Vertex(x: 0.85, y:  0.9, z: 0),
        Vertex(x: 0.9, y:  0.9, z: 0),
        Vertex(x: 0.9, y: -0.9, z: 0)
    ]

    var indices: [UInt16] = [0, 3, 1, 3, 2, 1]

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer

    var outlineVertices: [Vertex]
    let outlineVertexBuffer: MTLBuffer
    let outlineIndexBuffer: MTLBuffer

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createColorbarPSO()
        outlinePipelineState = PipelineStates.createColorbarOutlinePSO()

        outlineVertices = [
            Vertex(x: 0.85 - border, y: -0.9 - border, z: 0.001),
            Vertex(x: 0.85 - border, y:  0.9 + border, z: 0.001),
            Vertex(x: 0.9 + border,  y:  0.9 + border, z: 0.001),
            Vertex(x: 0.9 + border,  y: -0.9 - border, z: 0.001)
        ]

        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }

        guard let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count, options: []) else {
            fatalError("Could not create index buffer")
        }

        guard let outlineVertexBuffer = device.makeBuffer(bytes: &outlineVertices, length: MemoryLayout<Vertex>.stride * outlineVertices.count, options: []) else {
            fatalError("Could not create outline vertex buffer")
        }

        guard let outlineIndexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count, options: []) else {
            fatalError("Could not create outline index buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.outlineVertexBuffer = outlineVertexBuffer
        self.outlineIndexBuffer = outlineIndexBuffer
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms, options: Options) {
        var params = fragment
        var uniforms = vertex
        uniforms.modelMatrix = transform.modelMatrix
        params.colormapChoice = options.colormap.rawValue

        // Outline for the colorbar
        renderEncoder.setRenderPipelineState(outlinePipelineState)
        renderEncoder.setVertexBuffer(outlineVertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: outlineIndexBuffer, indexBufferOffset: 0)

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
}
