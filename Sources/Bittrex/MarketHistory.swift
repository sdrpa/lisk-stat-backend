// Created by Sinisa Drpa on 11/16/17.

import Foundation

struct MarketHistory: Encodable {
   let id: Int
   let date: Date
   let quantity: Double
   let price: Double
   let total: Double
   let fillType: FillType
   let orderType: OrderType

   private enum CodingKeys : String, CodingKey {
      case id = "Id", date = "TimeStamp", quantity = "Quantity", price = "Price", total = "Total", fillType = "FillType", orderType = "OrderType"
   }

   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(date.iso8601, forKey: .date)
      try container.encode(quantity, forKey: .quantity)
      try container.encode(price, forKey: .price)
      try container.encode(total, forKey: .total)
      try container.encode(fillType, forKey: .fillType)
      try container.encode(orderType, forKey: .orderType)
   }
}

enum FillType: String, Encodable {
   case fill = "FILL"
   case partialFill = "PARTIAL_FILL"
}

enum OrderType: String, Encodable {
   case buy = "BUY"
   case sell = "SELL"
}

extension Formatter {
   static let iso8601: DateFormatter = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
      return formatter
   }()
}

extension Date {
   var iso8601: String {
      return Formatter.iso8601.string(from: self)
   }
}
