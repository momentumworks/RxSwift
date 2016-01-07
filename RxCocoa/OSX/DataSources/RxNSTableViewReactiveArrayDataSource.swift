//
//  RxNSTableViewReactiveArrayDataSource.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

// objc monkey business
class _RxNSTableViewReactiveArrayDataSource: NSObject, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _numberOfRowsInTableView(tableView)
    }

    func _numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return _tableView(tableView, objectValueForTableColumn: tableColumn, row: row)
    }
    
    func _tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        rxAbstractMethod()
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        return _tableView(tableView, setObjectValue: object, forTableColumn: tableColumn, row: row)
    }
    
    func _tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        rxAbstractMethod()
    }
}

class RxNSTableViewReactiveArrayDataSourceSequenceWrapper<E: NSObject, S: SequenceType where S.Generator.Element == Dictionary<String, E>>
    : RxNSTableViewReactiveArrayDataSource<E>, RxNSTableViewDataSourceType {
    typealias Element = S
    
    func tableView(tableView: NSTableView, observedEvent: Event<S>) {
        switch observedEvent {
        case .Next(let value):
            super.tableView(tableView, observedElements: Array(value))
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxNSTableViewReactiveArrayDataSource<E: NSObject>: _RxNSTableViewReactiveArrayDataSource {
    var itemModels: [[String : E]] = []
    let NIL_COLUMN = ""
    
    override init() {
        NSLog("Initing...")
        super.init()
    }
    
    override func _numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return itemModels.count ?? 0
    }
    
    override func _tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let item = itemModels[row]
        let res = item[tableColumn?.identifier ?? NIL_COLUMN]
        let id = tableColumn?.identifier ?? NIL_COLUMN
        return itemModels[row][tableColumn?.identifier ?? NIL_COLUMN]
    }
    
    override func _tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        let element = object as! E
        itemModels[row][tableColumn?.identifier ?? NIL_COLUMN] = element
    }
    
    // reactive
    
    func tableView(tableView: NSTableView, observedElements: [[String : E]]) {
        itemModels = observedElements
        
        let newColumnIDs = observedElements[0].keys
        let oldColumns = tableView.tableColumns
        let oldColumnIDs = oldColumns.map{$0.identifier}
        
        for oldColumn in oldColumns {
            if (!newColumnIDs.contains(oldColumn.identifier)) {
                tableView.removeTableColumn(oldColumn)
            }
        }
        
        for newColumnID in newColumnIDs {
            if (!oldColumnIDs.contains(newColumnID)) {
                let newColumn = NSTableColumn(identifier: newColumnID)
                newColumn.title = newColumnID
                
                tableView.addTableColumn(newColumn)
            }
        }
        
        
        tableView.reloadData()
    }
}