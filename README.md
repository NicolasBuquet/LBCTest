# LBCTest
LBC Test Nicolas Buquet

Architecture :

* Network/NBNetwork : interface réseau générale
* Network/AppNetwork : interface applicative réseau (appels API et téléchargement médias) - Utilise NBNetwork

* Data/Model/Item : modèle d'Item gérant aussi la désérialisation JSON -> Struct Item prenant en compte la conversion de date au format ISO8601
* Data/Model/ItemCategory : modèle de Category (désérialisation JSON -> Struct ItemCategory gérée nativement par le protocole Decodable)
* Date/AppData : interface applicative Data s'interfaçant avec AppNetwork pour récupérer les données Category et Item à la demande, et gère aussi le tri des Items (placé ici pour faciliter l'utilisation dans les tests unitaires sans embarquer le ItemListViewController et ses dépendances UI). Singleton AppData.shared

* Controllers/LoadingViewController : écran de chargement attendant la disponibilité des données Category et Item avant de passer au controleur suivant
* Controllers/ItemsViewController : écran de présentation des annonces prenant en compte un filtre éventuel. Dépendances principales sur AppData, Views/ItemListCell, Views/FilterPane, ItemDetailViewController. utilise une UICollectionView pour afficher ses éléments plutôt qu'une UITableView pour faciliter l'adaptation éventuelle de l'interface sur iPad (affichage sous forme de Cards plutôt que lignes en modifiant le Layout et les Cells utilisées). Affiche FilterPane en animation à l'appui sur le bouton 'Filtre' placé dans la navigationBar. Bloque l'interactivité de l'écran principal quand le FilterPane est affiché.
* Controllers/ItemDetailViewController : écran de présentation d'une annonce

* Views/UI : paramètres globaux d'UI
* Views/Badge : UI Badge (UILabel custom) utilisé sur ItemsViewController, ItemDetailViewController et FilterPane
* Views/ItemListCell : affichage de la preview d'une annonce dans ItemsViewController
* Views/FilterPane : View d'affichage et sélection de catégorie, utilisée en animation par ItemsViewController. Callback de sélection paramétrable à l'appel.

* Utils/AppBaseViewController : UIViewController de base pour les ViewController de l'application. Permet de customiser de manière globale ces dernier pour toute l'application et de centraliser certains comportements.
* Utils/AppNavigationController : UINavigationController subclass pour paramétrer l'apparence et le comportement
* Utils/UIlabel+Extension : UILabel custom init
* Utils/UIView+Extension : UIView helpers
* Utils/String+Extension : String helpers (calcul de la taille à l'affichage)
* Utils/Float+Extension : Float helpers (Float -> local price string)

* AppDelegate : AppDelegate sans SceneDelegate pour être compatible iOS 11+

Améliorations possibles :
  - gérer un cache au niveau de AppNetwork pour stocker localement et de manière persistante les médias en se basant sur l'url comme clé.
  - adopter un layout de type grille et cards sur la liste des annonces sur iPad (d'où le choix d'une UICollectionView plutôt qu'une UITableView).
  - plus de documentation dans le code en passant plus de temps.
  - plus de tests unitaires et tests unitaires sur l'UI.
  - filtre sur les prix.
  - ordre de tri.
  - sauvegarde des choix utilisateurs pour qu'ils soient persistants à travers les sessions.
  - améliorer le design de la vue des filtres (Popover)
  - et bien d'autres… :-)

Développé sur MacBook Pro 15" 2016, macOS 10.15.5, Xcode 12.2 (12B45b)

Testé sur iPhone 12 mini (iOS 14.2.1), iPad Pro 10.5 (iPadOs 13.6.1), iPhone SE 2016 (iOS 14.3) (optimisations UI à prévoir), iPhone 6 (iOS 12.5) et simulateurs.
