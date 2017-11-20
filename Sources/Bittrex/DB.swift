// Created by Sinisa Drpa on 11/16/17.

import Foundation
import SwiftKuery
import SwiftKueryPostgreSQL
import then

struct DB {
   static let host = "localhost"
   static let dbname = "..."
   static let port: Int32 = 5432
   static let username = "..."
   static let password = "..."
}

fileprivate class MarketHistoryTable: Table {
   let tableName = "market_history"
   let id = Column("id")
   let timestamp = Column("timestamp")
   let quantity = Column("quantity")
   let price = Column("price")
   let total = Column("total")
   let fillType = Column("fill_type")
   let orderType = Column("order_type")
}
fileprivate let table = MarketHistoryTable()

extension MarketHistory: Mappable {
   init?(rows: [String: Any]) {
      guard let id = rows[table.id.name] as? Int64,
         let timestamp = rows[table.timestamp.name] as? Int64,
         let quantity = rows[table.quantity.name] as? Double,
         let price = rows[table.price.name] as? Double,
         let total = rows[table.total.name] as? Double,
         let fillTypeRaw = rows[table.fillType.name] as? String,
         let fillType = FillType(rawValue: fillTypeRaw),
         let orderTypeRaw = rows[table.orderType.name] as? String,
         let orderType = OrderType(rawValue: orderTypeRaw) else {
            return nil
      }
      self.id = Int(id)
      self.date = Date(timeIntervalSince1970: Double(timestamp))
      self.quantity = quantity
      self.price = price
      self.total = total
      self.fillType = fillType
      self.orderType = orderType
   }
}

extension DB {
   static func insert(marketHistory: [MarketHistory]) throws {
      let values = marketHistory.enumerated().reduce(String()) { acc, curr in
         let string = acc + "(\(curr.element.id)," +
            "\(curr.element.date.timeIntervalSince1970)," +
            "\(curr.element.quantity)," +
            "\(curr.element.price)," +
            "\(curr.element.total)," +
            "'\(curr.element.fillType.rawValue)'," +
            "'\(curr.element.orderType.rawValue)')"
         return ((curr.offset + 1) == marketHistory.count)
            ? string
            : string + ","
      }
      let connection = PostgreSQLConnection(host: host, port: port, options: [.userName(username), .password(password), .databaseName(dbname)])
      defer { connection.closeConnection() }
      do {
         let raw = "INSERT INTO market_history VALUES \(values) ON CONFLICT DO NOTHING;"
         _ = try await(connection.connect())
         let result = try await(connection.execute(raw, parameters: []))
         if let queryError = result.asError {
            throw queryError
         }
      } catch let error {
         fatalError(error.localizedDescription)
      }
   }

   static func marketHistory() -> Promise<[MarketHistory]> {
      let connection = PostgreSQLConnection(host: host, port: port, options: [.userName(username), .password(password), .databaseName(dbname)])
      return Promise { resolve, reject in
         do {
            _ = try await(connection.connect())
//            let raw =
//               """
//               SELECT * FROM market_history
//               WHERE timestamp > $1
//               ORDER BY timestamp DESC;
//               """
//            let lastHours = 3
//            let lastHoursInSeconds = 60 * 60 * lastHours
//            let result = try await(connection.execute(raw, parameters: [Int(Date().timeIntervalSince1970) - lastHoursInSeconds]))
            let raw =
               """
               SELECT * FROM market_history
               ORDER BY timestamp DESC
               LIMIT 5000;
               """
            let result = try await(connection.execute(raw, parameters: []))
            switch result {
            case .resultSet(let resultSet):
               let terms = DB.rows(from: resultSet).flatMap(MarketHistory.init(rows:))
               resolve(terms)
            case .success(_), .successNoData:
               reject(App.err.fatal(App.file(#file, location: #line)))
            case .error(let error):
               reject(error)
            }
         } catch let error {
            reject(error)
         }
      }.noMatterWhat {
            connection.closeConnection()
      }
   }
}

extension DB {
   static func rows(from resultSet: ResultSet) -> [[String: Any]] {
      let ts = resultSet.rows.map {
         zip(resultSet.titles, $0)
      }
      let xs: [[String: Any]] = ts.map {
         var dictionaries = [String: Any]()
         $0.forEach {
            let (title, value) = $0
            dictionaries[title] = value
         }
         return dictionaries
      }
      return xs
   }

   static func truncate() throws {
      let connection = PostgreSQLConnection(host: host, port: port, options: [.userName(username), .password(password), .databaseName(dbname)])
      defer {
         connection.closeConnection()
      }
      do {
         let raw = "TRUNCATE ...;"
         _ = try await(connection.connect())
         let result = try await(connection.execute(raw))
         if let error = result.asError {
            throw error
         }
      } catch let error {
         throw error
      }
   }
}
