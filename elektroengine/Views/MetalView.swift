import SwiftUI
import MetalKit

struct MetalView: View {
    let options: Options
    @State private var metalView = MyMTKView()
    @State private var applicationController: ApplicationController?
    @State private var previousTranslation = CGSize.zero
    @State private var previousScroll: CGFloat = 1

    var body: some View {
        MetalViewRepresentable(applicationController: applicationController, metalView: $metalView, options: options)
            .onAppear {
                // We initialize the renderer only when metalview first appears
                applicationController = ApplicationController(metalView: metalView, options: options)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    InputController.shared.touchLocation = value.location
                    InputController.shared.touchDelta = CGSize(width: value.translation.width - previousTranslation.width,
                                                               height: value.translation.height - previousTranslation.height)
                    previousTranslation = value.translation
                    // if the user drags, cancel the tap touch
                    if abs(value.translation.width) > 1 ||
                        abs(value.translation.height) > 1 {
                        InputController.shared.touchLocation = nil
                    }
                }
                .onEnded {_ in
                  previousTranslation = .zero

                    // bug fix, temp
                  InputController.shared.leftMouseDown = false
                  InputController.shared.canMouseDown = false
                  InputController.shared.touchDelta = nil
              })
            .gesture(MagnificationGesture()
                .onChanged { value in
                    let scroll = value - previousScroll
                    InputController.shared.mouseScroll.x = Float(scroll)
                    previousScroll = value
                }
                .onEnded {_ in
                    previousScroll = 1
                })
    }
}

struct MetalViewRepresentable: NSViewRepresentable {
    let applicationController: ApplicationController?
    @Binding var metalView: MyMTKView
    let options: Options

    func makeNSView(context: Context) -> some NSView {
        let trackingArea = NSTrackingArea(rect: metalView.bounds, options: [.activeWhenFirstResponder, .mouseMoved, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        metalView.addTrackingArea(trackingArea)
        return metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }

    func updateMetalView() {
        applicationController?.options = options
    }
}

class MyMTKView: MTKView {
    override func mouseDown(with event: NSEvent) {
        InputController.shared.canMouseDown = true
    }

    override func mouseUp(with event: NSEvent) {
        InputController.shared.canMouseDown = false
    }
}
