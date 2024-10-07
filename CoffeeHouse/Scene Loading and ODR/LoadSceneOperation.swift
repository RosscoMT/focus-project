import SpriteKit
import Engine
import GameplayKit

class LoadSceneOperation: NSObject {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    let sceneMetadata: SceneMetadata
    
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    init(sceneMetadata: SceneMetadata) {
        self.sceneMetadata = sceneMetadata
        super.init()
    }
    
    
    func initalizeScene<T: BaseScene>() -> Result<T, GameErrors> {
        
        // Access the main root node by loading from GKScene(fileNamed:)
        if let sceneData: GKScene = GKScene(fileNamed: sceneMetadata.fileName) {
            
            // Handle the GKScene root node as a generic, to allow access to assets....
            if let sceneNode = sceneData.rootNode as? T {
                
                // Copy gameplay related content over to the scene - (Entities and graphs are found within the GKScene)
                sceneNode.entities = Set(sceneData.entities)
                sceneNode.graphs = sceneData.graphs
                
                // Set up the scene's camera and native size.
                sceneNode.createCamera()
                
                return .success(sceneNode)
            }
        } else {
            return .failure(.sceneFile)
        }
        
        return .failure(.sceneFile)
    }
}
