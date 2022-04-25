---
title: "Moving from RxSwift to Combine"
categories: rxswift combine
excerpt: Moving ViewModels from RxSwift to Combine.
---
## Moving from RxSwift to Combine

Lastly, I have been working on migrating a project from RxSwift to Combine, in this entry will share the learnings from that process, some things result very well and others don’t.

To get the basics of Combine I highly recommend this resource: [https://heckj.github.io/swiftui-notes/](https://heckj.github.io/swiftui-notes/)

### But why model your ViewModels or any business logic with Combine in the first place?

IMO Functional reactive programming increases the code readability and reduces the complexity a lot.

Even though Combine needs a learning curve once when you got comfortable with how the streams work and how the common operators work It will be very rewarding.

Another thing is for this project I still using UIKit, at first I thought of also migrating the UI to SwiftUI, but I started moving only the business logic and exposing Publishers to the ViewControllers.

I think It was a good decision to learn separately because SwiftUI and Combine API are tightly coupled, so you have to pay attention very carefully to figure out the boundaries between SwiftUI and Combine. 

 

### Getting Started

First Step: migrate protocols and implementations with a new Signature: Observable by AnyPubisher

So when you found with an `Observable<Element>`, you will need to change to `AnyPublisher<Element, Error>`

Some useful built-in Publishers that you can use are meanwhile you are migrating the implementation of your code:

- `Fail<Output, Failure>`
- `Empty<Output, Failure>`
- `Just<Output>`
- `Future<Output, Failure>`

### Subjects:

There are two convenient ways to transform imperative into functional code:

- `CurrentValueSubject`: when you need to model some kind of state and you need an initial value, so for every new subscriber, It will emit its current value.

- `PassthroughSubject`: mostly to model events, when you don't have an initial value.

You are going to `eraseToAnyPublisher` a lot, because you are exposing the signature as `AnyPublisher<Output, Error>`, at the end of your implementation, your often would need to use: `}.eraseToAnyPublisher()`

This is because you need to wrap the real type and only expose the generic type.

So your’s subscribers don’t care about the implementation, only are interesting in the result of the stream.

### Operators
Many of the operators available for Combine are self descriptives, so I won't deep here. You can help this project that describes the transition from RxSwift to Combine: [https://github.com/CombineCommunity/rxswift-to-combine-cheatsheet](https://github.com/CombineCommunity/rxswift-to-combine-cheatsheet), and here [https://heckj.github.io/swiftui-notes/#reference-operators](https://heckj.github.io/swiftui-notes/#reference-operators)

### Combine missed some common Operators in Reactive world

Although there is a project with many other operators, for now, I don't see necessary for. In practice with `flatMap`, `combineLatest`, `merge` and `zip`, you are ready to move forward.

### Combine with UIKit

You don't have many options here, you can expose publishers or use the modifier Published.

Another extension is CombineDataSources [https://github.com/CombineCommunity/CombineDataSources](https://github.com/CombineCommunity/CombineDataSources), but since iOS13 with the inclusion of `UICollectionViewDiffableDataSource` and UI`tableviewdiffabledatasource` you can get the same reactivity on your Table / Collection Views

### About Testing

First, remember it that is worth it to write tests from the beginning.

So during my transition, I got fast feedback when I changed any ViewModels, useCases or any wrappers signatures.

To fix that, I read the tests, sent some inputs, and expected some output.

To verify that the UI wasn’t broken, I took advantage of Snapshot tests, so I had the confidence that I was refactoring the business logic without affecting the UI.

### The Schedulers are not designed for Testing.

Using  `RunLoop.main` or `DispatchQuee.main` makes the view models impossible to test.

Although you can use `XCTWaiter.wait` inside yours test, only works for specific cases and in most cases is considered a bad practice.

In RxSwift world we have `RxTest`, but in Combine we don't have a first-party option, so I found this library to recover that control: [https://github.com/pointfreeco/combine-schedulers](https://github.com/pointfreeco/combine-schedulers)

Now I inject the scheduler on the viewModels  will look like this:

```swift
class TVShowDetailViewModel {
  let scheduler: AnySchedulerOf<DispatchQueue>
  // ...
  
  init(fetchDetailShowUseCase: FetchTVShowDetailsUseCase,
	       scheduler: AnySchedulerOf<DispatchQueue> = .main) {
    // ...
    self.scheduler = scheduler
  }
  
  fetchDetailShowUseCase.execute(requestValue: request)
  .receive(on: scheduler)
  // ...
  .store(in: &disposeBag)
}
```

And in Testing time you injected a different scheduler:

```swift
func test_WatchList_Taps_Happy_Path() {
  let scheduler = DispatchQueue.test
	
  let sut: TVShowDetailViewModelProtocol = TVShowDetailViewModel(
    fetchDetailShowUseCase: fetchTVShowDetailsUseCaseMock,
    scheduler: scheduler.eraseToAnyScheduler()
  )

  // when
  sut.viewDidLoad()
  scheduler.advance(by: 1)
  XCTAssertEqual(// ...

  // simulating a button tap
  sut.watchedButtonDidTapped()
  scheduler.advance(by: .milliseconds(300))
  XCTAssertEqual(1, saveToWatchListUseCaseMock.calledCounter)
  XCTAssertEqual([false, true], received)
}
```

When you inject the scheduler on your viewModel, is a way of controlling the time, you can control how the streams flow in a more deterministic way.

### Conclusion

I was happy with the result, It’s a great option to have a first-party library to work with stream values, so you don’t have to fight with dependency management.

I think is a great option to simplify your codebase in a single API and many of its operators are very useful for many common tasks that you need often.

The project that I talked about in this post is this: [https://github.com/rcaos/TVToday](https://github.com/rcaos/TVToday)

## References:
- [https://heckj.github.io/swiftui-note](https://heckj.github.io/swiftui-note)
- [https://quickbirdstudios.com/blog/rxswift-combine-transition-guide/](https://quickbirdstudios.com/blog/rxswift-combine-transition-guide/)
- [https://github.com/pointfreeco/combine-schedulers](https://github.com/pointfreeco/combine-schedulers)
