//: Playground - noun: a place where people can play

import UIKit

let noteSeparation:CGFloat = 1.059463
let delta:CGFloat = 10

let f1:CGFloat = 18
let f2:CGFloat = 18*noteSeparation
let a = 11000/2048


func yAtIndex(index:Int)->CGFloat{
    let indexF = CGFloat(index)
    return round((log(indexF+1)/log(noteSeparation))*delta)
}
