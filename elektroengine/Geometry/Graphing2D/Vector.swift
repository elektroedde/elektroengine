import MetalKit


struct Vector: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var vertices: [Vertex] = []



    let w: Float = 0.05
    let head: Float = 0.2
    let defaultLength: Float = 0.5
    let vertexBuffer: MTLBuffer


    init(device: MTLDevice, l: Float = 1) {
        vertices = [Vertex(x: 0, y:  w, z: 0), // Body
                    Vertex(x: 0, y: -w, z: 0), // Body
                    Vertex(x: l-head, y: -w, z: 0), // Body

                    Vertex(x: l-head, y: -w, z: 0.0), // Body
                    Vertex(x: l-head, y:  w, z: 0.0), // Body
                    Vertex(x: 0, y:  w, z: 0.0), // Body

                    Vertex(x: l-head, y:  2*w, z: 0.0), // Head
                    Vertex(x: l-head, y: -2*w, z: 0.0), // Head
                    Vertex(x: l, y: 0, z: 0.0)] // Head
        pipelineState = PipelineStates.createVectorPSO()

        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }



        self.vertexBuffer = vertexBuffer

    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        uniforms.modelMatrix = transform.modelMatrix
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setTriangleFillMode(.lines)

        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        //renderEncoder.setTriangleFillMode(.lines)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}

