---
title: "Test your ViewControllers"
categories: "Testing"
excerpt: Learn how to test use Snapshot tests for your ViewControllers
---

We write a lot of UI code, both ViewControllers and UIViews make up a large part of our codebase.

In addition there are many extreme cases that we have to handle when testing our views.

It is unusual to do tests on Views, since business logic, Use Cases, Repositories, etc. are generally tested, relegating the UI tests.

## But why?

I must admit that it is very difficult to cover all the UI code you have with unit tests.

It's much easier to test business logic, but testing views always seemed less than intuitive to me.

There are several ways to test our views:

- Unit Test to each element of the UI verifying its content.
- End to End Tests (XCUI)
- SnapShot Tests 📸

Testing UI components is often tricky because there are too many moving parts involved.
In order to test the view controller, we need things to work in **isolation**.

An overarching design goal is to have a clear separation of interests.

We must remember that the only job of our Views should be to render the UI and propagate user interactions.

A View controller that does too many things will be a very difficult VC to test. Patterns like MVVM, MVP help in this case.


## Making the View Controllers testable
Generally if we use MVVM or MVP or some other architecture pattern when testing the output of our ViewModels indirectly 
we are already testing the input of our views. And since the views are kept as passive agents, 
it seems like a double effort to test the views by checking the content of each element.

Dependency injection is a highly widespread technique in the iOS world, it allows us to 
isolate our Views in this case so that during testing we can mock up the objects.

Example using MVVM:

Design the ViewControllers to depend on a protocol instead of a specific instance of the viewModel:
```swift
  class PopularsViewController: UIViewController, StoryboardInstantiable {
    var viewModel: PopularViewModelProtocol!
  
    static func create(with viewModel: PopularViewModelProtocol) -> PopularsViewController {
      let controller = PopularsViewController.instantiateViewController()
      controller.viewModel = viewModel
      return controller
    }
  }
```

Defining a viewModel protocol:
```swift
  protocol PopularViewModelProtocol {
  
    // MARK: - Input
    func viewDidLoad()
    func didLoadNextPage()
    func showIsPicked(with id: Int)
    func refreshView()
  
    // MARK: - Output
    var viewState: Observable<SimpleViewState<TVShowCellViewModel>> { get }
    func getCurrentViewState() -> SimpleViewState<TVShowCellViewModel>
  }
```

Ready now we can use the interface of the ViewModel Protocol and mock it up to do the following types of tests:

## Snapshot Test 📸
I will concentrate on this type of test since I found this framework great. 
Originally created by Facebook, but is now maintained by the Uber team.

### How does it work?
Test the interface of your app by taking a snapshot of the UI and comparing it with a reference image, as simple as that.

It is a very useful tool in our testing arsenal to make the UI look the way we intended.

While it has more features like testing standalone UIViews or testing Layers, but for now let's just leave it to the basics.

1. Mocking the ViewModel

```swift
  class PopularViewModelMock: PopularViewModelProtocol {
    func viewDidLoad() { }
    
    func didLoadNextPage() { }
    
    func showIsPicked(with id: Int) { }
    
    func refreshView() { }
    
    func getCurrentViewState() -> SimpleViewState<TVShowCellViewModel> {
      //...
      return .empty
    }
  
    var viewState: Observable<SimpleViewState<TVShowCellViewModel>>
  
    init(state: SimpleViewState<TVShowCellViewModel>) {
      viewState = Observable.just(state)
    }
  }
```

2. Creating a SnapShot Test

```swift
  class PopularViewTests: FBSnapshotTestCase {
  
    let firstShow = TVShow.stub(id: 1, name: "Dark 🐶", voteAverage: 8.0)
    let secondShow = TVShow.stub(id: 2, name: "Dragon Ball Z 🔥", voteAverage: 9.0)
    let thirdShow = TVShow.stub(id: 3, name: "Este es un TVShow con un nombre muy largo que fue creado con fines de Test🚨", voteAverage: 10.0)  
    lazy var firstPage = TVShowResult.stub(page: 1,
                                           results: [firstShow, secondShow],
                                           totalResults: 3,
                                           totalPages: 2)
  
    lazy var secondPage = TVShowResult.stub(page: 2,
                                            results: [thirdShow],
                                            totalResults: 3,
                                            totalPages: 2)
  
    let emptyPage = TVShowResult.stub(page: 1, results: [], totalResults: 0, totalPages: 1)
  
    override func setUp() {
      super.setUp()
      self.recordMode = true
    }

    func test_WhenViewPopulated_thenShowPopulatedScreen() {
    
      let totalCells = (self.firstPage.results + self.secondPage.results)
        .map { TVShowCellViewModel(show: $0) }
    
      // given
      let viewModel = PopularViewModelMock(state: .populated(totalCells) )
      let viewController = PopularsViewController.create(with: viewModel)
    
      FBSnapshotVerifyView(viewController.view)
    }
  }
```



Result:
// TODO, insert Image here 

What if an error happens, and if the view is loading a next page? And if the service does not return any element?
```swift
  func test_WhenViewPaging_thenShowPagingScreen() {
    let firsPageCells = firstPage.results!.map { TVShowCellViewModel(show: $0) }
    
    // given
    let viewModel = PopularViewModelMock(state: .paging(firsPageCells, next: 2) )
    let viewController = PopularsViewController.create(with: viewModel)
    
    FBSnapshotVerifyView(viewController.view)
  }
 
  func test_WhenViewIsEmpty_thenShowEmptyScreen() {
    // given
    let viewModel = PopularViewModelMock(state: .empty)
    let viewController = PopularsViewController.create(with: viewModel)
    
    FBSnapshotVerifyView(viewController.view)
  }
  
  func test_WhenViewIsError_thenShowErrorScreen() {
    // given
    let viewModel = PopularViewModelMock(state: .error("Error to Fetch Shows") )
    let viewController = PopularsViewController.create(with: viewModel)
    
    FBSnapshotVerifyView(viewController.view)
  }
```

// TODO, inser Image here

The first time I generate the snapshots, I must execute the tests with the variable recordMode = true:

```swift
  override func setUp() {
    super.setUp()
    self.recordMode = true
  }
```

To verify the snapshots I run again with the recordMode variable set to false or commented:
// TODO, insert Image

### What if the UI is modified?
What happens for example that the rendering of the table is modified and some field is omitted or modified. 
I purposely modify the name of the TVShow and the color of a label in the cell.

In this case our tests begin to fail:
In the reference folder it generates 3 files for each failed test:

It generates the Original Image that serves as a reference, the new snapshot created and the difference between them.

Using this framework, you can instantly see exactly what is going on just by looking at the capture.

// TODO, insert 3 images here



## Summary
I hope you start using Snapshot test, it seems to me a powerful tool to start testing our ViewControllers and Views.

It allows us to reduce the possibility of introducing unexpected changes within the code, which is huge for business.

Snapshot tests are also useful during the development stage. It is much easier to prepare snapshots for all devices and cases than to run each configuration in a simulator.

## References:
- [https://github.com/uber/ios-snapshot-test-case](https://github.com/uber/ios-snapshot-test-case)
- [https://www.objc.io/issues/1-view-controllers/testing-view-controllers/](https://www.objc.io/issues/1-view-controllers/testing-view-controllers/)
- [https://www.raywenderlich.com/5043-ios-snapshot-test-case-testing-the-ui](https://www.raywenderlich.com/5043-ios-snapshot-test-case-testing-the-ui)
- [https://www.vadimbulavin.com/unit-testing-view-controller-uiviewcontroller-and-uiview-in-swift/](https://www.vadimbulavin.com/unit-testing-view-controller-uiviewcontroller-and-uiview-in-swift/)

