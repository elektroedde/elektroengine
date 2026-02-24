import MetalKit


struct Graph: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var vertices: [Vertex] = []




    let vertexBuffer: MTLBuffer

    let count: Int = 1000
    let amplitude: Float = 0.8
    let frequency: Float = 5
    let linewidth: Float = 0.01

    var sign: Float = -1

    var xval: Float
    var yval: Float

    let stepDistance: Float = 0.01
    init(device: MTLDevice) {
        pipelineState = PipelineStates.createGraphPSO()
        xval = -2*Float.pi
        yval = amplitude*sin(frequency*xval)

        vertices.append(Vertex(x: xval, y: yval + linewidth, z: 0))
        for _ in 0..<count {
            xval += stepDistance
            yval = amplitude*sin(frequency*xval)
            vertices.append(Vertex(x: xval, y: yval + linewidth*sign, z: 0))
            sign *= -1
        }
        //vertices.append(Vertex(x: -0.5+Float(count-1)*0.05, y: linewidth*sign, z: 0))
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

        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        //renderEncoder.setTriangleFillMode(.lines)

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
    }
}

