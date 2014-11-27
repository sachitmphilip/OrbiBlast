//
//  MyScene.h
//  OrbiBlast
//

//  Copyright (c) 2014 enterpi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate>


@end


@interface SKEmitterNode (fromFile)
+ (instancetype)orb_emitterNamed:(NSString*)name;


@end
