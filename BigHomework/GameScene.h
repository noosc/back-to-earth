//
//  GameScene.h
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "cocos2d.h"

@interface GameScene : CCLayer
{
    
}

+(CCScene *) scene;
+(CGPoint) locationFromTouch:(UITouch*)touch;
@end