//
//  UnitTests.swift
//  UnitTests
//
//  Created by George Nikolaev on 06.02.2024.
//

import XCTest
@testable import AcquirustClient

func initializeListAccountsRequest() -> ListAccountsResponse {
    var array = [AccountInfo]()
    for _ in 0...10 {
        let sender = Account(cardNumber: UUID(), isExisting: true)
        let recipient = Account(cardNumber: UUID(), isExisting: true)
        let transaction = Transaction(
            sender: sender,
            recipient: recipient,
            amount: 10,
            datetime: Date()
        )
        let account_info = AccountInfo(
            cardNumber: sender.cardNumber,
            balance: 100,
            transactions: [transaction]
        )
        array.append(account_info)
    }
    return ListAccountsResponse(accounts: array)
}

final class UnitTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of
        // each test method in the class.
    }
    
    func testSerializeDeserializeListAccountRequest() throws {
        let request: ListAccountsResponse = initializeListAccountsRequest()
        let data = try JSONEncoder().encode(request)
        print(String(data: data, encoding: .utf8))
        let _ = try JSONDecoder().decode(ListAccountsResponse.self, from: data)
    }
    
    func testSerializeFromStringListAccountRequest() throws {
        let string = "{\"accounts\":[{\"card_number\":\"3519f236-73aa-4e0a-87fb-ed11a0807f98\",\"balance\":11,\"transactions\":[{\"sender\":{\"card_number\":\"9a683ca7-4aa1-4a32-b35e-3be8b8413577\",\"is_existing\":true},\"recipient\":{\"card_number\":\"3519f236-73aa-4e0a-87fb-ed11a0807f98\",\"is_existing\":true},\"amount\":12,\"datetime\":\"2024-02-07T07:24:29Z\"},{\"sender\":{\"card_number\":\"3519f236-73aa-4e0a-87fb-ed11a0807f98\",\"is_existing\":true},\"recipient\":{\"card_number\":\"6feb8830-4904-472e-a8be-77b6d78e0518\",\"is_existing\":true},\"amount\":1,\"datetime\":\"2024-02-07T07:24:44Z\"}]},{\"card_number\":\"6feb8830-4904-472e-a8be-77b6d78e0518\",\"balance\":1,\"transactions\":[{\"sender\":{\"card_number\":\"3519f236-73aa-4e0a-87fb-ed11a0807f98\",\"is_existing\":true},\"recipient\":{\"card_number\":\"6feb8830-4904-472e-a8be-77b6d78e0518\",\"is_existing\":true},\"amount\":1,\"datetime\":\"2024-02-07T07:24:44Z\"}]}]}"
        let data = string.data(using: .utf8)!;
        let _ = try JSONDecoder().decode(ListAccountsResponse.self, from: data)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(
            with: self,
            options: []
        ),
              let data = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
              ),
              let prettyPrintedString = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
              ) else { return nil }
        
        return prettyPrintedString
    }
}
