import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Vars & Lets
    var window: UIWindow?
    var rootController: CoordinatorNavigationController {
        return self.window!.rootViewController as! CoordinatorNavigationController
    }
    private lazy var dependencyConatiner = DependencyContainer(rootController: self.rootController)
    

  // MARK: - Application lifecycle
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.dependencyConatiner.start()
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
 
