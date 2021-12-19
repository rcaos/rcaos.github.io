---
title: "From Monolith app to Modular app"
categories: "Modular Architecture"
excerpt: Explore the process of breaking a big Monolith app into small modules
---
## App Monolithic vs App Modular ⚙️
In this entry I will share the challenges I faced when converting a monolithic app to a modular one on iOS.

### The beggining
Every app begins in a monolithic way. This is either a single Project, or a Workspace with a single project.

How do I know if my app is monolithic? Your project probably looks like this:
{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-23-app-monolith-to-modular-app-ios/002.png">
{: refdef}


As your app grows each feature, each dependency that you add the compilation times rise, there are no defined limits as everything 
is in a single project.
In this context, it is essential to modularize your large code base, into small, independent and testable components.

## What is a Module?
Consist on take as much individually, coherent code and put in one individually compilable unit. That converts in our basic unit of development: Resources plus code.

## So, But what is Modular Architecture?
Modular programming is a programming paradigm that consists of dividing a program into modules or subprograms in order to 
make it more readable and manageable.

It is historically presented as an evolution of structured programming to solve programming problems larger and more complex than it can solve.

### Profits:
- Escalation: Separating the code into groups by functionalities is essential to be able to scale.
- Team Division: 👨‍💻 👩‍💻
By using frameworks, modules we are isolating functionalities.
Several developers or teams are assigned to a certain module of the app.
Each team can individually use their own architecture
Even if it does not handle a development style guide, each team could have its coding style, you can even test new architectures oriented only to a certain feature.

- Faster compile times. 🚀
When working on a specific module you only compile the dependencies of that module.
Faster development time.
Not only when compiling, you can directly access a certain screen that you are modifying without going through all the screens of the main application.

- Maintenance: Adding a new feature is really easy.
- Testing: Each feature can be tested individually. The UI still has to be tested, but the integration tests are made easier.


After refactoring, now the app looks like this:
{:refdef: style="text-align: center;"}
<img src="{{ site.url }}/assets/posts/2020-07-23-app-monolith-to-modular-app-ios/004.png">
{: refdef}

For the example project I used Cocoa Pods, but it is also applicable to Swift Package Manager or Carthage.

### Modules in Detail:

- Networking: Management of connections with services.
For example here could a third party dependency, for example Alamofire, Moya, etc and it would only belong to this module.

- Shared: To share Domain Entities, Use Cases, Repositories common to the other modules. It could even be broken down a bit more into a Core Module and a Common Module.

- Account: It contains the management of the login, logout and everything concerning actions that depend on an authenticated user.

- KeyChainStorage To save and retrieve values from the KeyChain.

- AiringToday, PopularShows, SearchShows In this case I separated them according to each scene in the main view of the application.

- ShowDetails: A view that is called from different modules. It grew so large that I decided to isolate it into a single module.

- Persistence: Contains the use cases and Repositories to save to persist an entity.

- RealmPersistence: Here I do the Persistence Module implementations. Only here I add the Realm dependency.

In case you need to migrate to CoreData, I replace this module with one "CoreDataPersistence"

- UI: All concerning the visual part of the app, here I include Colors, Fonts, common visual components.

## Possible inconveniences that you will face:

### Bundle
When you work with a single project, it is likely that for references to a Storyboard, nib or image you will do it this way:

```swift
  let nibName = UINib(nibName: "AiringTodayCollectionViewCell", bundle: nil)
  let someImage = UIImage(named: "calendar")
  static func instantiateViewController(_ bundle: Bundle? = nil)
```


When working with modules to reference the Bundle of the module it belongs to

```swift
  let nib = UINib(nibName: identifier, bundle: Bundle(for: T.self))

  internal class SharedModule { 
    static let bundle = Bundle(for: SharedModule.self) 
  }

  public extension UIImage { 
    convenience init?(name: String) { 
      self.init(named: name, in: SharedModule.bundle, compatibleWith: .none) 
    } 
  }
```


### Circular Dependencies 🚫
``
There is a circular dependency between XMPPFramework/Core and XMPPFramework/Authentication
``

The modules depend on others and on third-party Libraries, but mutual dependency is not allowed

If you find yourself in the case that Module A depends on Module B and vice versa, Cocoa Pods will throw you an error.

For these cases it is better to rethink the way your modules interact.

One way out of this is to expose the dependencies of a Module using a protocol and make this module independent.

### Shared module too long
Maybe out of common sense we tend to put everything in the Share module, which would make it grow out of control, 
which would take us to the starting point, we would no longer have a monolithic App, but instead a too extensive Shared Module.

Every time a part of the application or a module in general begins to grow and can be abstracted, as I extract it to an independent module.

### Access control
Keeping access control by default, Swift handles internal and we should use private or fileprivate in most cases.

Only in the case of entry point to a module or when it is really necessary to expose our interfaces as public.

## Conclusion.
It is clear all the benefits of modularizing an application, you can have several developers working in parallel on 
various parts of the application independently.

Even if your app is not that big yet, it can grow very fast in the near future, so you can take advantage of its benefits now.

You can review a final modularized project here: 
[`https://github.com/rcaos/TVToday`](https://github.com/rcaos/TVToday)

## References:
- [https://engineering.depop.com/scaling-up-an-ios-app-with-modularisation-8cd280d6b2b8](https://engineering.depop.com/scaling-up-an-ios-app-with-modularisation-8cd280d6b2b8)
- [https://academy.realm.io/posts/modular-ios-apps/](https://academy.realm.io/posts/modular-ios-apps/)
- [https://medium.com/kinandcartacreated/modular-ios-strangling-the-monolith-4a6843a28992](https://medium.com/kinandcartacreated/modular-ios-strangling-the-monolith-4a6843a28992)
- [https://tech.olx.com/modular-architecture-in-ios-c1a1e3bff8e9](https://tech.olx.com/modular-architecture-in-ios-c1a1e3bff8e9)
- [https://blog.gojekengineering.com/1-app-18-products-a-journey-from-monolith-to-a-microapps-codebase-8ea30d070148](https://blog.gojekengineering.com/1-app-18-products-a-journey-from-monolith-to-a-microapps-codebase-8ea30d070148)
