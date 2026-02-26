import MetalKit



struct Surface3D: Transformable {

    //var hitbox: BoundingSphere = BoundingSphere(center: [0,0,0], radius: 1)

    var sideLength: Float = 2
    var pipelineState: MTLRenderPipelineState!

    var transform = Transform()
    var vertices: [Vertex] = []

    private var indices: [[UInt16]] = []
    var flatIndices: [UInt16] = []

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    var minY: Float = 0
    var maxY: Float = 0

    var highlighted: Bool = false



    let nodes: UInt16 = 200
    init(device: MTLDevice) {
        pipelineState = PipelineStates.createSurfacePSO()
        for i in 0..<nodes {
            for j in 0..<nodes {
                // Start with a half period (frequency = 0.5)
                let x: Float = Float(j) / Float(nodes - 1)
                let amplitude: Float = exp(-Float(i) / Float(nodes))
                let yy = amplitude * sin(0.5 * Float.pi * x)
                vertices.append(Vertex(x: -1 + Float(2*j)/Float(nodes), y: yy, z: -1 + Float(2*i)/Float(nodes)))
            }
        }
        
        // Calculate min and max Y values
        let yValues = vertices.map { $0.y }
        minY = yValues.min() ?? 0
        maxY = yValues.max() ?? 0

        for row in 0..<nodes-1 {
            for col in 0..<nodes-1 {
                indices.append([col+row*nodes, col+1+row*nodes, nodes+col+row*nodes])
                indices.append([col+1+row*nodes, nodes+1+col+row*nodes, nodes+col+row*nodes])
            }
        }

        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        flatIndices = indices.flatMap { $0 }

        guard let indexBuffer = device.makeBuffer(bytes: flatIndices, length: MemoryLayout<UInt16>.stride * flatIndices.count, options:[]) else {
            fatalError("Could not create index buffer")
        }
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer


    }


    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        
        // Set the min/max Y values for height-based coloring
        params.minY = minY
        params.maxY = maxY
        
        //let fillMode: MTLTriangleFillMode = highlighted ? .lines : .fill

        renderEncoder.setTriangleFillMode(.fill)

        uniforms.modelMatrix = transform.modelMatrix

        //params.colormap = highlighted ? 1 : 0

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)


        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: flatIndices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)


    }
}


