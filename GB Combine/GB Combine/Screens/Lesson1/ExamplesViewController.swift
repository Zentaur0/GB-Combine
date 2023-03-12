//
//  ExamplesViewController.swift
//  GB Combine
//
//  Created by Антон Сивцов on 04.03.2023.
//

import UIKit
import Combine

final class Lesson1ViewController: UIViewController {

    var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemYellow
        
//        example()
//        justExample()
//        assignToOnExample()
//        customSubscriberExample()
//        futureExample()
//        subjectExample()
//        customExample()
    }

    private func example() {
        let myNoitification = Notification.Name("My notification")
        let center = NotificationCenter.default
        let publisher = center.publisher(for: myNoitification)
        
        let subscription = publisher.sink { notification in
            print("Notification received from a publisher! Notification -> \(notification)")
        }
        
        center.post(name: myNoitification, object: nil)
        subscription.cancel()
    }

    private func justExample() {
        let just = Just("Hello world!")
        
        just.sink { completion in
            print("Receive Completion", completion)
        } receiveValue: { value in
            print("Receive Value", value)
        }

        just.sink(
            receiveCompletion: {
                print("Received completion (another)", $0)
            }, receiveValue: {
                print("Received value (another)", $0)
            }
        )
    }
    
    private func assignToOnExample() {
        class SomeClass {
            var someValue = "" {
                didSet {
                    print(someValue)
                }
            }
        }
        
        let object = SomeClass()
        let publisher = ["Hello world", "Fuck this world"].publisher
        
        publisher.assign(to: \.someValue, on: object)
    }
    
    private func customSubscriberExample() {
        let intPublisher = (0...10).publisher
        
        let intSubscriber = IntSubscriber()
        
        DispatchQueue.global().async {
            intPublisher.subscribe(intSubscriber)
        }
    }
    
    func futureExample() {
        func futureIncrement(
            integer: Int,
            afterDelay delay: TimeInterval
        ) -> Future<Int, Never> {
            Future<Int, Never> { promise in
                print("Original")
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    promise(.success(integer + 1))
                }
            }
        }
        
        let future = futureIncrement(integer: 1, afterDelay: 3)
        
        future
            .sink { completion in
                print("Receive completion", completion)
            } receiveValue: { value in
                print("Receive Value", value)
            }
            .store(in: &subscription)
    }
    
    func subjectExample() {
        let subscriber = StringSubscriber()
        let subject = PassthroughSubject<String, StringSubscriber.MyError>()
        
        subject.subscribe(subscriber)
        
        let subscription = subject
            .sink { completion in
                print("Receive completion (sink)", completion)
            } receiveValue: { value in
                print("Receive value (sink)", value)
            }

        subject.send("Hello")
        subject.send("Fuck")
        subject.send("World")
        
        subscription.cancel()
        
        subject.send("Still there?")
        
        subject.send(completion: .failure(.test))
        subject.send(completion: .finished)
        
        subject.send("How about another one?")
    }
    
    func customExample() {
        let subscriber = CustomSubscriber<String, Never>()
        let subject = CustomSubject<String, Never>()
        
        subject.subscribe(subscriber)
        
        let subscription = subject.sink {
            print("23iu4234", $0)
        } receiveValue: {
            print("dksajfld", $0)
        }

        subject.send("First")
        subject.send("Second")
        
        subscription.cancel()
        subject.send("adsflkjgalgsjfagagsg")
        subject.send(completion: .finished)
        
        subject.send("Third")
    }
}

final class StringSubscriber: Subscriber {
    enum MyError: Error {
        case test
    }

    typealias Input = String
    typealias Failure = StringSubscriber.MyError
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        print("Receive value", input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<StringSubscriber.MyError>) {
        print("Receive Completion for subscriber \(Self.self)", completion)
    }
}

final class IntSubscriber: Subscriber {

    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.max(5))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Receive value", input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Receive Completion for subscriber \(Self.self)", completion)
    }
}
