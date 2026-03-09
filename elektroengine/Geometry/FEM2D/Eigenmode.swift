import MetalKit

struct Eigenmode: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var highlighted: Bool = false
    var femObject: FEM_Model = FEM_Model()
    var femValues: [Float] = []
    var eigenmode1: [Float] = []
    var eigenmode2: [Float] = []
    var eigenmode3: [Float] = []
    var eigenmode4: [Float] = []
    var eigenmode5: [Float] = []
    var eigenmode6: [Float] = []
    var eigenmode7: [Float] = []



    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let femBuffer: MTLBuffer

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createFEMPSO()
        let mesh = getEigenmode()
        
        
        for v in mesh.nodes {
            print(v)
            femObject.nodes.append(Int(v-1))

        }
        for i in stride(from: 0, to: mesh.nodeCoords.count, by: 3) {
            femObject.vertices.append(Vertex(x: Float(mesh.nodeCoords[i]), y: Float(mesh.nodeCoords[i+1]), z: Float(mesh.nodeCoords[i+2])))
        }

        //for node in mesh.boundaryNodes {
        //    femObject.dirichletNodes.append(Int(node-1))
        //    femObject.dirichletValues.append(0)
        //}

        guard let vertexBuffer = device.makeBuffer(bytes: femObject.vertices, length: MemoryLayout<Vertex>.stride * femObject.vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }

        let indexData = femObject.nodes.map { UInt16($0) }
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.stride * indexData.count, options: []) else {
            fatalError("Could not create index buffer")
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        guard let result = Solver.solveEigen(model: femObject, numModes: 7, printDebug: true) else {
            fatalError("Eigenvalue solver failed")
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Eigenvalues (first 10): \(result.eigenvalues.prefix(20))")
        print("Total time for the solver: \(String(format: "%.0f", (endTime - startTime)*1000))ms\n")

        femValues = result.eigenvectors[0]
        eigenmode1 = result.eigenvectors[0]
        eigenmode2 = result.eigenvectors[1]
        eigenmode3 = result.eigenvectors[2]
        eigenmode4 = result.eigenvectors[3]
        eigenmode5 = result.eigenvectors[4]
        eigenmode6 = result.eigenvectors[5]
        eigenmode7 = result.eigenvectors[6]

        


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
        var uniforms = vertex
        params.minFem = femValues.min() ?? 0
        params.maxFem = femValues.max() ?? 1
        params.colormapChoice = options.colormap.rawValue
        let fillMode: MTLTriangleFillMode = options.drawWireframe ? .lines : .fill
        
        renderEncoder.setTriangleFillMode(fillMode)
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

