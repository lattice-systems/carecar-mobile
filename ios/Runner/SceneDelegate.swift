import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // V2-M22.06: iOS toma la imagen del selector de apps al pasar a inactiva. La
  // capa de Flutter llega tarde a veces, asi que aqui se cubre la ventana con
  // una vista opaca nativa (sin canal ni dependencias).
  private var cubierta: UIView?

  override func sceneWillResignActive(_ scene: UIScene) {
    if let ventana = (scene as? UIWindowScene)?.windows.first, cubierta == nil {
      let vista = UIView(frame: ventana.bounds)
      vista.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      vista.backgroundColor = .systemBackground
      ventana.addSubview(vista)
      cubierta = vista
    }
    super.sceneWillResignActive(scene)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    cubierta?.removeFromSuperview()
    cubierta = nil
    super.sceneDidBecomeActive(scene)
  }
}
