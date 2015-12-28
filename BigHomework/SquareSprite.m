//
//  SquareSprite.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "SquareSprite.h"

@implementation SquareSprite

@synthesize squareType, toBeRemove, generateSignal, canMerge, canMove, isUsing, isSpecial, generateSpecial;

+(id) createSquare
{
    return [[[self alloc] initWithDefaultType] autorelease];
}

-(id) initWithDefaultType
{
    toBeRemove = NO;
    generateSignal = NO;
    isUsing = NO;
    generateSpecial = NO;
    
    if (self = [super init]) {
        [self setType:FoodSquare canMove:YES isSpecial:NO];
    }
    return self;
}

-(void) setType:(SquareTypes)type canMove:(BOOL)move isSpecial:(BOOL)special
{
    squareType = type;
    canMove = move;
    canMerge = YES;
    isSpecial = special;
    
    NSString* frameName;
    switch (type) {
        case FoodSquare:
            if (move && !special) {
                frameName = @"square-food.png";
            }else if (move && special){
                frameName = @"special-food.png";
            }else if (!move && !special){
                frameName = @"frozen-food.png";
            }else if (!move && special){
                frameName = @"frozen-special-food.png";
            }
            break;
        case Watersquare:
            if (move && !special) {
                frameName = @"square-water.png";
            }else if (move && special){
                frameName = @"special-water.png";
            }else if (!move && !special){
                frameName = @"frozen-water.png";
            }else if (!move && special){
                frameName = @"frozen-special-water.png";
            }
            break;
        case Electriciysquare:
            if (move && !special) {
                frameName = @"square-electricity.png";
            }else if (move && special){
                frameName = @"special-electricity.png";
            }else if (!move && !special){
                frameName = @"frozen-electricity.png";
            }else if (!move && special){
                frameName = @"frozen-special-electricity.png";
            }
            break;
        case SignalSquare:
            if (move) {
                frameName = @"square-signal.png";
            }else {
                frameName = @"frozen-signal.png";
            }
            canMerge = NO;
            break;
        case DefenceSquare:
            if (move && !special) {
                frameName = @"square-defence.png";
            }else if (move && special){
                frameName = @"special-defence.png";
            }else if (!move && !special){
                frameName = @"frozen-defence.png";
            }else if (!move && special){
                frameName = @"frozen-special-defence.png";
            }
            break;
        case HeatSquare:
            if (move && !special) {
                frameName = @"square-heat.png";
            }else if (move && special){
                frameName = @"special-heat.png";
            }else if (!move && !special){
                frameName = @"frozen-heat.png";
            }else if (!move && special){
                frameName = @"frozen-special-heat.png";
            }
            break;
        default:
            [NSException exceptionWithName:@"Square exception!" reason:@"Unhandled square type" userInfo:nil];
            break;
    }
    self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

@end