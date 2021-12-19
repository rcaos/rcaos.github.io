---
title: "About the Coordinator pattern on iOS"
categories: "Navigation"
excerpt: Thoughts about using the Coordinator pattern on iOS
---
## About the Coordinator pattern on iOS

When I learned to develop applications for iOS one of the topics that are included is 
how to handle navigation within the application or how to go from one screen to another.

To face this problem we have a mechanism provided by Apple and Xcode: Storyboards and Segues

At first it seemed so natural to me, after all, using the tools that Apple provides you is most of the time a safe bet.

This works for small applications, but once your application grows you face different problems:

- Navigation is static and using storyboards can easily get out of control.
- View Controllers end up with code that corresponds to navigation (too much responsibility)
- High coupling between ViewControllers (why ViewController A has to know that it should display ViewController B and what's more, why should it know how to create or inject dependencies to this ViewController B)
- Boilerplate code
- Reusability issues
- Using the same screen in different contexts
- A / B testing
- Push Notifications

## What is a Coordinator

The idea of a Coordinator is simple.

It is likely that in your application you have several flows grouped according to your business logic 
(Onboarding, User Registration, Settings, User Profile, Shopping Cart, New Order, etc.)

Now each of these flows would be managed by a Coordinator. The Coordinator's job is to know which ViewController to display.

Suppose I have an Onboarding, at the end of its work this communicates to its Coordinator that it has finished or that 
the user has triggered an action that implies showing another ViewController.

The Coordinator knows where to go and how to do it.

This supposes to lighten our ViewControllers, since you are taking the responsibility of handling navigation from them.

Advantages:

- ViewControllers reusability
- Allow to present a Viewcontroller in different contexts
- Easy implementation of Dependency Injection
- Remove code related to the navigation of the View Controllers

## How to implement it?

Although there are several Frameworks: XCoordinator, Coordinator, RxFlow

But you could start with something simpler:

```swift
  public protocol Coordinator {
    func start()
    func stop()
  }
```

## Child Coordinators:

If you have a large application you can divide a coordinator into child Coordinators, each responsible for handling a certain flow of the application.

These in turn may have other child Coordinators and so on.

When a Child Coordinator finishes she informs her father that she has finished.


## Steps:

This is a concept that I took up from [here](https://github.com/RxSwiftCommunity/RxFlow/blob/main/RxFlow/Step.swift): 

A Step could be defined as a path or navigation flow within a Coordinator.

```swift
  public protocol Step {
  }
 
  public struct DefaultStep: Step {
    public init() { }
  }
```

Using Steps within our Coordinator:

```swift
  public protocol Coordinator {
    func start(with step: Step)
    func start()
    func stop()
  }
```

### Example:
Suppose we have our Contact Coordinator, through this enumeration we define the possible actions that this Coordinator can handle:

```swift
  public enum ContactsSteps: Step {
    case main
    case detail
    case userProfile(userId: String)
    case userProfileFromNotification(userId: String)
  }
```

The great advantage of using an Enumeration to define the Steps is that the possible navigation flows of a Coordinator are explicit 
that allow us to quickly have an overview of the Coordinator

To instantiate the Coordinator with the default Step, I would do it as follows:
```swift
  let contactsCoordinator = ContactsCoordinator(navigationController: navigation)
  contactsCoordinator.start()
```

What if I want to instantiate the Coordinator from a notification? Or I just don't want to router to an option within the menu:
```swift
  let contactsCoordinator = ContactsCoordinator(navigationController: navigation)
  contactsCoordinator.start(with: ContactsSteps.userProfileFromNotification(userId: "insert-id-here"))
```

## Handling dependencies

If you have noticed, the creation of the ViewControllers is simple, it does not have any dependencies, but in a real app, regardless of the design pattern (MVC, MVVM, VIPER, Clean Swift, etc.) that we are using, our ViewControllers need dependencies.

Maybe you need to inject a ViewModel ?, a Service ?, a UseCase ?, a Repository? An Interactor?

As common sense it would be to include the logic of creating our VC within the Coordinator, but as this would imply that the Coordinator separates about the management of these dependencies and what it entails (Scope of dependencies, Life cycle, etc.)

Our Coordinator shouldn't care how the ViewControllers are created, internally I may be using Storyboards, XIB files, by code, etc.

Nor are the dependencies required to create these components

To face this problem we create an object whose job it will be to create these ViewControllers.


Now inside our Coordinator we can use this container to create our View Controllers:

## Communication from ViewControllers to Coordinators

Regardless of the pattern you use, you will need a way to communicate with the coordinator.

To accomplish this we have several ways, the most common are using Protocols or using Closures.

The simplest is using closures, x example:

It is important to remember that when we use closures, we must use weak self to prevent memory leaks.


## Communication between Coordinators

Another important point to control is the way in which our Coordinators end, they can occur in 2 situations:

The main view managed by the Coordinator disappears from the navigation stack as a result of a user action.
The view disappears because the user clicked on the "Back" button in our navigation.
The first case is easy to handle, like the previous point, I can inject the ViewController with a closure in which I can control the moment when the user performs a certain action.

The second requires a bit more work, since we usually delegate the navigation behavior to what is built by default in UIKit.

In most cases you don't have to worry about when the user pressed the back button to free up resources.

## Controlling navigation

But when using Child Coordinators we must control that they finish their life cycle correctly by removing them from the parent Coordinator arrangement.

A possible solution for this would be to listen to the events sent by the UINavigationControllerDelegate and be listening on the parent Coordinator when a view is removed from the navigation stack.

Another possible solution is to rewrite the Back button with a custom Button and inform Coordinator that it is ending the main view.

I particularly prefer to use a kind of "hack" that consists of adding a last call in the Main view of a Child Coordinator before it finishes deinitializing.

You could inject a Closure into it and call the Coordinator's Stop method correctly.

```swift
  public class NextViewController: UIViewController {
    var nextAction: (() -> Void)?
    var viewDidFinish: (() -> Void)?
  
    deinit {
      print("Deinit 🔥 \(Self.self)")
      viewDidFinish?()
    }
  }
```

## Conclusion:

Ready that concludes much of the way we use the Coordinator pattern at work.

This has made it easier for us to better control the navigation within the application, to use our ViewControllers in different contexts and to make them lighter.

I hope this information will help you and you can use it in your next project.

I have tried to cut down a lot of the code to be able to generate the snippets.

In this project I have included several of the points mentioned in this post: [`https://github.com/rcaos/DemoCoordinators`](https://github.com/rcaos/DemoCoordinators)  

## References:
- [https://www.raywenderlich.com/158-coordinator-tutorial-for-ios-getting-started](https://www.raywenderlich.com/158-coordinator-tutorial-for-ios-getting-started)
- [https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps](https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps)
- [https://www.hackingwithswift.com/articles/175/advanced-coordinator-pattern-tutorial-ios](https://www.hackingwithswift.com/articles/175/advanced-coordinator-pattern-tutorial-ios)
- [https://blog.kulman.sk/architecting-ios-apps-coordinators/](https://blog.kulman.sk/architecting-ios-apps-coordinators/)
- [https://github.com/RxSwiftCommunity/RxFlow](https://github.com/RxSwiftCommunity/RxFlow)
