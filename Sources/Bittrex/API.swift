
// Created by Sinisa Drpa on 11/16/17.

import Foundation

class API {
   private let apiServer = "https://bittrex.com/api/v1.1"
   private let session = URLSession(configuration: .default)
   private var dataTask: URLSessionDataTask?

   func getmarkethistory() {
      let request = urlRequest(path: apiServer + "/public/getmarkethistory",
                               method: "GET",
                               params: ["market": "BTC-LSK"])
      dataTask?.cancel()
      dataTask = session.dataTask(with: request) { [weak self] data, response, error in
         defer {
            self?.dataTask = nil
         }
         if let error = error {
            fatalError(error.localizedDescription)
         } else if let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200,
            let marketHistory = API.marketHistoryFrom(data: data) {
            do {
               try DB.insert(marketHistory: marketHistory)
               print("Successfuly added market history at: \(Date())")
            } catch let error {
               fatalError(error.localizedDescription)
            }
         }
      }
      dataTask?.resume()
   }
}

extension API {
   static func marketHistoryFrom(data: Data) -> [MarketHistory]? {
      do {
         let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
         guard let results = json?["result"] as? [[String: Any]] else {
            print("Could not parse json?['result'].")
            return nil
         }
         let history = results.flatMap { (result: [String: Any]) -> MarketHistory? in
            return marketHistory(result: result)
         }
         return history
      } catch let error {
         fatalError(error.localizedDescription)
      }
   }

   static func marketHistory(result: [String: Any]) -> MarketHistory {
      guard let id = result["Id"] as? Int else {
         fatalError("Could not parse id.")
      }
      guard let timestamp = result["TimeStamp"] as? String,
         let date = API.dateFromISO(string: timestamp) else {
            fatalError("Could not parse timestamp.")
      }
      guard let quantity = double(result["Quantity"]) else {
         fatalError("Could not parse quantity.")
      }
      guard let price = double(result["Price"]) else {
         fatalError("Could not parse price.")
      }
      guard let total = double(result["Total"]) else {
         fatalError("Could not parse total.")
      }
      guard let fillTypeRaw = result["FillType"] as? String,
         let fillType = FillType(rawValue: fillTypeRaw),
         let orderTypeRaw = result["OrderType"] as? String,
         let orderType = OrderType(rawValue: orderTypeRaw) else {
            fatalError("Could not parse fillType, orderType.")
      }
      return MarketHistory(id: id,
                           date: date,
                           quantity: quantity,
                           price: price,
                           total: total,
                           fillType: fillType,
                           orderType: orderType)
   }

   static func double(_ jsonValue: Any?) -> Double? {
      switch jsonValue {
      case let value as Double:
         return value
      case let value as Int:
         return Double(value)
      default:
         return nil
      }
   }
}

extension API {
   static func dateFromISO(string: String) -> Date? {
      let indexOfLastDot: Int
      if string.contains(".") {
         guard let index = string.lastIndexOf(target: ".") else {
            return nil
         }
         indexOfLastDot = index
      } else {
         indexOfLastDot = string.count
      }
      let substring = String(string.prefix(indexOfLastDot))
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      let date = dateFormatter.date(from: substring)
      return date
   }

   func urlRequest(path: String, method: String, params: [String: String]) -> URLRequest {
      guard var url = URL(string: path) else {
         fatalError()
      }
      url = url.appendingQueryParameters(params)
      var request = URLRequest(url: url)
      request.httpMethod = method
      return request
   }
}

// MARK: -

protocol URLQueryParameterStringConvertible {
   var queryParameters: String {get}
}

extension Dictionary: URLQueryParameterStringConvertible {
   /**
    This computed property returns a query parameters string from the given NSDictionary. For
    example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
    string will be @"day=Tuesday&month=January".
    @return The computed parameters string.
    */
   var queryParameters: String {
      var parts: [String] = []
      for (aKey, aValue) in self {
         let key = String(describing: aKey).encodingAddingPercent()
         let value = String(describing: aValue).encodingAddingPercent()
         parts.append("\(key)=\(value)")
      }
      return parts.joined(separator: "&")
   }
}

extension URL {
   /**
    Creates a new URL by adding the given query parameters.
    @param parametersDictionary The query parameter dictionary to add.
    @return A new URL.
    */
   func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
      let URLString : String = "\(self.absoluteString)?\(parametersDictionary.queryParameters)"
      return URL(string: URLString)!
   }
}

// MARK: -

extension String {
   func lastIndexOf(target: String) -> Int? {
      if let range = self.range(of: target, options: .backwards) {
         return self.distance(from: startIndex, to: range.lowerBound)
      } else {
         return nil
      }
   }

   func encodingAddingPercent() -> String {
      guard let string = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
         fatalError()
      }
      return string
   }
}

