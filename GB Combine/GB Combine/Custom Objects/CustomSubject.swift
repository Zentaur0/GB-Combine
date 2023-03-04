//
//  CustomSubject.swift
//  GB Combine
//
//  Created by Антон Сивцов on 04.03.2023.
//

import Foundation
import Combine

final class CustomSubject<T: Hashable, E: Error>: Subject {
    typealias Output = T
    typealias Failure = E
    
    private var subscribers: [any Subscriber] = []
    private var customSubscribers: [CustomSubscriber<T, E>] = []
    
    func send(subscription: Subscription) {
        subscribers.forEach { subscriber in
            subscriber.receive(subscription: subscription)
        }
        
        customSubscribers.forEach { subscriber in
            subscriber.receive(subscription: subscription)
        }
    }
    
    func send(_ value: T) {
        subscribers.forEach { subscriber in
            if let subscriber = subscriber as? any Subscriber<T, Never> {
                let _ = subscriber.receive(value)
            }
        }
        
        customSubscribers.forEach { subscriber in
            let _ = subscriber.receive(value)
        }
    }
    
    func send(completion: Subscribers.Completion<E>) {
        subscribers.forEach { subscriber in
            if let subscriber = subscriber as? any Subscriber<T, E> {
                let _ = subscriber.receive(completion: completion)
            }
        }
        
        customSubscribers.forEach { subscriber in
            subscriber.receive(completion: completion)
        }
        customSubscribers = []
        subscribers = []
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, E == S.Failure, T == S.Input {
        guard let subscriber = subscriber as? CustomSubscriber<T, E> else {
            subscribers.append(subscriber)
            return
        }
        
        customSubscribers.append(subscriber)
    }
}
