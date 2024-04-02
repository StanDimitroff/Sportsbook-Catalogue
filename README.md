# Sportsbook-Catalogue

## Solution

The application is built respecting modular design and SOLID principles:
* `CatalogueCore` module consists all the business models and rules. It is compiled as a platform-agnostic framework that can be reused in another application-specific target - iOS, and macOS. It also contains fast and reliable unit tests for the main components. Because it is a macOS target the tests are executed on the Mac and there is no need to instantiate simulators.
* `CatalogueiOS` module is an application application-specific target built for iOS and contains all the UI needed for the application. The UI is built in simple MVC.


## Ideas for improvement
* Similar to `LoadSportsUseCaseTests` such tests can be created for `RemoteSportEventsLoader`
* Similar to `SportsViewControllerTests` such tests can be created for `SportEventsViewController`
* `SportCell` and `SportEventCell` configurations can be moved to another component reducing the view controller responsibilities
* All presentation logic could be extracted in a separate component or module which is ui framework-independent ant thus it can be used with SwiftUI as well
* Some code duplications can be extracted in reusable methods
* Test plans can be configured for CI on a remote server (for ex. Github actions)
* Server URL and auth token should not be placed in the code
