//
//  ORBMenuScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-01.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBMenuScene.h"
#import "MyScene.h"

@implementation ORBMenuScene
- (instancetype)initWithSize:(CGSize)size
{
    
    
    
    if(self = [super initWithSize:size]) {
        SKEmitterNode *background = [SKEmitterNode orb_emitterNamed:@"Background"];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
            [background advanceSimulationTime:10];
        
        [self addChild:background];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        title.text = @"Orbi Blast";
        title.fontSize = 60;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        title.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:1.0];
        
        [self addChild:title];
        
        SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        tapToPlay.text = @"Tap to play";
        tapToPlay.fontSize = 40;
        tapToPlay.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) - 80);
        tapToPlay.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.7];
        
        [self addChild:tapToPlay];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   MyScene *game = [[MyScene alloc] initWithSize:self.size];
    [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
}
@end
