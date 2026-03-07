import MetalKit



struct Cube: Transformable {

    //var hitbox: BoundingSphere = BoundingSphere(center: [0,0,0], radius: 1)

    var sideLength: Float = 2
    var pipelineState: MTLRenderPipelineState!

    var transform = Transform()
    var vertices: [Vertex] = [Vertex(x: 0, y: 0, z: 0), Vertex(x: 1, y: 0, z: 0), Vertex(x: 1, y: 1, z: 0)]

    private var indices: [UInt16] = [0, 1, 2]


    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer


    var highlighted: Bool = false


    var dirichlet1: [UInt16] = []
    var dirichlet0: [UInt16] = []



    let nodes: UInt16 = 30
    init(device: MTLDevice) {
        pipelineState = PipelineStates.createGraphPSO()






        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }


        guard let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * indices.count, options:[]) else {
            fatalError("Could not create index buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
    }


    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        //let fillMode: MTLTriangleFillMode = highlighted ? .lines : .fill
        renderEncoder.setTriangleFillMode(.lines)

        uniforms.modelMatrix = transform.modelMatrix

        //params.colormap = highlighted ? 1 : 0

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}



