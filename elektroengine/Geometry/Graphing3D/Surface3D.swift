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
    
    var minX: Float = 0
    var maxX: Float = 0
    var minY: Float = 0
    var maxY: Float = 0
    var minZ: Float = 0
    var maxZ: Float = 0

    var highlighted: Bool = false

    var timer: Float = 0
    
    let nodes: UInt16 = 200
    
    var nnodes: [Int] = []
    init(device: MTLDevice) {
        pipelineState = PipelineStates.createSurfacePSO()
        let mesh = createRectangle(5, 3)
        
        // All vertices (GMSH node tags are 1-based)
        for val in mesh.nodes {
            nnodes.append(Int(val)-1)
        }
        for i in stride(from: 0, to: mesh.nodeCoords.count, by: 3) {
            vertices.append(Vertex(x: Float(mesh.nodeCoords[i]), y: Float(mesh.nodeCoords[i+2]), z: Float(mesh.nodeCoords[i+1])))
        }
        minX = vertices.min(by: { $0.x < $1.x })?.x ?? 0
        maxX = vertices.max(by: { $0.x < $1.x })?.x ?? 0
        minY = vertices.min(by: { $0.y < $1.y })?.y ?? 0
        maxY = vertices.max(by: { $0.y < $1.y })?.y ?? 0
        minZ = vertices.min(by: { $0.z < $1.z })?.z ?? 0
        maxZ = vertices.max(by: { $0.z < $1.z })?.z ?? 0

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
        let indexData = nnodes.map { UInt16($0) }

        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.stride * indexData.count, options:[]) else {
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
        
        switch(options.graphing3D.tmMode) {
        case .TM11:
            params.xmode = 1
            params.zmode = 1
        case .TM12:
            params.xmode = 1
            params.zmode = 2
        case .TM21:
            params.xmode = 2
            params.zmode = 1
        case .TM22:
            params.xmode = 2
            params.zmode = 2
        case .TM1010:
            params.xmode = 10
            params.zmode = 10
        }
        
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
                                            indexCount: nnodes.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)


    }
}


