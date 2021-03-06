//
//  ViewController.swift
//  Example
//
//  Created by Jon Worms on 4/9/17.
//
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

