import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        return vertexDescriptor
    }

    static var femLayout: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = VertexBuffer.index
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        vertexDescriptor.attributes[13].format = .float
        vertexDescriptor.attributes[13].offset = 0
        vertexDescriptor.attributes[13].bufferIndex = FEMBuffer.index
        vertexDescriptor.layouts[13].stride = MemoryLayout<Float>.stride

        return vertexDescriptor
    }
}

extension BufferIndices {
    var index: Int {
        return Int(self.rawValue)
    }
}
