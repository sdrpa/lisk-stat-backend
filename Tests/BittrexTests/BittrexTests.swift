// Created by Sinisa Drpa on 9/24/17.

import XCTest
@testable import Bittrex

class BittrexTests: XCTestCase {
   override func setUp() {
   }

   override func tearDown() {
   }

   func testDateFromIsoDate() {
      XCTAssertNotNil(API.dateFromISO(string: "2014-07-09T03:21:20.087"))
      XCTAssertNotNil(API.dateFromISO(string: "2014-07-09T03:21:20.08"))
      XCTAssertNotNil(API.dateFromISO(string: "2014-07-09T03:21:20"))
   }

   func test() {
      let result: [String: Any] = ["OrderType": "SELL",
                                   "Quantity": 100,
                                   "Id": 46845976,
                                   "TimeStamp": "2017-11-17T17:30:50.143",
                                   "Price": 0.0011449699999999999,
                                   "FillType": "PARTIAL_FILL",
                                   "Total": 0.114497]
      XCTAssertNotNil(API.marketHistory(result: result))
   }
}
