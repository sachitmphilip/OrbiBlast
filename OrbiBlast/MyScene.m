//
//  MyScene.m
//  OrbiBlast
//
//  Created by enterpi on 9/11/14.
//  Copyright (c) 2014 enterpi. All rights reserved.
//

#import "MyScene.h"
#import "CGVector+TC.h"
#import "ORBMenuScene.h"

enum {
    CollisionPlayer = 1<<1,
    CollisionEnemy = 1<<2,
};



@implementation MyScene
{
    BOOL _dead;
    SKNode *_player;
    NSMutableArray *_enemies;
    SKLabelNode * _scoreLabel;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        
        self.physicsWorld.gravity  = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        _enemies = [NSMutableArray new];
        
        
        
        _player = [SKNode node];
        SKShapeNode *circle = [SKShapeNode node];
        circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-10, -10, 20, 20)].CGPath;
        circle.fillColor = [UIColor blueColor];
        circle.strokeColor  =[UIColor blueColor];
        circle.glowWidth = 5;
      
        
        SKEmitterNode *trail = [SKEmitterNode orb_emitterNamed:@"Trail"];
        trail.targetNode = self;
        trail.position = CGPointMake(CGRectGetMidX(circle.frame), CGRectGetMidY(circle.frame));
        
        
        
        
        
        
        
        _player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        _player.physicsBody.mass = 100000;
        _player.physicsBody.categoryBitMask = CollisionPlayer;
        _player.physicsBody.contactTestBitMask = CollisionEnemy;

        
        
        
        
        
        [_player addChild: trail];
        
        
        
        
        
        _player.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:_player];
                              
        
        
        
        
          }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    [self performSelector:@selector(spawnEnemy) withObject:nil afterDelay:1.0];
}
-(void)spawnEnemy
{
    SKNode *enemy = [SKNode node];
    
    SKEmitterNode *trail = [SKEmitterNode orb_emitterNamed:@"Trail"];
    trail.targetNode = self;
    trail.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[
                [SKColor redColor],
                [SKColor colorWithHue:0.1 saturation:.5 brightness:1 alpha:1],
                [SKColor redColor],] times:@[@0, @0.02, @0.2]];
    trail.particleScale /= 2;
    trail.position = CGPointMake(10, 10);
    [enemy addChild:trail];
    
    CGFloat radius = MAX(self.size.height, self.size.width)/2;
    CGFloat angle = (arc4random_uniform(1000)/1000.) * M_PI*2;
    CGPoint p = CGPointMake(cos(angle)*radius, sin(angle)*radius);
    enemy.position = CGPointMake(self.size.width/2 + p.x, self.size.width/2 + p.y);
    
    enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6];
    enemy.physicsBody.categoryBitMask = CollisionEnemy;
    enemy.physicsBody.allowsRotation = NO;
    
    [_enemies addObject:enemy];
    [self addChild:enemy];
    
    [self runAction:[SKAction playSoundFileNamed:@"Spawn.wav" waitForCompletion:NO]];
    
    
    
    if (!_scoreLabel)
    {
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
        _scoreLabel.fontSize = 200;
        _scoreLabel.position =CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        _scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.5];
        [self addChild:_scoreLabel];
    }
    
    _scoreLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)_enemies.count];
    
    
    // Next spawn
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:5],
                                         [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
                                         ]]];
}


- (void)dieFrom:(SKNode*)killingEnemy
{ _dead = YES;
    
    SKEmitterNode *explosion = [SKEmitterNode orb_emitterNamed:@"Explosion"];
    explosion.position = _player.position;
    [self addChild:explosion];
    [explosion runAction:[SKAction sequence:@[
                                              [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO],
                                              [SKAction waitForDuration:0.4],
                                              [SKAction runBlock:^{
        // TODO: Remove these more nicely
        [killingEnemy removeFromParent];
        [_player removeFromParent];
    }],
                                              [SKAction waitForDuration:0.4],
                                              [SKAction runBlock:^{
        explosion.particleBirthRate = 0;
    }],
                                              [SKAction waitForDuration:1.2],
                                              
                                              [SKAction runBlock:^{
       ORBMenuScene *menu = [[ORBMenuScene alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
    }],
                                              ]]];

}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player runAction:[SKAction moveTo:[[touches anyObject]locationInNode:self] duration:0.1]];
}
-(void)update:(NSTimeInterval)currentTime
{
    
    CGPoint playerPos = _player.position;
    
    for(SKNode *enemyNode in _enemies) {
        CGPoint enemyPos = enemyNode.position;
        
        /* Uniform speed: */
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector normalized = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(normalized, 4);
        
        /*
         Inversely proportional:
         CGVector diff = TCVectorMinus(playerPos, enemyPos);
         CGVector normalized = TCVectorUnit(diff);
         CGVector force = TCVectorMultiply(normalized, 1/sqrt(TCVectorLength(diff))*40);
         */
        
        /* Inverse square root
         CGVector diff = TCVectorMinus(playerPos, enemyPos);
         CGVector normalized = TCVectorUnit(diff);
         CGVector force = TCVectorMultiply(normalized, 1/sqrt(TCVectorLength(diff))*40);
         */
        
        [enemyNode.physicsBody applyForce:force];
    }
    
    _player.physicsBody.velocity = CGVectorMake(0, 0);
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if(_dead)
        return;
    
    [self dieFrom:contact.bodyB.node];
    contact.bodyB.node.physicsBody = nil;
}

@end


@implementation SKEmitterNode (fromFile)


+(instancetype)orb_emitterNamed:(NSString *)name
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:name ofType:@"sks"]];
}














































@end
