//
//  CustomSubscriber.swift
//  GB Combine
//
//  Created by Антон Сивцов on 04.03.2023.
//

import Foundation
import Combine

final class CustomSubscriber<T: Hashable, E: Error>: Subscriber {
    typealias Input = T
    typealias Failure = E
    
    func receive(subscription: Subscription) {
        subscription.request(.max(5))
    }
    
    func receive(_ input: T) -> Subscribers.Demand {
        print("receive value", input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<E>) {
        print("Receive completion for \(Self.self)")
        switch completion {
        case .finished:
            print("Finished")
        case .failure(let failure):
            print("Failed with: \(failure.localizedDescription)")
        }
    }
}
