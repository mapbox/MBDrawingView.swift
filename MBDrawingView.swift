import UIKit

public protocol DrawingViewDelegate {

    func drawingView(drawingView: DrawingView, didDrawWithPoints points: [CGPoint])

}

public class DrawingView: UIView {

    private var points: [CGPoint]!
    private var context: CGContextRef!
    private var strokeColor: UIColor = UIColor.blueColor().colorWithAlphaComponent(0.75)
    private var lineWidth: CGFloat = 3

    public var delegate: DrawingViewDelegate?

    public convenience init(frame: CGRect, strokeColor: UIColor, lineWidth: CGFloat) {
        self.init(frame: frame)

        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init(coder aDecoder: NSCoder) {
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
        UIGraphicsBeginImageContext(bounds.size)
        context = UIGraphicsGetCurrentContext()
        setStrokeColor(self.strokeColor)
        setLineWidth(self.lineWidth)
    }

    override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        points.removeAll(keepCapacity: false)

        let firstPoint = (touches.first as! UITouch).locationInView(self)

        points.append(firstPoint)

        CGContextBeginPath(context)
        CGContextMoveToPoint(context, firstPoint.x, firstPoint.y)
    }

    override public func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        CGContextMoveToPoint(context, points.last!.x, points.last!.y)

        let point = (touches.first as! UITouch).locationInView(self)

        points.append(point)

        CGContextAddLineToPoint(context, point.x, point.y)
        CGContextStrokePath(context)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        layer.contents = image.CGImage
    }

    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        delegate?.drawingView(self, didDrawWithPoints: points)
    }

}
