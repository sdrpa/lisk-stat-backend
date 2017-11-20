// Created by Sinisa Drpa on 11/17/17.

import Foundation
import Dispatch

public class Runner {
   let delay = 10.0

   private let timer = DispatchSource.makeTimerSource()
   private let api = API()

   public init() {
      print("Runner started at: \(Date())")
   }

   deinit {
      timer.suspend()
   }

   public func run() {
      timer.setEventHandler() { [weak self] in
         self?.api.getmarkethistory()
      }

      let now = DispatchTime.now()
      let deadline = DispatchTime(uptimeNanoseconds: now.uptimeNanoseconds + (UInt64(delay * 1e9)))
      timer.schedule(deadline: deadline, repeating: delay)
      timer.resume()
   }
}
