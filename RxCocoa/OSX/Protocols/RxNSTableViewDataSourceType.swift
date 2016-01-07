//
//  RxNSTableViewDataSourceType.swift
//  Rx
//
//  Created by Rheese Burgess on 07/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

/**
 Marks data source as `NSOutlineView` reactive data source enabling it to be used with one of the `bindTo` methods.
 */
public protocol RxNSTableViewDataSourceType {
    
    /**
     Type of elements that can be bound to outline view.
     */
    typealias Element
    
    /**
     New observable sequence event observed.
     
     - parameter outlineView: Bound outline view.
     - parameter observedEvent: Event
     */
    func tableView(tableView: NSTableView, observedEvent: Event<Element>) -> Void
}
