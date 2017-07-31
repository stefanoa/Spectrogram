//: Playground - noun: a place where people can play

import UIKit
let delta:CGFloat = 10
func yAtIndex(index:Int)->CGFloat{
    let indexF = CGFloat(index)
    return round((log(indexF+1)/log(noteSeparation))*delta)
}
let noteSeparation:CGFloat = 1.059463
let size:Int = 16

let y0 = yAtIndex(index: 0)
for i in 0...size-1{
    let y = yAtIndex(index: i)
    print("y:\(y)")
}
print ("size:\(yAtIndex(index:size-1))")


