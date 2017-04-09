//
//  LineNumberView.swift
//
//  Copyright (c) 2017 Jon Worms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa


public class LineNumberView: NSRulerView {
	
	
	private var fontAttributes: [String: AnyObject] = [:]
	
	
	// MARK: Colors
	var backgroundColor: NSColor = NSColor(calibratedRed: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
	var foregroundColor: NSColor {
		set { fontAttributes[NSForegroundColorAttributeName] = newValue }
		get { return fontAttributes[NSForegroundColorAttributeName] as! NSColor }
	}
	var selectionColor: NSColor = NSColor.black
	
	
	
	
	required override public init(scrollView: NSScrollView?, orientation: NSRulerOrientation) {
		super.init(scrollView: scrollView, orientation: orientation)
		let lineNumberStyle = NSMutableParagraphStyle()
		lineNumberStyle.alignment = .right
		
		fontAttributes[NSParagraphStyleAttributeName] = lineNumberStyle
		fontAttributes[NSBackgroundColorAttributeName] = NSColor.clear
        foregroundColor = NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.65, alpha: 1.0)
	}
	
	required public init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	
	override public var isFlipped: Bool { return true }
	
	
	override public func draw(_ dirtyRect: NSRect) {
		guard let context: CGContext = NSGraphicsContext.current()?.cgContext else { return }
		
		// fill the background
		context.setFillColor(backgroundColor.cgColor)
		context.fill(dirtyRect)
		
		// draw a border on the right
		context.setStrokeColor(foregroundColor.cgColor)
		context.setLineWidth(0.5)
		context.move(to: CGPoint(x: dirtyRect.width, y: 0))
		context.addLine(to: CGPoint(x: dirtyRect.width, y: dirtyRect.height))
		context.strokePath()
		
		// this usually gets called on super.draw(dirtyRect), but we're not calling it
		drawHashMarksAndLabels(in: dirtyRect)
	}
	
	
	
	
	override public func drawHashMarksAndLabels(in rect: NSRect) {
		
		guard let textView: LineHighlightingTextView = self.clientView as? LineHighlightingTextView,
			  let textContainer: NSTextContainer = textView.textContainer,
			  let textStorage: NSTextStorage = textView.textStorage,
		      let layout: NSLayoutManager = textView.layoutManager,
		      let context: CGContext = NSGraphicsContext.current()?.cgContext else {
			return
		}
	
		
		
		// scalar values for text view content
		let scalars = textStorage.string.unicodeScalars

		// range of glyphs in the visible area of the text view
		let visibleGlyphRange = layout.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
		let selectedLinePosition: CGFloat = textView.selectedLineRect?.origin.y ?? -1
		
		var lineNumber: Int = 1
		// count newlines in range up to the visible range
		for i in 0..<visibleGlyphRange.location {
			if scalars[i].isNewline {
				lineNumber += 1
			}
		}
		
		
		// font operations
		let font: NSFont = textView.font ?? NSFont.controlContentFont(ofSize: 11)
		fontAttributes[NSFontAttributeName] = font // set the font from the textView for number drawing
		
		// line up the baselines for the font with the baselines in the text view
		var fontBaselineOffset = font.boundingRectForFont.height + font.descender
		if layout.defaultLineHeight(for: font) >= fontBaselineOffset {
			fontBaselineOffset = ceil(fontBaselineOffset)
		} else {
			fontBaselineOffset = floor(fontBaselineOffset)
		}
		let lineOffset = layout.defaultBaselineOffset(for: font) - fontBaselineOffset
		// NOTE: ^ above is close, but needs work
		
		
		// translate vertically to line up with document position and baseline offset
		context.translateBy(x: 0, y: convert(NSZeroPoint, from: textView).y + lineOffset)
		
		
		
		// Begin drawing line numbers:
		
		// y-position of the last line
		var lastLinePosition: CGFloat = 0
		
		
		// range of each line as we step through the visible Range, starting at the start of the visible range
		var lineStart = visibleGlyphRange.location
		var lineLength = 0
		
		
		for i in visibleGlyphRange.location..<visibleGlyphRange.location + visibleGlyphRange.length {
			lineLength += 1
			
			if scalars[i].isNewline {
				
				let lineRect = layout.boundingRect(forGlyphRange: NSMakeRange(lineStart, lineLength-1), in: textContainer)
				let markerRect = NSRect(x: 0, y: lineRect.origin.y, width: rect.width-3, height: font.boundingRectForFont.height)

				drawLineNumber(lineNumber, inRect: markerRect, highlight: markerRect.origin.y == selectedLinePosition)
				
				lineStart += lineLength
				lineLength = 0
				lineNumber += 1
				lastLinePosition = markerRect.origin.y + lineRect.height
			}
			
		}

		// draw the last line number
		drawLineNumber(lineNumber, inRect: NSRect(x: 0, y: lastLinePosition, width: rect.width-3, height: font.boundingRectForFont.height), highlight: lastLinePosition == selectedLinePosition)
	}
	


	
	private func drawLineNumber(_ number: Int, inRect rect: NSRect, highlight: Bool = false) {
		if highlight {
			var attributes = fontAttributes
			attributes[NSForegroundColorAttributeName] = selectionColor
			NSString(string: "\(number)").draw(in: rect, withAttributes: attributes)
			return
		}
		NSString(string: "\(number)").draw(in: rect, withAttributes: fontAttributes)
	}
	


}
