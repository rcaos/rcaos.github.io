---
title: "What is Functional Programming and why you should care?"
categories: "Functional Programming"
excerpt: Explore the concepts behind the functional programming that supports the famouse frameworks as RxSwift, Combine
---
## What is Functional Programming and why you should care?
If you developing iOS apps, you are likely to come across these frameworks that Apple has released in the last year:

- Combine: Apple's new Functional Reactive Programming framework for handling asynchronous processes.
- SwiftUI: Provides us with a functional programming environment to build user interfaces declaratively on iOS and other Apple platforms.
- And off course our old friend:  RxSwift: maintained by the community, a framework based on "Functional Reactive Programming".

Something that iOS developers cannot escape is the _Functional_ part and if you have not yet interacted with these tools jet,
at the beginning it can be very overwhelming all the new concepts of both: the _Functional_ part and the _Reactive_ part.
In this post, I will cover the functional part and how you can use it in your day-to-day when you use Swift, 
I will leave the Reactive part for another entry. One step at a time. 

Swift is a primarily imperative language, but modern functional programming concepts have been introduced into its design, let's explore some concepts:

## First-Class Functions

In Swift we can use functions like Data types, this implies that we can:

- Assign functions to variables
- Pass functions as arguments
- Return functions as a result of another function

```swift
  func incrementer(_ element: Int) -> Int {
    return element + 1
  }
  
  func multiplier(_ element: Int) -> Int {
    return element * 2
  }
  
  // #1: Can set a function a variable
  let incrementOperation = incrementer
```

```swift
  typealias operation = (Int) -> Int
  
  // #2: Can I receive a function as parameter
  func incrementerOperation(_ value: Int, _ operation: incrementer) -> Int {
    return operation(value)
  }
```

```swift
  // #3: Can I return a function
  func chooseOperation(value: Int) -> operation {
    return value < 10 ? incrementer : multiplier
  }
``` 

## Higher-Order Functions

It is a special function that meets at least one of the following requirements:

- Receive a function as an argument or
- Returns a function

This behavior offers a high level of abstraction since they allow abstracting not only values but actions.
Swift offers Higher Order functions, for instance: map, filter, reduce.

{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-09-functional-programming-swift-ios/001.png">
{: refdef}

## Pure Function

{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-09-functional-programming-swift-ios/002.png">
{: refdef}

It is a function that must be fulfilled:

- Given the same arguments, it always returns the same values.
- It has no side effects
- It does not depend on the external state, it depends solely and exclusively on the input parameters.

It may seem like such a simple concept 🤷‍♂️, but it is one of the foundations of functional programming.

Pure Functions are extremely independent, they are easy to move, refactor, and rearrange in code, making programs more flexible and adaptable in the future.

Not pure function 🚫
```swift
  var isLoading = false

  // Because depend of values outside of Input parameters function
  
  func doubleValues(_ array: [Int]) -> [Int] {
    if isLoading {
      return []
    } else {
      return array.map { $0 * 2 }
    }
  }
```

Pure function ✅
``` swift
  let animals = ["cow", "dog ", "pig", "bird"]

  // Depends only on its arguments
  func capitalize(_ animals: [String], except: String) -> [String] {
    return animals
      .map {
        if $0 != except {
          return $0.prefix(1).capitalized + $0.dropFirst()
        } else {
          return $0
        }
    }
  }

  let filters = capitalize(animals, except: "pig")  // ["Cow", "Dog ", "pig", "Bird"]
```

⚠️ Warning ⚠️

- Not every function by nature can be pure.
- Many times there is no other option but to invoke global functions.
- Have implicit dependencies
- Depend on external factors
- I/O

## Shared State

It is any variable, or object, that exists in a shared scope or as a property of an object that is passed between scopes.

Functional programming avoids shared state, instead relying on immutable data structures and pure function calls to derive new existing data.

The big problem with shared state is that to understand how a function works, you must know the complete history of each shared variable that the function uses or affects.
You need to know in advance how and how many times a function has been called.

## Immutability

- An object is immutable when it cannot be modified after it is created
- Swift provides immutable data structures by definition.
- To avoid that a variable mute we use "let", this allows the Swift compiler to optimize the code.
- Immutability ensures that the code we write has no side effects.
- In Swift most of the structures it provides are of Type Value (Int, String, Array), this implies that when assigning them to a variable their value is copied.

Value types are very important because they simplify compiler behavior in memory management.
In addition, they do not increase the value of the ARC, but the memory can be freed when its current scope is removed.
<br><br>
So is it very expensive to use Types by Value?
For example, copy an array of 1000 elements each time it is assigned to another variable.
But this is not the case, since the Swift compiler optimizes these statements and only performs the copy when there is a modification of the variables that share the array.
This technique is called Copy on Write

## Side Effects

It is any change of state of the application that a function performs other than its return value:

- Modify a global or static variable
- Write to file
- Network calls
- Launch an external process
- Call other functions with Side Effects

It is impossible to think that an application does not have side effects, it is more we build apps because we want Side Effects, 
we want to make payments, persist data on the device, use the network, send an email.

The thing to keep in mind is that it should be isolated from the rest of the software. 
By keeping the side effects separate from the rest of the program logic, the software will be much easier to understand, refactor, debug, test, and maintain.

## So What is Functional programming?🤔

{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-09-functional-programming-swift-ios/003.png">
{: refdef}

It is the process of building software:

- Using pure functions
- Avoiding the shared state
- Avoiding data mutation and
- Avoiding side effects.

The state of the application flows through pure functions, the pillar of functional programming is to transform a data flow and as a result another data flow returns.
As a result the code tends to be more concise, more predictable, therefore easier to test.

## From imperative to Functional

{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-09-functional-programming-swift-ios/004.png">
{: refdef}

We must remember that the change from imperative to functional is not an all or nothing game, a more reserved approach would be to start small, 
start writing Pure Functions and use Higher Order Functions whenever it makes sense. 
(map, filter, reduce) and gradually implement all these new concepts in the code that we write every day.

One drawback you might face is that due to muscle memory, the next time you sit down to write code and 
come across problems that you have faced before, you will naturally use the same approach that you have always used to solve them.

Applying the functional approach is a mental leap, but it's worth it, your code will become easier to test, reuse, and refactor.
Remember that the goal is to create pure, simple and generic functions and then compose more complex functions using composition.

In the real world the applications we build widely mix Functional Programming, Object Oriented or some other paradigm, 
personally I write functional code where it makes sense, it shouldn't force things either.

I hope you are encouraged to use these concepts, that will help you to create code easies to read, reuse and maintain.

## References:

- [What is a Pure Function](https://medium.com/javascript-scene/master-the-javascript-interview-what-is-a-pure-function-d1c076bec976/)
- [Elements of Functional Programming](https://www.youtube.com/watch?v=OgU8d_E1K14)
- [Composing Software The Book](https://medium.com/javascript-scene/composing-software-the-book-f31c77fc3ddc)
- [What is Copy on Write](https://www.hackingwithswift.com/example-code/language/what-is-copy-on-write)
