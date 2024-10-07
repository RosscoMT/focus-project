#  CoffeeHouse 


Spritekit Notes

* Always use copy() on the sprite you want to use from a scene file. As failure to do so will cause crash.
* To avoid difficulty in adding new elements to a camera node use xScale x 1 and yScale 1 either in code or from the sky file. As sizing and positioning will be incorrect and difficult to resolve.
* Remember to correct nodes positioning when the scene updates as the sprite will drift away from its set location with window resizing.
* Remember to use xScale and yScale when updating it's size.
* didChangeSize will be called twice per window resize call. Use override var size: CGSize - if you want to receive only 1 call. *There is a bug where the original scale of a recently updated sprite will appear in the console ie. original xScale 1.2 with the updated value of 4.6. The effect is 1.2, 4.6, 1.2, 4.6 can result in views failing to correctly scale in one direction ie left or right.
* When changing the scaling of the sprite, you must use the original sizing against the new. As using the current sprite size against the new window size will only show the small difference between them not the overall. ie Screen width 928px and Menu width 923px will appear as 1.0043594… where as the original 200px calculates as 4.64. The system is constantly scaling the sprite from the initial size not the last set size.

Positioning
* If are using NSEvent such as mouse location use and want to find if there is a node at that location use - func location(in node: SKNode) -> CGPoint example: event.location(in: self.camera!)

Physics 

* The character must be set to false for dynamic as we do not want the character to be moved by the furniture.
* Remember collisions reported by didBegin(_ contact: SKPhysicsContact) are a single value encapsulating two properties bodyA and bodyB. But their combined values are unique ie player + wall, player + obstacle… when checking contacts you need used bitwise OR operator (A | B) ie contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

Lighting

* Even the camera needs a higher zPosition to avoid lighting and shadows. As it’s zPosition may fall in line with light node.

Intelligence - Rendering

* An entity requires a state machine with a state to keep it shown on screen drawing per cycle - ie if you want an idle state the state machine for the entity must be called constantly from the update(deltaTime seconds: TimeInterval)

Bitwise 

* Bitwise OR operator (A | B) combines the values into one or more numbers ie A + B.... - used for binary numbers (Don’t think of swift | | which is a OR statement)

Entity vs SKSpriteNode

* Because a GameplayKit entity is not a SpriteKit sprite node, and therefore does not include a visual representation of itself 

Extensions

* Extensions are generally preferred as they tend to be more reusable than helper methods that can easily get buried within the underbelly of your code 


Start up process

- Any level which needs resources such as textures, plists, sound etc should use the ResourceLoadableType with their respective class name added to the SceneConfiguration > Scene > loadableTypes 

- Access to platform specific user inputs ie mouseDown comes from either compiler directives #if or target membership or scheme

NOTES:

- More child layers within layer equals more writes regardless of the z positioning

// REWRITE THE DESTINATION POINT WHERE THE BOT STANDS IN FRONT OF THE TILL - CONTINUE WITH ANY OTHER DESTINATION CHECKS

Recorded fails:

FAIL (1826.0245361328125, -513.2979125976562)
FAIL (1826.0245361328125, -513.2979125976562)
FAIL (377.3360290527344, -562.7069091796875)
FAIL (698.2777099609375, -330.8700866699219)

// ISSUES
- If character get stuck we need to help release him
- If character becomes stuck in wander we need to revolve there issue (delete or reassign information)
- Long press bug with many taps on furniture item
- Multiplatform issues - needs testing and fixing

- Consider creating debug tool for tapping on NPC to reveal their navigation path

ADD PAUSE FUNCTIONALITY TO THE GAME

TEST THE PAUSE FUNCTIONALITY
  
     
Rule component

GOAL:

We want to cycle through the Mandate Cycle tasks in order
 
var currentMandate - The current instruction being carried out by the bot
var mandateTasks - The core series of instructions a bot should follow

Notes:

- It will control the currentMandate per entity

- enterScene - Simply instructs bot to spawn and move into the scene
- queue - Move to till - (Is there a queue?, Y - You will need use different behaviour, N - Move till point)
- served - Move to area for collecting coffee
- walkTo - Move to table for consumption (Is there any tables available? Y - Move to the table, N - Use wander behaviour)
- consumeSitting - Consuming at table
- leave - Bot plots path and leaves the store (Can bot leave? Y - Leave the scene, N - Use wander behaviour and try again shortly)

BOT Rules

- NextMandateIsAvailable - else use this
- IsNotStuck


Mandate Cycle
- enterScene
- queue
- served
- walkTo
- wait ** - Fallback rule
- leave
- wander ** - Fallback rule

