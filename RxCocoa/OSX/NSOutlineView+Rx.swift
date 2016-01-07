//
//  NSOutlineView+Rx.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 17/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSOutlineView {

    /**
    Binds sequences of elements to outline view rows.

    - parameter source: Observable sequence of items.
    - parameter childrenFactory: Transform between sequence elements and their child elements.
    - returns: Disposable object that can be used to unbind.
    */
    public func rx_itemsWithChildrenFactory<S: SequenceType, O: ObservableType where S.Generator.Element : NSObject, O.E == S>
            (source: O)
            (childrenFactory: (S.Generator.Element) -> [S.Generator.Element])
                    -> Disposable {
        let dataSource = RxNSOutlineViewReactiveArrayDataSourceSequenceWrapper<S>(childrenFactory: childrenFactory)

        return self.rx_itemsWithOutlineViewDataSource(dataSource)(source: source)
    }

    /**
    Binds sequences of elements to outline view rows using a custom reactive data used to perform the transformation.

    - parameter dataSource: Data source
    - parameter source: Observable sequence of items.
    - returns: Disposable object that can be used to unbind.
    */
    public func rx_itemsWithOutlineViewDataSource<DataSource: protocol<RxNSOutlineViewDataSourceType, NSOutlineViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
            (dataSource: DataSource)
            (source: O)
                    -> Disposable  {
        return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxNSOutlineViewDataSourceProxy, event) -> Void in
            guard let outlineView = self else {
                return
            }
            dataSource.outlineView(outlineView, observedEvent: event)
        }
    }

    /**
    Reactive wrapper for `delegate`.

    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public override var rx_delegate: DelegateProxy {
        return proxyForObject(RxNSOutlineViewDelegateProxy.self, self)
    }

    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createOutlineViewDelegateProxy() -> RxNSOutlineViewDelegateProxy {
        return RxNSOutlineViewDelegateProxy(parentObject: self)
    }

    /**
     Factory method that enables subclasses to implement their own `rx_dataSource`.

     - returns: Instance of delegate proxy that wraps `dataSource`.
     */
    public func rx_createOutlineViewDataSourceProxy() -> RxNSOutlineViewDataSourceProxy {
        return RxNSOutlineViewDataSourceProxy(parentObject: self)
    }

    /**
     Reactive wrapper for `dataSource`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public override var rx_dataSource: DelegateProxy {
        return proxyForObject(RxNSOutlineViewDataSourceProxy.self, self)
    }

    /**
     Installs data source as forwarding delegate on `rx_dataSource`.

     It enables using normal delegate mechanism with reactive delegate mechanism.

     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func rx_setDataSource(dataSource: NSOutlineViewDataSource)
                    -> Disposable {
        let proxy = proxyForObject(RxNSOutlineViewDataSourceProxy.self, self)

        return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }

    /**
     Installs delegate as forwarding delegate on `rx_delegate`.

     It enables using normal delegate mechanism with reactive delegate mechanism.

     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setDelegate(delegate: NSOutlineViewDelegate)
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
    public func rx_setDelegate(delegate: NSOutlineViewDelegate, retainDelegate: Bool)
                    -> Disposable {
        let proxy: RxNSOutlineViewDelegateProxy = proxyForObject(RxNSOutlineViewDelegateProxy.self, self)
        return installDelegate(proxy, delegate: delegate, retainDelegate: retainDelegate, onProxyForObject: self)
    }

    // MARK Events

    public var rx_itemSelected: ControlEvent<Int> {
        let source = rx_delegate.observe("outlineViewSelectionDidChange:")
        .map { _ in
            return self.selectedRow
        }

        return ControlEvent(events: source)
    }
}