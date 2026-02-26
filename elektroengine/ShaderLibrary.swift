import MetalKit

enum VertexShaderType {
    case background, graph, vector, fem, surface
}

enum FragmentShaderType {
    case background, graph, vector, fem, surface
}

class ShaderLibrary {
    static var defaultLibrary: MTLLibrary!
    
    private static var vertexShaders: [VertexShaderType: Shader] = [:]
    private static var fragmentShaders: [FragmentShaderType: Shader] = [:]
    
    static func initialize() {
        defaultLibrary = Renderer.device.makeDefaultLibrary()
        createDefaultShaders()
    }
    
    static func createDefaultShaders() {
        vertexShaders.updateValue(VertexBackgroundShader(), forKey: .background)
        vertexShaders.updateValue(VertexGraphShader(), forKey: .graph)
        vertexShaders.updateValue(VertexVectorShader(), forKey: .vector)
        vertexShaders.updateValue(VertexFEMShader(), forKey: .fem)
        vertexShaders.updateValue(VertexSurfaceShader(), forKey: .surface)
        
        fragmentShaders.updateValue(FragmentBackgroundShader(), forKey: .background)
        fragmentShaders.updateValue(FragmentGraphShader(), forKey: .graph)
        fragmentShaders.updateValue(FragmentVectorShader(), forKey: .vector)
        fragmentShaders.updateValue(FragmentFEMShader(), forKey: .fem)
        fragmentShaders.updateValue(FragmentSurfaceShader(), forKey: .surface)
    }
    
    static func vertex(_ type: VertexShaderType) -> MTLFunction {
        return vertexShaders[type]!.function
    }
    
    static func fragment(_ type: FragmentShaderType) -> MTLFunction {
        return fragmentShaders[type]!.function
    }
}

protocol Shader {
    var name: String { get }
    var functionName: String { get }
    var function: MTLFunction { get }
}

struct VertexBackgroundShader: Shader {
    var name: String = "Background Vertex Shader"
    var functionName: String = "vertex_background"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct FragmentBackgroundShader: Shader {
    var name: String = "Background Fragment Shader"
    var functionName: String = "fragment_background"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct VertexGraphShader: Shader {
    var name: String = "Graph Vertex Shader"
    var functionName: String = "vertex_graph"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct FragmentGraphShader: Shader {
    var name: String = "Graph Fragment Shader"
    var functionName: String = "fragment_graph"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct VertexVectorShader: Shader {
    var name: String = "Vector Vertex Shader"
    var functionName: String = "vertex_vector"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct FragmentVectorShader: Shader {
    var name: String = "Vector Fragment Shader"
    var functionName: String = "fragment_vector"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct VertexFEMShader: Shader {
    var name: String = "FEM Vertex Shader"
    var functionName: String = "vertex_fem"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct FragmentFEMShader: Shader {
    var name: String = "FEM Fragment Shader"
    var functionName: String = "fragment_fem"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct VertexSurfaceShader: Shader {
    var name: String = "Surface Vertex Shader"
    var functionName: String = "vertex_surface"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

struct FragmentSurfaceShader: Shader {
    var name: String = "Surface Fragment Shader"
    var functionName: String = "fragment_surface"
    var function: MTLFunction {
        let function = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        function?.label = name
        return function!
    }
}

