//
//  PasteboardChangeStore.swift
//  CopiPasta
//
//  Created by Сергей Лукичев on 16.11.2024.
//

import Combine
import SwiftUI

final class PasteboardChangeStore: ObservableObject {
    
    private var pasteboardChangedSubscription: AnyCancellable? = nil
    
    private let callback: PasteboardCallback
    
    init(for pasteboard: UIOrNSPasteboard, callback: @escaping PasteboardCallback) {
        self.callback = callback
        self.pasteboardChangedSubscription = getPasteboardChangedPublisher(pasteboard: pasteboard)
            .sink { [weak self] _ in self?.callback() }
    }
    
    private func getPasteboardChangedPublisher(pasteboard: UIOrNSPasteboard) -> AnyPublisher<Void, Never> {
        Timer.publish(every: 1, on: .current, in: .common)
            .autoconnect()
            .map { _ in
                let count = pasteboard.changeCount
                return count
            }
            .merge(with: Just(pasteboard.changeCount))
            .removeDuplicates()
            .dropFirst()
            .void()
            .eraseToAnyPublisher()
    }
}

public typealias UIOrNSPasteboard = NSPasteboard

public extension View {
    func onPasteboardChange(for pasteboard: UIOrNSPasteboard = .general, do callback: @escaping PasteboardCallback) -> some View {
        PasteboardChangeListenerView(containing: self, for: pasteboard, do: callback)
    }
}

public typealias PasteboardCallback = () -> Void

struct PasteboardChangeListenerView<T>: View where T: View {
    private let containingView: T
    
    @StateObject private var store: PasteboardChangeStore
    
    init(containing view: T, for pasteboard: UIOrNSPasteboard, do callback: @escaping PasteboardCallback) {
        self.containingView = view
        
        let store = PasteboardChangeStore(for: pasteboard, callback: callback)
        _store = StateObject<PasteboardChangeStore>(wrappedValue: store)
    }
    
    var body: some View {
        containingView
    }
}

extension Publisher {
    func void() -> Publishers.Map<Self, Void> {
        self
            .map { _ in Void() }
    }
}
