//
//  IntroductionExampleViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 5/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cocoa
import AppKit

class Thingy: NSObject {
    let i: Int
    
    init(i: Int) {
        self.i = i
    }
}

class IntroductionExampleViewController : ViewController {
    @IBOutlet var a: NSTextField!
    @IBOutlet var b: NSTextField!
    @IBOutlet var c: NSTextField!
    @IBOutlet var slider: NSSlider!
    @IBOutlet var sliderValue: NSTextField!
    @IBOutlet var tableView: NSTableView!
    
    @IBOutlet var disposeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        showAlert("After you close this, prepare for a loud sound ...")

        // c = a + b
        let sum = Observable.combineLatest(a.rx_text, b.rx_text) { (a: String, b: String) -> (Int, Int) in
            return (Int(a) ?? 0, Int(b) ?? 0)
        }
        
        // bind result to UI
        sum
            .map { (a, b) in
                return "\(a + b)"
            }
            .bindTo(c.rx_text)
            .addDisposableTo(disposeBag)
        
        // Also, tell it out loud
//        let speech = NSSpeechSynthesizer()
//        
//        sum
//            .map { (a, b) in
//                return "\(a) + \(b) = \(a + b)"
//            }
//            .subscribeNext { result in
//                if speech.speaking {
//                    speech.stopSpeaking()
//                }
//                
//                speech.startSpeakingString(result)
//            }
//            .addDisposableTo(disposeBag)
        
        
        slider.rx_value
            .subscribeNext { value in
                self.sliderValue.stringValue = "\(Int(value))"
            }
            .addDisposableTo(disposeBag)
        
        sliderValue.rx_text
            .subscribeNext { value in
                let doubleValue = value.toDouble() ?? 0.0
                self.slider.doubleValue = doubleValue
                self.sliderValue.stringValue = "\(Int(doubleValue))"
            }
            .addDisposableTo(disposeBag)
        
        let items: Observable<[[String: Thingy]]> = Observable.just([["Column A": Thingy(i: 1), "Column B": Thingy(i: 10)],
            ["Column A": Thingy(i: 2), "Column B": Thingy(i: 20)],
            ["Column A": Thingy(i: 3), "Column B": Thingy(i: 30)]])
        
        items
            .bindTo(tableView.rx_items)
            .addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
        
        disposeButton.rx_tap
            .subscribeNext { [weak self] _ in
                print("Unbind everything")
                self?.disposeBag = DisposeBag()
            }
            .addDisposableTo(disposeBag)
    }
}

extension IntroductionExampleViewController : NSTableViewDelegate {
    func toString<T>(t: T?) -> String? {
        if (t != nil) {
            return "\(t!)"
        }
        
        return nil
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: NSTableCellView
        
        let item = tableView.dataSource()?.tableView?(tableView, objectValueForTableColumn: tableColumn, row: row)
        let i = (item as? Thingy)?.i
        let label = toString(i) ?? ""
        
        if let fetchedCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) {
            cellView = fetchedCell as! NSTableCellView
            cellView.textField?.stringValue = label
        } else {
            cellView = NSTableCellView()
            cellView.identifier = tableColumn!.identifier
            
            let textField = NSTextField(frame: CGRect(x: 0, y: -2, width: 200, height: 20))
            textField.identifier = tableColumn!.identifier
            textField.stringValue = label
            textField.bordered = false
            textField.drawsBackground = false
            
            cellView.textField = textField
            cellView.addSubview(textField)
        }
        
        return cellView
    }
}