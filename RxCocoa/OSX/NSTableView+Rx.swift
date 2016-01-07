//
//  NSTableView+Rx.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSTableView {
    
    /**
     Binds sequences of elements to table view rows.
     
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    
    public func rx_items<E: NSObject, S: SequenceType, O: ObservableType where S.Generator.Element == Dictionary<String, E>, O.E == S>
        (source: O) -> Disposable {
            let dataSource = RxNSTableViewReactiveArrayDataSourceSequenceWrapper<E, S>()
            
            return rx_itemsWithTableViewDataSource(dataSource)(source: source)
    }
    
    /**
     Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
     
     - parameter dataSource: Data source
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    public func rx_itemsWithTableViewDataSource<DataSource: protocol<RxNSTableViewDataSourceType, NSTableViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        (source: O)
        -> Disposable  {
            return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxNSTableViewDataSourceProxy, event) -> Void in
                guard let tableView = self else {
                    return
                }
                dataSource.tableView(tableView, observedEvent: event)
            }
    }

    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxNSTableViewDelegateProxy.self, self)
    }
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createTableViewDelegateProxy() -> RxNSTableViewDelegateProxy {
        return RxNSTableViewDelegateProxy(parentObject: self)
    }
    
    /**
     Factory method that enables subclasses to implement their own `rx_dataSource`.
     
     - returns: Instance of delegate proxy that wraps `dataSource`.
     */
    public func rx_createTableViewDataSourceProxy() -> RxNSTableViewDataSourceProxy {
        return RxNSTableViewDataSourceProxy(parentObject: self)
    }
    
    /**
     Reactive wrapper for `dataSource`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_dataSource: DelegateProxy {
        return proxyForObject(RxNSTableViewDataSourceProxy.self, self)
    }
    
    /**
     Installs data source as forwarding delegate on `rx_dataSource`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func rx_setDataSource(dataSource: NSTableViewDataSource)
        -> Disposable {
            let proxy = proxyForObject(RxNSTableViewDataSourceProxy.self, self)
            
            return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx_delegate`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setDelegate(delegate: NSTableViewDelegate)
        -> Disposable {
            return self.rx_setDelegate(delegate, retainDelegate: false)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx_delegate`, and optionally retains a strong reference to it.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - parameter retainDelegate: Whether or not a strong reference to the delegate should be retained (Note this should typically be false)
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setDelegate(delegate: NSTableViewDelegate, retainDelegate: Bool)
        -> Disposable {
            let proxy: RxNSTableViewDelegateProxy = proxyForObject(RxNSTableViewDelegateProxy.self, self)
            return installDelegate(proxy, delegate: delegate, retainDelegate: retainDelegate, onProxyForObject: self)
    }
}