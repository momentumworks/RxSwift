//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

/**
 Delegate proxy for `NSTextField`.

 For more information take a look at `DelegateProxyType`.
*/
public class RxTextFieldDelegateProxy
    : DelegateProxy
    , NSTextFieldDelegate
    , DelegateProxyType {

    private let doubleSubject     = PublishSubject<Double>()
    private let floatSubject      = PublishSubject<Float>()
    private let intSubject        = PublishSubject<Int>()
    private let textSubject       = PublishSubject<String>()
    private let attributedSubject = PublishSubject<NSAttributedString>()

    private let isEditing = PublishSubject<Bool>()

    /**
     Typed parent object.
    */
    public weak private(set) var textField: NSTextField?

    /**
     Initializes `RxTextFieldDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
    */
    public required init(parentObject: AnyObject) {
        self.textField = (parentObject as! NSTextField)
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate methods

    public override func controlTextDidBeginEditing(_: NSNotification) {
        self.isEditing.onNext(true)
    }

    public override func controlTextDidEndEditing(_: NSNotification) {
        self.isEditing.onNext(false)
    }

    public override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        self.doubleSubject.on(.Next(textField.doubleValue))
        self.floatSubject.on(.Next(textField.floatValue))
        self.intSubject.on(.Next(textField.integerValue))
        self.textSubject.on(.Next(textField.stringValue))
        self.attributedSubject.on(.Next(textField.attributedStringValue))
    }

    // MARK: Delegate proxy methods

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let control = (object as! NSTextField)

        return castOrFatalError(control.rx_createDelegateProxy())
    }

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let textField: NSTextField = castOrFatalError(object)
        return textField.delegate
    }

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let textField: NSTextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }
    
}

extension NSTextField {

    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(parentObject: self)
    }

    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxTextFieldDelegateProxy.self, self)
    }

    private func createControlProperty<T>(source sourceFn: (RxTextFieldDelegateProxy, NSControl) -> Observable<T>, sink sinkFn: (NSControl, T) -> ()) -> ControlProperty<T> {
        let delegate = proxyForObject(RxTextFieldDelegateProxy.self, self)

        let source = Observable.deferred { [weak self] () -> Observable<T> in
            guard let strongSelf = self else {
                return Observable.empty()
            }

            return sourceFn(delegate, strongSelf)
        }.takeUntil(rx_deallocated)

        let observer = UIBindingObserver(UIElement: self) { control, value in
            sinkFn(control, value)
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }

    /**
    Reactive wrapper for `Double` property.
    */
    public var rx_double: ControlProperty<Double> {
        let sourceFn = { (delegate: RxTextFieldDelegateProxy, textField: NSControl) -> Observable<Double> in
            delegate.doubleSubject.startWith(textField.doubleValue)
        }

        let sinkFn = { (control: NSControl, value: Double) in
            control.doubleValue = value
        }
        return createControlProperty(source: sourceFn, sink: sinkFn)
    }

    /**
    Reactive wrapper for `Float` property.
    */
    public var rx_float: ControlProperty<Float> {
        let sourceFn = { (delegate: RxTextFieldDelegateProxy, textField: NSControl) -> Observable<Float> in
            delegate.floatSubject.startWith(textField.floatValue)
        }

        let sinkFn = { (control: NSControl, value: Float) in
            control.floatValue = value
        }
        return createControlProperty(source: sourceFn, sink: sinkFn)
    }

    /**
    Reactive wrapper for `Int` property.
    */
    public var rx_int: ControlProperty<Int> {
        let sourceFn = { (delegate: RxTextFieldDelegateProxy, textField: NSControl) -> Observable<Int> in
            delegate.intSubject.startWith(textField.integerValue)
        }

        let sinkFn = { (control: NSControl, value: Int) in
            control.integerValue = value
        }
        return createControlProperty(source: sourceFn, sink: sinkFn)
    }

    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let sourceFn = { (delegate: RxTextFieldDelegateProxy, textField: NSControl) -> Observable<String> in
            delegate.textSubject.startWith(textField.stringValue)
        }

        let sinkFn = { (control: NSControl, value: String) in
            control.stringValue = value
        }
        return createControlProperty(source: sourceFn, sink: sinkFn)
    }

    /**
    Reactive wrapper for `AttributedString` property.
    */
    public var rx_attributedString: ControlProperty<NSAttributedString> {
        let sourceFn = { (delegate: RxTextFieldDelegateProxy, textField: NSControl) -> Observable<NSAttributedString> in
            delegate.attributedSubject.startWith(textField.attributedStringValue)
        }

        let sinkFn = { (control: NSControl, value: NSAttributedString) in
            control.attributedStringValue = value
        }
        return createControlProperty(source: sourceFn, sink: sinkFn)
    }

    public var rx_textAfterEditing: Observable<String> {
        let delegate = proxyForObject(RxTextFieldDelegateProxy.self, self)

        return Observable.combineLatest(delegate.isEditing, delegate.textSubject) { isEditing, text -> String? in
            if (isEditing) {
                return nil
            } else {
                return text
            }
        }.flatMap { text -> Observable<String> in
            guard let text = text else {
                return Observable.empty()
            }

            return Observable.just(text)
        }
    }
}
