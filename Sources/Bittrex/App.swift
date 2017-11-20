// Created by Sinisa Drpa on 11/16/17.

import Foundation
import Kitura
import KituraCORS
import SwiftyJSON
import then

public struct App {
   enum err: Error {
      case fatal(String) // description
      case invalidRequest
   }

   public init() {
   }

   public func run() {
      let envVars = ProcessInfo.processInfo.environment
      let portString: String = envVars["PORT"] ?? envVars["CF_INSTANCE_PORT"] ??  envVars["VCAP_APP_PORT"] ?? "8182"
      let port = Int(portString) ?? 8182

      var cors: CORS {
         let options = Options(allowedOrigin: .all,
                               allowedHeaders: ["Content-Type", "Authorization"],
                               maxAge: 5)
         return CORS(options: options)
      }

      let router = Router()
      router.all("/", middleware: cors)
      //router.post("*", middleware: BodyParser())

      router.get("/", handler: App.main)
      router.get("/getmarkethistory", handler: App.marketHistory)

      Kitura.addHTTPServer(onPort: port, with: router)
      Kitura.run()
   }
}

extension App {
   static func main(request: RouterRequest, response: RouterResponse, next: () -> Void) {
      response.status(.OK).send(json: ["Service": "AI"])
      next()
   }

   static func marketHistory(request: RouterRequest, response: RouterResponse, next: () -> Void) {
      defer { next() }
      do {
         let xs = try await(DB.marketHistory())
         let encoded = try App.encoder.encode(["result": xs])
         response.send(data: encoded)
      } catch let error {
         response.status(.internalServerError).send(error.localizedDescription)
      }
   }
}

extension App {
   static func file(_ file: String, location: Int) -> String {
      let filename = URL(fileURLWithPath: file).lastPathComponent
      return filename + ":" + String(location)
   }

   static var encoder: JSONEncoder {
      let encoder = JSONEncoder()
      //encoder.dateEncodingStrategy = .iso8601
      return encoder
   }
}

