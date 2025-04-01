import Foundation
import Swiftty

Window.enableRawMode()
Window.enterAlternateScreen()

defer {
  Window.disableRawMode()
  Window.exitAlternateScreen()
}

let reader = Reader()
try await reader.run { event in
  switch event {
  case .key(let keyEvent):
    switch keyEvent.code {
    case .char("q") where keyEvent.modifiers == nil, .cc(.etx):
      await reader.stop()
    default: break
    }
  default: break
  }
  print(event)
}
