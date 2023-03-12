//
//  Lesson2ViewController.swift
//  GB Combine
//
//  Created by Антон Сивцов on 12.03.2023.
//

import UIKit
import Combine

final class Lesson2ViewController: UIViewController {
    
    private var subscriptions: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        
//        collectExample()
//        mapExample()
//        tryMapExample()
//        flatMapExample()
//        replacingNilExample()
//        replaceEmptyExample()
//        scanExample()
//        filterExample()
//        firstWhereExample()
//        removeDuplicatesExample()
//        ignoreOutputExample()
//        dropFirstExample()
//        dropWhileExample()
//        dropUntilOutputFromExample()
//        prefixExample()
//        prefixWhileExample()
//        prefixUntilOutputFromExample()
//        a1Example()
//        a2Example()
//        a3Example()
//        exersize2Example()
        exersize3Example()
    }
    
    func collectExample() {
        let publisher = ["a", "b", "c", "d", "e", "f"].publisher
        
        publisher
            .collect(2) //.collect()
            .sink { completion in
                print("Collect Example status:", completion)
            } receiveValue: { value in
                print("Value received:", value)
            }.store(in: &subscriptions)
    }
    
    func mapExample() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let publisher = [4, 82, 6].publisher
        
        publisher
            .map {
                formatter.string(for: $0) ?? ""
            }
            .sink(receiveValue: { print("Value Received:", $0) })
            .store(in: &subscriptions)
    }
    
    func tryMapExample() {
        let just = Just("Dirrectory name that does not exists")
        
        just.tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
            .sink { completion in
                print("Collect Example status:", completion)
            } receiveValue: { value in
                print("Value received:", value)
            }
            .store(in: &subscriptions)
    }
    
    struct Chatter {
        let name: String
        let message: CurrentValueSubject<String, Never>
        
        init(name: String, message: String) {
            self.name = name
            self.message = CurrentValueSubject(message)
        }
    }
    
    func flatMapExample() {
        let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte")
        let james = Chatter(name: "James", message: "Hi, I'm James")
        
        let chat: CurrentValueSubject<Chatter, Never> = CurrentValueSubject(charlotte)
        
//        chat.sink(receiveValue: { print("\($0.name) wrote: \($0.message.value)") })
//            .store(in: &subscriptions)
//
//        charlotte.message.value = "Charlotte: How's it going?"
//        chat.value = james
        
//        Charlotte wrote: Hi, I'm Charlotte
//        James wrote: Hi, I'm James
        
        chat.flatMap(maxPublishers: .max(2)) { $0.message }
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
        
        charlotte.message.value = "Charlotte: How's it going?"
        chat.value = james
        
        james.message.value = "James: Doing great. You?"
        charlotte.message.value = "Charlotte: I'm doing fine, thanks"
        
        let bill = Chatter(name: "Bill", message: "Hi, I'm Bill")
        
        chat.value = bill
    }
    
    func replacingNilExample() {
        let publisher = ["A", nil, "C"].publisher
        
        publisher.replaceNil(with: "-")
            .map { $0! }
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func replaceEmptyExample() {
        let publisher = Array<String>().publisher
        
        publisher.replaceEmpty(with: "Adlkjfh")
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func scanExample() {
        var dailyGainLoss: Int { .random(in: -10...10) }
        let days = (0..<15).map { _ in dailyGainLoss }.publisher
        
        days.scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    }
    
    func filterExample() {
        let numbers = (100...200).publisher
        
        numbers
            .filter { $0 % 2 == 0 }
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func firstWhereExample() {
        let numbers = (1...9).publisher
        
        numbers
            .first(where: { $0 % 4 == 0 })
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func removeDuplicatesExample() {
        let words = "hey hey man .. do you you want to to listen to mister mister ? ? ?"
            .components(separatedBy: " ")
            .publisher
        
        words.removeDuplicates()
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func ignoreOutputExample() {
        let publisher = [1, 2, 3, 4, 5].publisher
        
        publisher
            .ignoreOutput()
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func dropFirstExample() {
        let publisher = [1, 2, 3, 4, 5].publisher
        
        publisher
            .dropFirst(2)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func dropWhileExample() {
        let numbers = (1...10).publisher
        
        numbers.drop(while: { $0 % 5 != 0 })
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func dropUntilOutputFromExample() {
        let isReady = PassthroughSubject<Void, Never>()
        let taps = PassthroughSubject<Int, Never>()
        
        taps.drop(untilOutputFrom: isReady)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
        
        (1...5).forEach {
            taps.send($0)
            
            if $0 == 3 {
                isReady.send()
            }
        }
    }
    
    // prefix works agains drop
    
    func prefixExample() {
        let numbers = (1...10).publisher
        
        numbers.prefix(5)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func prefixWhileExample() {
        let numbers = (1...10).publisher
        
        numbers.prefix(while: { $0 % 5 != 0 })
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func prefixUntilOutputFromExample() {
        let isReady = PassthroughSubject<Void, Never>()
        let taps = PassthroughSubject<Int, Never>()
        
        taps.prefix(untilOutputFrom: isReady)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
        
        (1...5).forEach {
            taps.send($0)
            
            if $0 == 3 {
                isReady.send()
            }
        }
    }
    
    // 1
    let numbers = (1...100).publisher
    
    func a1Example() {
        numbers.dropFirst(50)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func a2Example() {
        numbers.dropFirst(50)
            .prefix(20)
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    func a3Example() {
        numbers.filter { $0 % 2 == 0 }
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    // 2
    func exersize2Example() {
        let stringsPublisher = ["2", "4", "9", "43", "sdaf", "2", "78"].publisher
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        stringsPublisher
            .compactMap { Int($0) }
            .collect()
            .map { $0.reduce(0, +) / $0.count }
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
    
    // 3
    func exersize3Example() {
        let publisher = PassthroughSubject<Any, Never>()
        
        publisher
            .findPhoneNumber()
            .sink(receiveValue: { print($0) })
            .store(in: &subscriptions)
        
        publisher.send("7958294573")
    }
}

extension Publisher where Output == Any, Failure == Never {
    func findPhoneNumber() -> AnyPublisher<PhoneNumber, Never> {
        // some base that contains phone numbers
        let base = ["7958294573", "7982944573", "7958298859"]
        
        return self
            .first(where: {
                if let string = $0 as? String, string.count == 10 {
                   return base.contains(string)
                } else if let int = $0 as? Int, String(int).count == 10 {
                    return base.contains(String(int))
                }
                return false
            })
            .compactMap {
                if let string = $0 as? String {
                   return PhoneNumber(value: Int(string) ?? 0)
                } else if let int = $0 as? Int {
                    return PhoneNumber(value: int)
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
}

struct PhoneNumber {
    let value: Int
}
