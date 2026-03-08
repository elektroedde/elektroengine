import MetalKit
import Observation

class ApplicationController: NSObject {
    var renderer: Renderer
    private var currentScene: SceneX
    var options: Options
    private var lastApplicationChoice: ApplicationWindow
    
    var deltaTime: Double = 0
    private var lastTime: Double = CFAbsoluteTimeGetCurrent()

    init(metalView: MTKView, options: Options) {
        self.options = options
        self.lastApplicationChoice = options.applicationChoice
        renderer = Renderer(metalView: metalView, options: options)
        currentScene = ApplicationController.createScene(for: options.applicationChoice)

        super.init()
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
    
    func checkForSceneChange() {
        if options.applicationChoice != lastApplicationChoice {
            print("🔄 Switching scene from \(lastApplicationChoice) to \(options.applicationChoice)")
            lastApplicationChoice = options.applicationChoice
            switchScene(to: options.applicationChoice)
        }
    }

    private static func createScene(for app: ApplicationWindow) -> SceneX {
        switch app {
        case .FEM2D: return FEM2DScene()
        case .FEM3D: return FEM3DScene()
        case .Graphing2D: return Graphing2DScene()
        case .Graphing3D: return Graphing3DScene()
        }
    }
    private func switchScene(to app: ApplicationWindow) {
        currentScene = Self.createScene(for: app)
        if let metalView = renderer.metalView {
            currentScene.update(size: metalView.drawableSize)
        }
    }
}

extension ApplicationController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        currentScene.update(size: size)
        renderer.mtkView(view, drawableSizeWillChange: size)
    }

    func draw(in view: MTKView) {
        checkForSceneChange()
        let deltaTime = calculateDeltaTime()
        currentScene.update(deltaTime: deltaTime)
        renderer.draw(scene: currentScene, in: view)
    }

    private func calculateDeltaTime() -> Float {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        return deltaTime
    }
}
