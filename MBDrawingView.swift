import UIKit

public protocol MBDrawingViewDelegate {

    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint])

}

public class MBDrawingView: UIView {

    private var points: [CGPoint]!
    private var context: CGContextRef!
    private var strokeColor: UIColor = UIColor.blueColor().colorWithAlphaComponent(0.75)
    private var lineWidth: CGFloat = 3

    public var delegate: MBDrawingViewDelegate?

    public convenience init(frame: CGRect, strokeColor: UIColor, lineWidth: CGFloat) {
        self.init(frame: frame)

        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    deinit {
        UIGraphicsEndImageContext()
    }

    public func setStrokeColor(strokeColor: UIColor) {
        self.strokeColor = strokeColor
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
    }

    public func setLineWidth(lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        CGContextSetLineWidth(context, lineWidth)
    }

    private func setup() {
        backgroundColor = UIColor.clearColor()

        points = [CGPoint]()

        createContext()
    }

    public func reset() {
        points = [CGPoint]()

        UIGraphicsEndImageContext();

        createContext()
    }

    private func createContext() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        context = UIGraphicsGetCurrentContext()
        setStrokeColor(self.strokeColor)
        setLineWidth(self.lineWidth)
    }

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        points.removeAll(keepCapacity: false)

        let firstPoint = touches.first!.locationInView(self)

        points.append(firstPoint)

        CGContextBeginPath(context)
        CGContextMoveToPoint(context, firstPoint.x, firstPoint.y)
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        CGContextMoveToPoint(context, points.last!.x, points.last!.y)

        let point = touches.first!.locationInView(self)

        points.append(point)

        CGContextAddLineToPoint(context, point.x, point.y)
        CGContextStrokePath(context)

        #if swift(>=2.3)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
        #else
            let image = UIGraphicsGetImageFromCurrentImageContext()
        #endif

        layer.contents = image.CGImage
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.drawingView(self, didDrawWithPoints: points)
    }

}
