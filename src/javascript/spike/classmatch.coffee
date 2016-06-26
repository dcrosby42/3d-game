mkModule = ->
  class Action

  class Time extends Action

  class Input extends Action

  class Mouse extends Action

  return {
    Action: Action
    Time: Time
    Input: Input
    Mouse: Mouse
  }

M1 = mkModule()
M2 = mkModule()


in1 = new M1.Input()
console.log in1

in2 = new M2.Input()
console.log in2

console.log in1 instanceof M1.Action
console.log in1 instanceof M1.Input
console.log in1 instanceof M1.Time
console.log in1 instanceof M2.Input
console.log in2 instanceof M2.Input



