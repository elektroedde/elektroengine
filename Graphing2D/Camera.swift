import CoreGraphics

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}


struct FPCamera: Camera {
    var transform = Transform()

    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100

    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }

    var viewMatrix: float4x4 {
        (float4x4(rotation: rotation) * float4x4(translation: position)).inverse
    }

    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
        
    }

    mutating func update(deltaTime: Float) {
    }
}

struct GraphCamera: Camera {
    var transform = Transform()
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100

    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }

    var viewMatrix: float4x4 {
        (float4x4(rotation: rotation) * float4x4(translation: position)).inverse
    }

    let minDistance: Float = 0.1
    let maxDistance: Float = 30
    var target: SIMD3<Float> = [0, 0, 0]
    var distance: Float = 10


    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }



    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        var scrollSensitivity = Settings.touchZoomSensitivity * 5 * distance / maxDistance
        var panSensitivity = Settings.touchPanSensitivity * distance / maxDistance
        #if os(macOS)
        scrollSensitivity = Settings.mouseScrollSensitivity
        panSensitivity = Settings.mousePanSensitivity
        #endif


        distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        input.mouseScroll = .zero
        if input.leftMouseDown {

            position.x -= input.mouseDelta.x * panSensitivity
            position.y -= input.mouseDelta.y * panSensitivity
            input.mouseDelta = .zero
        }

        position = float3(position.x, position.y, -distance)
    }
}
