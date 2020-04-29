import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var coordinator: MainCoordinator?
    var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let navController = UINavigationController()
    coordinator = MainCoordinator(navigationController: navController)
    coordinator?.start()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
    self.setupGlobalAppearance()
    return true
  }
  
  //MARK: Appearance
  func setupGlobalAppearance() {
      let customFont = UIFont.appRegularFontWith(size: 17)
      UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
      UITextField.appearance().substituteFontName = Config.Font.type.sourceLight
      UILabel.appearance().substituteFontName = Config.Font.type.sourceLight
      UILabel.appearance().substituteFontNameBold = Config.Font.type.sourceLight
  }
}
 
