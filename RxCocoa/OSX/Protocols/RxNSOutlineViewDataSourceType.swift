//
//  RxNSOutlineViewDataSourceType.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 17/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

/**
 Marks data source as `NSOutlineView` reactive data source enabling it to be used with one of the `bindTo` methods.
 */
public protocol RxTableViewDataSourceType {

    /**
     Type of elements that can be bound to outline view.
     */
    typealias Element

    /**
     New observable sequence event observed.

     - parameter outlineView: Bound outline view.
     - parameter observedEvent: Event
     */
    func outlineView(outlineView: NSOutlineView, observedEvent: Event<Element>) -> Void
}
