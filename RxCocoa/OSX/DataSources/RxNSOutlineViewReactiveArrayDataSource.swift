//
//  RxNSOutlineViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 17/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

// objc monkey business
class _RxNSOutlineViewReactiveArrayDataSource: NSObject, NSOutlineViewDataSource {
    func _outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        rxAbstractMethod()
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return _outlineView(outlineView, child: index, ofItem: item)
    }

    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    func _outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return 0
    }

    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return _outlineView(outlineView, numberOfChildrenOfItem: item)
    }

    func _outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return nil
    }

    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return _outlineView(outlineView, objectValueForTableColumn: tableColumn, byItem: item)
    }
}

class RxNSOutlineViewReactiveArrayDataSourceSequenceWrapper<S: SequenceType where S.Generator.Element : NSObject>
        : RxNSOutlineViewReactiveArrayDataSource<S.Generator.Element>, RxNSOutlineViewDataSourceType {

    typealias Element = S

    override init(childrenFactory: ChildrenFactory) {
        super.init(childrenFactory: childrenFactory)
    }

    func outlineView(outlineView: NSOutlineView, observedEvent: Event<S>) {
        switch observedEvent {
        case .Next(let value):
            super.outlineView(outlineView, observedElements: Array(value))
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxNSOutlineViewReactiveArrayDataSource<Element: NSObject> : _RxNSOutlineViewReactiveArrayDataSource {
    typealias ChildrenFactory = (Element) -> [Element]

    var itemModels: [Element]? = nil

    let childrenFactory: ChildrenFactory

    init(childrenFactory: ChildrenFactory) {
        self.childrenFactory = childrenFactory
    }

    override func _outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil) {
            return (itemModels?[index])!
        } else {
            return childrenFactory(item as! Element)[index]
        }
    }

    override func _outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (item == nil) {
            return itemModels?.count ?? 0
        } else {
            return childrenFactory(item as! Element).count
        }
    }

    override func _outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return item
    }

    // reactive

    func outlineView(outlineView: NSOutlineView, observedElements: [Element]) {
        self.itemModels = observedElements

        outlineView.reloadData()
    }
}