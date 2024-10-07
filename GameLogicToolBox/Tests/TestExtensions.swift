//
//  TestExtensions.swift
//  
//
//  Created by Ross Viviani on 21/04/2023.
//

import XCTest
import SpriteKit
import Engine
import Foundation
import GameplayKit

@testable import Engine

final class TestExtensions: XCTestCase {
    
    struct TestConfigurationModel: Decodable {
        let fileName: String
        let sceneType: String
        let required: Bool
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    // Tests CGPoint conversion to a vectorFloatPoint
    func testCGPointToVectorFloatPoint() throws {
       
        let point: CGPoint = CGPoint(x: 239, y: 888)
        let convertedPoint: vector_float2 = point.vectorFloatPoint()
        
        XCTAssertEqual(point.x, CGFloat(convertedPoint.x))
        XCTAssertEqual(point.y, CGFloat(convertedPoint.y))
    }
    
    // Test generic decoding of data objects
    func testDecodePlistData() throws {
 
        guard let url: URL = Bundle.module.url(forResource: "TestConfiguration", withExtension: "plist") else {
            throw GameErrors.locateFile
        }
        
        do {
            let sut: [TestConfigurationModel] = try Data.decodePlistData(url: url)
            
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(sut.first?.fileName, "ExampleScene")
            XCTAssertEqual(sut.first?.sceneType, "TestScene")
            XCTAssertEqual(sut.first?.required, true)
        } catch {
            throw GameErrors.decodeFailed
        }
    }
    
    // Test SIMD2<Float> to CGPoint conversion
    func testSIMDPointConversion() {
       
        let sut = SIMD2.init(x: Float(452.23), y: Float(873.12))
        let point = CGPoint.init(sut)
        
        XCTAssertEqual(CGFloat(sut.x), point.x)
        XCTAssertEqual(CGFloat(sut.y), point.y)
    }
    
    // Test SIMD2<Float> to CGPoint conversion
    func testCGPointConversion() {
        
        let sut = CGPoint(x: 234.44, y: 382.33)
        let point = SIMD2.init(sut)

        // Round the SIMD2 due to long decimal return value
        XCTAssertEqual(sut.x, round(CGFloat(point.x * 1000)) / 1000)
        XCTAssertEqual(sut.y, round(CGFloat(point.y * 1000)) / 1000)
    }
    
    // Test the adding of components
    func testAddComponents() {
        
        let sut = GKEntity()
        
        let componentOne = SampleComponentOne()
        let componentTwo = SampleComponentTwo()
        let componentThree = SampleComponentThree()
        let componentFour = SampleComponentFour()
        
        sut.addComponents([componentOne, componentTwo, componentThree, componentFour])
        
        XCTAssertTrue(sut.components.contains(componentOne))
        XCTAssertTrue(sut.components.contains(componentTwo))
        XCTAssertTrue(sut.components.contains(componentThree))
        XCTAssertTrue(sut.components.contains(componentFour))
        
        XCTAssertEqual(sut.components.count, 4)
    }
    
    // Test the vector float to CGPoint and rounding
    func testVectorFloatToCGPoint() {
        
        let sut = vector_float2(x: 23210.0111, y: 1123.22232)
        let point = sut.point()
        
        XCTAssertEqual(point.x, 23210.0)
        XCTAssertEqual(point.y, 1123.0)
    }
    
    // Test the setting the camera constraints
    func testSetCameraConstraints() {
        
        let camera: SKCameraNode = .init()
        let testBoard = SKSpriteNode(color: .brown, size: .init(width: 2272.84, height: 1449.72))
        let player = SKSpriteNode(color: .yellow, size: .init(width: 120, height: 120))
        testBoard.addChild(player)
        player.position = .init(x: 2209.68798828125, y: 320.0)
        
        camera.setCameraConstraints(data: .init(board: testBoard, node: player, size: .init(width: 700.0, height: 525.0)), config: .init(cameraEdgeBounds: 100))
        
        XCTAssertEqual(camera.constraints?.count, 2)
    }
    
    // Test the magnify the scene
    func testMagnifyScene() {
        
        let gesture: NSMagnificationGestureRecognizer = .init()
        gesture.magnification = 0.1865234375
        let sut: SKCameraNode = .init()
        sut.magnifyScene(gesture, config: ["zoomRate" : 0.3, "minimumZoom" : 0.5, "maximumZoom" : 2.5])
        XCTAssertEqual(sut.xScale, 0.6217448115348816)
    }
    
    // Test the adding multiple child nodes
    func testAddChildNode() {
        
        let sutOne = SKSpriteNode(color: .clear, size: .init(width: 100, height: 100))
        let sutTwo = SKSpriteNode(color: .clear, size: .init(width: 100, height: 100))
        let sutThree = SKSpriteNode(color: .clear, size: .init(width: 100, height: 100))
        
        let container = SKSpriteNode(color: .clear, size: .init(width: 100, height: 100))
        container.addChilds([sutOne, sutTwo, sutThree])
        
        XCTAssertEqual(container.children.contains(sutOne), true)
        XCTAssertEqual(container.children.contains(sutTwo), true)
        XCTAssertEqual(container.children.contains(sutThree), true)
        XCTAssertEqual(container.children.count, 3)
    }
    
    // Test when a node intersects its destination
    func testContactsThreshold() {
        
        let sut = SKSpriteNode(color: .clear, size: .init(width: 100, height: 100))
        sut.position = .zero
        
        let destination = SKSpriteNode(color: .clear, size: .init(width: 50, height: 300))
        destination.position = .init(x: 40, y: 40)
        
        let answer = sut.contactsThreshold(destination: destination, size: 30)
        XCTAssertTrue(answer)
    }
    
    // Test the search of a child node
    func testChildNodeWithNameAndPath() {
        
        let sut = SKNode()
        
        let world = SKNode()
        world.name = Nodes.world.rawValue
        
        let characters = SKNode()
        characters.name = Nodes.characters.rawValue
        
        let spawnCharacter = SKNode()
        spawnCharacter.name = Nodes.playerSpawnLocation.rawValue
        
        sut.addChild(world)
        world.addChild(characters)
        characters.addChild(spawnCharacter)
        
        let characterNode = sut.childNode(name: Nodes.characters, baseExtension: "//world")
        let spawnLocation = characterNode?.childNode(name: Nodes.playerSpawnLocation)
        
        XCTAssertEqual(characterNode, characters)
        XCTAssertEqual(spawnLocation, spawnCharacter)
    }
    
    // Test the retrieval of a child node through search
    func testCentrePoint() {
        
        let container: SKSpriteNode = .init(color: .blue, size: .init(width: 3500, height: 1222))
        
        let node: SKSpriteNode = .init(color: .blue, size: .init(width: 346, height: 455))
        container.addChild(node)
        node.anchorPoint = .zero
        node.position = .init(x: 54, y: 188)
        
        XCTAssertEqual(node.centrePoint(), .init(x: 227.0, y: 415.5))
    }
    
    // Test for animation is active
    func testAnimationActive() {
   
        let node: SKSpriteNode = .init(color: .blue, size: .init(width: 346, height: 455))
        node.run(.moveTo(x: 10000, duration: 60), withKey: "Moving")
 
        XCTAssertEqual(node.animationActive(animationKey: "Moving"), true)
    }
    
    // Test if node is attached to a scene
    func testAttachedToScene() {
        
        let scene = SKScene(size: .init(width: 1500, height: 4000))
        let node: SKSpriteNode = .init(color: .blue, size: .init(width: 346, height: 455))
        scene.addChild(node)
        
        XCTAssertEqual(node.attachedToScene(), true)
    }
    
    // Test the filtering of nodes from a scene
    func testFilterNodes() {
        
        let scene = SKScene(size: .init(width: 1500, height: 4000))
        
        let world = SKNode()
        world.name = Nodes.world.rawValue
        
        let characters = SKNode()
        characters.name = Nodes.characters.rawValue
        
        let spawnCharacterOne = SKNode()
        spawnCharacterOne.name = Nodes.playerSpawnLocation.rawValue
        
        let spawnCharacterTwo = SKNode()
        spawnCharacterTwo.name = Nodes.playerSpawnLocation.rawValue
        
        let spawnCharacterThree = SKNode()
        spawnCharacterThree.name = Nodes.playerSpawnLocation.rawValue
        
        let spawnCharacterFour = SKNode()
        spawnCharacterFour.name = Nodes.playerSpawnLocation.rawValue
        
        let randomOne = SKNode()
        randomOne.name = "randomOne"
        
        let randomTwo = SKNode()
        randomTwo.name = "randomTwo"
        
        let randomThree = SKNode()
        randomThree.name = "randomThree"
        
        scene.addChild(world)
        world.addChild(characters)
        
        characters.addChilds([spawnCharacterOne, spawnCharacterTwo, spawnCharacterThree, spawnCharacterFour, randomOne, randomTwo, randomThree])
        
        let charactersNodes = scene.filteredNodes(path: "world/characters/PlayerSpawnLocation")
        let randomNodes = scene.filteredNodes(path: "world/characters/randomOne")
        
        XCTAssertEqual(charactersNodes.contains(spawnCharacterOne), true)
        XCTAssertEqual(charactersNodes.contains(spawnCharacterTwo), true)
        XCTAssertEqual(charactersNodes.contains(spawnCharacterThree), true)
        XCTAssertEqual(charactersNodes.contains(spawnCharacterFour), true)
        XCTAssertEqual(charactersNodes.count, 4)
        
        XCTAssertEqual(randomNodes.contains(randomOne), true)
        XCTAssertEqual(randomNodes.count, 1)
    }
    
    // Test the capitalising of a string
    func testCaptializeString() {
        let sut = "super"
        XCTAssertEqual(sut.captializeString(), "Super")
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
