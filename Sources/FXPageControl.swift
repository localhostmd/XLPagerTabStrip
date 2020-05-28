//
//  FXPageControl.swift
//  
//
//  Created by Mateusz Dworak on 26/05/2020.
//

import UIKit

@objc class FXPageControl: UIControl {
    typealias DotShapeRawType = Int
    enum DotShape: DotShapeRawType {
        case unknown = 0
        case circle = 1
        case square = 2
        case triangle = 3
    }

    func setUp() {
        // Needs redrawing if bounds change
        contentMode = .redraw
    }

    func sizeForNumber(ofPages pageCount: Int) -> CGSize {
        let width = dotSize + (dotSize + dotSpacing) * CGFloat((numberOfPages - 1))
        return vertical ? CGSize(width: dotSize, height: width) : CGSize(width: width, height: dotSize)
    }

    func updateCurrentPageDisplay() {
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard numberOfPages > 0 else { return }
        guard numberOfPages > 1 || !hidesForSinglePage else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let size = sizeForNumber(ofPages: numberOfPages)

        if vertical {
            context.translateBy(x: frame.size.width / 2, y: (frame.size.height - size.height) / 2)
        } else {
            context.translateBy(x: (frame.size.width - size.width) / 2, y: frame.size.height / 2)
        }

        for i in 0..<numberOfPages {
            var dotImage: UIImage?
            var dotColor: UIColor?
            var dotShape: DotShape!
            var dotSize: CGFloat = 0
            var dotShadowColor: UIColor?
            var dotShadowOffset = CGSize.zero
            var dotShadowBlur: CGFloat = 0

            if i == _currentPage {
                selectedDotColor.setFill()
                dotImage = delegate?.pageControl(self, selectedImageForDotAtIndex: i)
                dotShape = DotShape(rawValue: delegate?.pageControl(self, selectedShapeForDotAtIndex: i) ?? _dotShape)
                dotColor = delegate?.pageControl(self, selectedColorForDotAtIndex: i) ?? .black
                dotShadowBlur = self.selectedDotShadowBlur
                dotShadowColor = self.selectedDotShadowColor
                dotShadowOffset = self.selectedDotShadowOffset
                dotSize = selectedDotSize != 0 ? selectedDotSize : dotSize
            } else {
                selectedDotColor.setFill()
                dotImage = delegate?.pageControl(self, imageForDotAtIndex: i) ?? self.dotImage
                dotShape = DotShape(rawValue: delegate?.pageControl(self, shapeForDotAtIndex: i) ?? _dotShape)
                dotColor = delegate?.pageControl(self, colorForDotAtIndex: i) ?? self.dotColor
            }

            context.saveGState()
            let offset = (self.dotSize + self.dotSpacing) * CGFloat(i) + self.dotSize / 2
            context.translateBy(x: vertical ? 0 : offset, y: vertical ? offset : 0)

            if let dotShadowColor = dotShadowColor, dotShadowColor != .clear {
                context.setShadow(offset: dotShadowOffset, blur: dotShadowBlur, color: dotShadowColor.cgColor)
            }

            if let dotImage = dotImage {
                dotImage.draw(in: CGRect(x: -dotImage.size.width / 2, y: -dotImage.size.height / 2, width: dotImage.size.width, height: dotImage.size.height))
            } else {
                dotColor?.setFill()
                switch dotShape {
                case .circle:
                    context.fillEllipse(in: CGRect(x: -dotSize / 2, y: -dotSize / 2, width: dotSize, height: dotSize))
                case .square:
                    context.fill(CGRect(x: -dotSize / 2, y: -dotSize / 2, width: dotSize, height: dotSize))
                case .triangle:
                    context.beginPath()
                    context.move(to: CGPoint(x: 0, y: -dotSize / 2))
                    context.addLine(to: CGPoint(x: dotSize / 2, y: dotSize / 2))
                    context.addLine(to: CGPoint(x: -dotSize / 2, y: dotSize / 2))
                    context.addLine(to: CGPoint(x: 0, y: -dotSize / 2))
                    context.fillPath()
                default:
                    context.beginPath()
                    context.fillPath()
                }
            }
            context.restoreGState()
        }
    }

    func clampedPageValue(for page: Int) -> Int {
        if wrapEnabled {
            return numberOfPages > 0 ? (page + numberOfPages) % numberOfPages: 0
        } else {
            return min(max(0, page), numberOfPages - 1)
        }
    }

    @IBOutlet weak var delegate: PageControlDelegate?

    private var _currentPage: Int = 0
    @IBInspectable var currentPage: Int {
        get { _currentPage }
        set {
            _currentPage = clampedPageValue(for: newValue)
        }
       }
    private var _numberOfPages: Int = 0
    @IBInspectable var numberOfPages: Int {
        get { _numberOfPages }
        set {
            if _numberOfPages != newValue {
                _numberOfPages = newValue
                if _currentPage >= newValue {
                    _currentPage = _numberOfPages - 1
                }
                setNeedsDisplay()
            }
        }
    }
    @IBInspectable var defersCurrentPageDisplay: Bool = false
    @IBInspectable var hidesForSinglePage: Bool = false
    @IBInspectable var wrapEnabled: Bool = false
    @IBInspectable var vertical: Bool = false

    @IBInspectable var dotImage: UIImage! {
        didSet { setNeedsDisplay() }
    }

    private var _dotShape = 0
    @IBInspectable var dotShape: DotShapeRawType {
        get {
            _dotShape
        }
        set {
            if newValue > _dotShape {
                if newValue > DotShape.triangle.rawValue {
                    _dotShape = DotShape.triangle.rawValue
                } else if newValue < DotShape.circle.rawValue {
                    _dotShape = DotShape.circle.rawValue
                } else {
                    _dotShape = newValue
                }
            }
        }
    }
    @IBInspectable var dotSize: CGFloat = 6.00 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotColor: UIColor! {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotShadowColor: UIColor! {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotShadowBlur: CGFloat = 0 {
           didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotShadowOffset: CGSize = CGSize(width: 0, height: 1) {
           didSet { setNeedsDisplay() }
    }

    @IBInspectable var selectedDotImage: UIImage! {
              didSet { setNeedsDisplay() }
       }
    private var _selectedDotShape: DotShapeRawType = 0
    @IBInspectable var selectedDotShape: DotShapeRawType {
        get {
            _selectedDotShape
        }
        set {
            if newValue > _selectedDotShape {
                if newValue > DotShape.triangle.rawValue {
                    _selectedDotShape = DotShape.triangle.rawValue
                } else if newValue < DotShape.circle.rawValue {
                    _selectedDotShape = DotShape.circle.rawValue
                } else {
                    _selectedDotShape = newValue
                }
            }
        }
    }
    @IBInspectable var selectedDotSize: CGFloat = 0 {
              didSet { setNeedsDisplay() }
       }
    @IBInspectable var selectedDotColor: UIColor! {
              didSet { setNeedsDisplay() }
       }
    @IBInspectable var selectedDotShadowColor: UIColor! {
              didSet { setNeedsDisplay() }
       }
    @IBInspectable var selectedDotShadowBlur: CGFloat = 0 {
              didSet { setNeedsDisplay() }
       }
    @IBInspectable var selectedDotShadowOffset: CGSize = CGSize(width: 0, height: 1) {
              didSet { setNeedsDisplay() }
       }

    @IBInspectable var dotSpacing: CGFloat = 10.0 {
              didSet { setNeedsDisplay() }
       }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let point = touch?.location(in: self) else { return }
        let forward = vertical ? (point.y > frame.size.height / 2) : (point.x > frame.size.width / 2)
        currentPage = clampedPageValue(for: currentPage + (forward ? 1 : -1))

        if defersCurrentPageDisplay {
            setNeedsDisplay()
        }
        sendActions(for: .valueChanged)
        super.endTracking(touch, with: event)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var dotSize = sizeForNumber(ofPages: numberOfPages)
        if selectedDotSize != 0 {
            let width = selectedDotSize - self.dotSize
            let height = max(36, max(self.dotSize, selectedDotSize))
            dotSize.width = vertical ? height : dotSize.width + width
            dotSize.height = vertical ? dotSize.height + width : height
        }
        if (dotShadowColor != nil && dotShadowColor != .clear) || (selectedDotShadowColor != nil && selectedDotShadowColor != .clear) {
            dotSize.width += max(dotShadowOffset.width, selectedDotShadowOffset.width) * 2
            dotSize.height += max(dotShadowOffset.height, selectedDotShadowOffset.height) * 2
            dotSize.width += max(dotShadowBlur, selectedDotShadowBlur) * 2
            dotSize.height += max(dotShadowBlur, selectedDotShadowBlur) * 2
        }
        return dotSize
    }

    override var intrinsicContentSize: CGSize {
        sizeThatFits(bounds.size)
    }
}

@objc protocol PageControlDelegate: AnyObject, NSObjectProtocol {
    func pageControl(_ pageControl: FXPageControl, imageForDotAtIndex index: Int) -> UIImage?
    func pageControl(_ pageControl: FXPageControl, shapeForDotAtIndex index: Int) -> FXPageControl.DotShapeRawType
    func pageControl(_ pageControl: FXPageControl, colorForDotAtIndex index: Int) -> UIColor?

    func pageControl(_ pageControl: FXPageControl, selectedImageForDotAtIndex index: Int) -> UIImage?
    func pageControl(_ pageControl: FXPageControl, selectedShapeForDotAtIndex index: Int) -> FXPageControl.DotShapeRawType
    func pageControl(_ pageControl: FXPageControl, selectedColorForDotAtIndex index: Int) -> UIColor?
}

extension PageControlDelegate {
    func pageControl(_ pageControl: FXPageControl, imageForDotAtIndex index: Int) -> UIImage? { return nil }
    func pageControl(_ pageControl: FXPageControl, shapeForDotAtIndex index: Int) -> FXPageControl.DotShapeRawType { return 0 }
    func pageControl(_ pageControl: FXPageControl, colorForDotAtIndex index: Int) -> UIColor? { return nil }

    func pageControl(_ pageControl: FXPageControl, selectedImageForDotAtIndex index: Int) -> UIImage? { return nil }
    func pageControl(_ pageControl: FXPageControl, selectedShapeForDotAtIndex index: Int) -> FXPageControl.DotShapeRawType { return 0 }
    func pageControl(_ pageControl: FXPageControl, selectedColorForDotAtIndex index: Int) -> UIColor? { return nil }
}
