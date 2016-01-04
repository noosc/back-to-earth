//
//  GameScene.h
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "cocos2d.h"
#import "SquareCache.h"

@interface GameScene : CCLayer
{
    SquareCache* squareCache;
}

+(CCScene *) scene;
+(CGPoint) locationFromTouch:(UITouch*)touch;
@end