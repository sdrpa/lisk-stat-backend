
// Created by Sinisa Drpa on 11/16/17.

import Foundation
import Dispatch

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
class Metronome {

   private lazy var timer: DispatchSourceTimer = {
      let t = DispatchSource.makeTimerSource()
      let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(interval)
      let repeating = DispatchTimeInterval.seconds(interval)
      t.schedule(deadline: deadline, repeating: repeating)
      t.setEventHandler(handler: { [weak self] in
         self?.eventHandler?()
      })
      return t
   }()

   private let interval: Int
   private var eventHandler: (() -> Void)?

   init(interval: Int, block: @escaping () -> Void) {
      self.interval = interval
      self.eventHandler = block
   }

   private enum State {
      case suspended
      case resumed
   }

   private var state: State = .suspended

   deinit {
      timer.setEventHandler {}
      timer.cancel()
      /*
       If the timer is suspended, calling cancel without resuming
       triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
       */
      resume()
      eventHandler = nil
   }

   func resume() {
      if state == .resumed {
         return
      }
      state = .resumed
      timer.resume()
   }

   func suspend() {
      if state == .suspended {
         return
      }
      state = .suspended
      timer.suspend()
   }
}
