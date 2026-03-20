import MetalKit



struct GravitySurface: Transformable {
    var pipelineState: MTLRenderPipelineState!

    var transform = Transform()
    var vertices: [Vertex] = []

    
    var indices: [UInt16] = []

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    var minX: Float = 0
    var maxX: Float = 0
    var minY: Float = 0
    var maxY: Float = 0
    var minZ: Float = 0
    var maxZ: Float = 0

    var highlighted: Bool = false

    var timer: Float = 0
    
    let gridWidth: Int = 250
    let gridHeight: Int = 250
    let surfaceWidth: Float = 100.0
    let surfaceHeight: Float = 100.0

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createGravityPSO()
        
        let halfW = surfaceWidth / 2
        let halfH = surfaceHeight / 2
        
        // Generate grid vertices
        for row in 0...gridHeight {
            for col in 0...gridWidth {
                let x = -halfW + surfaceWidth * Float(col) / Float(gridWidth)
                let z = -halfH + surfaceHeight * Float(row) / Float(gridHeight)
                vertices.append(Vertex(x: x, y: 0, z: z))
            }
        }
        
        // Generate triangle indices
        let cols = UInt16(gridWidth + 1)
        for row in 0..<UInt16(gridHeight) {
            for col in 0..<UInt16(gridWidth) {
                let topLeft = row * cols + col
                let topRight = topLeft + 1
                let bottomLeft = topLeft + cols
                let bottomRight = bottomLeft + 1
                
                indices.append(contentsOf: [topLeft, topRight, bottomLeft])
                indices.append(contentsOf: [topRight, bottomRight, bottomLeft])
            }
        }
        
        minX = -halfW
        maxX =  halfW
        minY =  0
        maxY =  0
        minZ = -halfH
        maxZ =  halfH

       

        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        
        

        guard let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * indices.count, options:[]) else {
            fatalError("Could not create index buffer")
        }
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer


    }


    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms, options: Options, timer: Float) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        var timeee = timer
        
        // Set the min/max Y values for height-based coloring
        params.minY = -1
        params.maxY = 1
        
        params.surfaceMinX = minX
        params.surfaceMaxX = maxX
        params.surfaceMinY = minY
        params.surfaceMaxY = maxY
        params.surfaceMinZ = minZ
        params.surfaceMaxZ = maxZ
        
        
        
        params.colormapChoice = options.colormap.rawValue
        let fillMode: MTLTriangleFillMode = options.drawWireframe ? .lines : .fill
        
        renderEncoder.setTriangleFillMode(fillMode)
    
        uniforms.modelMatrix = transform.modelMatrix

        

        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBytes(&timeee, length: MemoryLayout<Float>.stride, index: 20)


        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setVertexBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)


    }
}


