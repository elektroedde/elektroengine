import GameController

struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
}
class InputController {
    static let shared = InputController()

    var canMouseDown = false
    var leftMouseDown = false
    var rightClick: CGPoint = .zero
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    var touchLocation: CGPoint?
    var touchDelta: CGSize? {
      didSet {
        touchDelta?.height *= -1
        if let delta = touchDelta {
          mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
        }
        leftMouseDown = touchDelta != nil
      }
    }

    init() {
        let center = NotificationCenter.default
        center.addObserver(forName: .GCMouseDidConnect, object: nil, queue: nil) { notification in
            let mouse = notification.object as? GCMouse

            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.leftMouseDown = self.canMouseDown && pressed
            }


            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                self.mouseDelta = Point(x: deltaX, y: deltaY)


            }

            mouse?.mouseInput?.scroll.valueChangedHandler = { _, scrollX, scrollY in
                self.mouseScroll = Point(x: scrollX, y: scrollY)
            }
        }
    }

}
