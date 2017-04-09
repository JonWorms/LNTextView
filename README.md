LNTextView
===========

![Screenshot](https://github.com/JonWorms/LNTextView/blob/master/Screenshot.gif?raw=true)
### Installing:
You can either copy LNTextView.swift, LineHighlightingTextView.swift, and LineNumberView.swift into your project, or you can build and embed the LNTextView framework into your project. I release will come soon, at which time you should be able to use [Carthage](https://github.com/Carthage/Carthage) as well.
### Example Usage:
###### With Storyboard:
```Swift
//
//  ViewController.swift
//  Example
//
import Cocoa
import LNTextView

class ViewController: NSViewController {

	@IBOutlet var textView: LNTextView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Set a color theme:
		textView.textBackgroundColor = NSColor(calibratedRed: CGFloat(29.0/255.0), green: CGFloat(32.0/255.0), blue: CGFloat(35.0/255.0), alpha: 1)
		textView.lineNumbersBackgroundColor = NSColor(calibratedRed: CGFloat(54.0/255.0), green: CGFloat(56.0/255.0), blue: CGFloat(58.0/255.0), alpha: 1)
		textView.lineNumbersForegroundColor = NSColor.gray
		textView.selectionColor = NSColor(calibratedRed: 0.28, green: 0.30, blue: 0.32, alpha: 1)
		textView.currentLineColor = NSColor.white
		textView.textColor = NSColor.white
		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
```
