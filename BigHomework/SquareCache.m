//
//  SquareCache.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "SquareCache.h"
#import "SquareSprite.h"
#import "GameScene.h"
#import "LoseScene.h"
#import "WinScene.h"
#import "SimpleAudioEngine.h"

@implementation SquareCache
@synthesize boundingBox;

static const int numSquare = 128;
static const int matrixSize = 8;

-(id) init
{
    if (self = [super init]) {
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"square.plist"];
        CCTexture2D* gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:@"square.png"];
        batch = [CCSpriteBatchNode batchNodeWithTexture:gameArtTexture];
        
        CCSprite* outFrame = [CCSprite spriteWithSpriteFrameName:@"outframe.png"];
        [batch addChild:outFrame z:-1];
        [self addChild:batch];
        
        isAnimating = YES;
        isTouchEnable = NO;
        isInit = YES;
        isRemoving = NO;
        frozen = NO;
        needFill = NO;
        gameOver = NO;
        win = NO;
        needReset = NO;
        squareSrc = ccp(-1, -1);
        squareDest = ccp(-1, -1);
        
        time = 180;
        temperature = 5;
        electricity = 0;
        signal = 0;
        timeMax = 180;
        temperatureMax = 5;
        electricityMax = 51;
        
        delay = 1;
        
        squares = [[CCArray alloc] initWithCapacity:numSquare];
        for (int i = 0; i < numSquare; i++) {
            SquareSprite* square = [SquareSprite createSquare];
            square.visible = NO;
            [batch addChild:square z:1 tag:i];
            [squares addObject:square];
        }
        
        matrix = [[CCArray alloc] initWithCapacity:matrixSize];
        for (int i = 0; i < matrixSize; i++) {
            CCArray* column = [CCArray arrayWithCapacity:matrixSize];
            [matrix addObject:column];
        }
        
        //recycle container
        removing = [[CCArray alloc] initWithCapacity:15];
        usedSprites = [[CCArray alloc] initWithCapacity:5];
        signalStars = [[CCArray alloc] initWithCapacity:5];
        timeStars = [[CCArray alloc] initWithCapacity:5];
        
        //remove entire line animation
        lineSprites = [[CCArray alloc] initWithCapacity:numSquare];
        for (int i = 0; i < numSquare; i++) {
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"hleft.png"];
            sprite.visible = NO;
            [lineSprites addObject:sprite];
            [batch addChild:sprite z:11];
        }
        [self resetSquares];
        
        //ices
        ices = [[CCArray alloc] initWithCapacity:matrixSize * matrixSize];
        for (int i = 0; i < matrixSize * matrixSize; i++) {
            CCSprite* ice = [CCSprite spriteWithSpriteFrameName:@"ice.png"];
            ice.visible = NO;
            ice.anchorPoint = ccp(0, 0);
            [ices addObject:ice];
        }
        
        //stars
        stars = [[CCArray alloc] initWithCapacity:matrixSize * matrixSize];
        for (int i = 0; i < matrixSize * matrixSize; i++) {
            CCSprite* star = [CCSprite spriteWithSpriteFrameName:@"star.png"];
            star.visible = NO;
            [stars addObject:star];
            [batch addChild:star z:13];
        }
        
        //streaks
        streaks = [[CCArray alloc] initWithCapacity:matrixSize * matrixSize];
        for (int i = 0; i < matrixSize * matrixSize; i++) {
            CCMotionStreak* streak = [CCMotionStreak streakWithFade:0.5 minSeg:10 width:3 color:ccWHITE textureFilename:@"star.png"];
            [streaks addObject:streak];
            [self addChild:streak z:5];
        }
        
        //mask
        mask = [CCSprite spriteWithSpriteFrameName:@"mask.png"];
        mask.position = ccp(0, 124);
        [batch addChild:mask z:12];
        
        //astronaut
        astronaut = [CCSprite spriteWithSpriteFrameName:@"astronaut.png"];
        astronaut.position = ccp(0, 124);
        [self addChild:astronaut z:20];
        
        //status
        status = [CCSprite spriteWithSpriteFrameName:@"status.png"];
        status.position = ccp(0, 124);
        [self addChild:status z:3];
        
        foodLeft = [CCSprite spriteWithSpriteFrameName:@"foodLeft.png"];
        foodLeft.position = ccp(46.5f, 524.7f);
        [status addChild:foodLeft z:4];
        
        foodMiddle = [CCSprite spriteWithSpriteFrameName:@"foodMiddle.png"];
        foodMiddle.position = ccp(46.5f, 524.7f);
        foodMiddle.anchorPoint = ccp(0, 0.5f);
        foodMiddle.scaleX = 1;
        [status addChild:foodMiddle z:3];
        
        foodRight = [CCSprite spriteWithSpriteFrameName:@"foodRight.png"];
        CGPoint position = foodMiddle.position;
        position.x += foodMiddle.contentSize.width * foodMiddle.scaleX;
        foodRight.anchorPoint = ccp(0.3f, 0.5f);
        foodRight.position = position;
        [status addChild:foodRight z:4];
        
        electricityLeft = [CCSprite spriteWithSpriteFrameName:@"electricityLeft.png"];
        electricityLeft.position = ccp(46.5f, 508.7f);
        electricityLeft.visible = NO;
        [status addChild:electricityLeft z:4];
        
        electricityMiddle = [[CCArray alloc] initWithCapacity:electricityMax];
        for (int i = 0; i < electricityMax; i++) {
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"electricityMiddle.png"];
            sprite.position = ccp(46.5f + i * sprite.contentSize.width, 508.7f);
            sprite.anchorPoint = ccp(0, 0.5f);
            sprite.visible = NO;
            [status addChild:sprite z:5];
            [electricityMiddle addObject:sprite];
        }
        
        electricityRight = [CCSprite spriteWithSpriteFrameName:@"electricityRight.png"];
        electricityRight.anchorPoint = ccp(0.1, 0.5f);
        electricityRight.visible = NO;
        [status addChild:electricityRight z:4];
        
        temperatureLeft = [CCSprite spriteWithSpriteFrameName:@"foodLeft.png"];
        temperatureLeft.position = ccp(46.5f, 492.2f);
        [status addChild:temperatureLeft z:4];
        
        temperatureMiddle = [[CCArray alloc] initWithCapacity:temperatureMax];
        for (int i = 0; i < temperatureMax; i++) {
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"temperatureMiddle.png"];
            sprite.position = ccp(46.5f + i * sprite.contentSize.width, 492.2f);
            sprite.anchorPoint = ccp(0, 0.5f);
            [status addChild:sprite z:3];
            [temperatureMiddle addObject:sprite];
        }
        temperatureRight = [CCSprite spriteWithSpriteFrameName:@"foodRight.png"];
        position = ((CCSprite*)[temperatureMiddle objectAtIndex:temperature -1]).position;
        position.x += ((CCSprite*)[temperatureMiddle objectAtIndex:temperature -1]).contentSize.width;
        temperatureRight.position = position;
        temperatureRight.anchorPoint = ccp(0.3f, 0.5f);
        [status addChild:temperatureRight z:4];
        
        ownSignal = [[CCArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"ownSignal.png"];
            sprite.position = ccp(49.5f + i * 20.5, 467.5f);
            sprite.visible = NO;
            [status addChild:sprite z:3];
            [ownSignal addObject:sprite];
        }
        
        shake = [CCSprite spriteWithSpriteFrameName:@"shake.png"];
        shake.opacity = 0;
        [batch addChild:shake z:20];
        
        [self scheduleUpdate];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

//arrange squares to matrix
-(void) resetSquares
{
    isInit = YES;
    [removing removeAllObjects];
    for (int i = 0; i < numSquare; i++) {
        SquareSprite* square = [squares objectAtIndex:i];
        [square stopAllActions];
        square.visible = NO;
        square.isUsing = NO;
        square.canMove = YES;
        square.toBeRemove = NO;
        square.generateSignal = NO;
        square.generateSpecial = NO;
        square.scale = 1;
        CCSprite* ice = (CCSprite*)[square getChildByTag:@"ice"];
        if (ice != nil) {
            ice.visible = NO;
            [ice removeFromParentAndCleanup:YES];
        }
    }
    for (int j = 0; j < matrixSize; j++) {
        CCArray* column = [matrix objectAtIndex:j];
        [column removeAllObjects];
        for (int i = 0; i < matrixSize; i++) {
            int type = arc4random() % (MAXSquare - 1);
            [self createAtRow:i Column:j WithType:type canMove:YES isSpecial:NO];
        }
    }
    //make sure no 3-sequence at initial time
    while (isInit) {
        [self scanSquares];
    }
    for (int j = 0; j < matrixSize; j++) {
        for (int i = 0; i < matrixSize; i++) {
            [self dropSquareAtRow:i Column:j From:[self positionOfItemAtRow:i + matrixSize Column:j]];
        }
    }
}

-(SquareSprite*) squareAtRow:(int)row Column:(int)column
{
    return (SquareSprite*)[[matrix objectAtIndex:column] objectAtIndex:row];
}


-(CGPoint) locationOfSquare:(SquareSprite*)square
{
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            if ([self squareAtRow:i Column:j] == square) {
                return ccp(i, j);
            }
        }
    }
    return ccp(-1, -1);
}

//return whether there are any 3-squence to be removed
-(BOOL) isAvailable
{
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.canMerge == NO || square.canMove == NO) {
                continue;
            }
            /*    o
                  #   */
            if (i > 0 && [self squareAtRow:i - 1 Column:j].squareType == square.squareType) {
                /*    o
                      #
                      #   */
                if (i > 1 && [self squareAtRow:i - 2 Column:j].squareType == square.squareType) {
                    return YES;
                }
                /*    #
                      o
                      #   */
                if (i < matrixSize - 1 && [self squareAtRow:i + 1 Column:j].squareType == square.squareType) {
                    return YES;
                }
            }
            /*    #
                  #
                  o   */
            if (i < matrixSize - 2 && [self squareAtRow:i + 1 Column:j].squareType == square.squareType && [self squareAtRow:i + 2 Column:j].squareType == square.squareType) {
                return YES;
            }
            //  #o
            if (j > 0 && [self squareAtRow:i Column:j - 1].squareType == square.squareType) {
                //   ##o
                if (j > 1 && [self squareAtRow:i Column:j - 2].squareType == square.squareType) {
                    return YES;
                }
                //   #o#
                if (j < matrixSize - 1 && [self squareAtRow:i Column:j + 1].squareType == square.squareType) {
                    return YES;
                }
            }
            //   o##
            if (j < matrixSize - 2 && [self squareAtRow:i Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 2].squareType == square.squareType) {
                return YES;
            }
            
            /*    o
                 #    */
            if (i > 0 && j > 0 && [self squareAtRow:i - 1 Column:j - 1].squareType == square.squareType) {
                /*    o
                     #
                     #    */
                if (i > 1 && [self squareAtRow:i - 2 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
                /*    o
                    ##    */
                if (j > 1 && [self squareAtRow:i - 1 Column:j - 2].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
                /*    o
                     # #  */
                if (j < matrixSize - 1 && [self squareAtRow:i - 1 Column:j + 1].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
            }
            /*   o
                  #  */
            if (i > 0 && j < matrixSize - 1 && [self squareAtRow:i - 1 Column:j + 1].squareType == square.squareType) {
                /*   o
                      #
                      #   */
                if (i > 1 && [self squareAtRow:i - 2 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
                /*   o
                      ##  */
                if (j < matrixSize - 2 && [self squareAtRow:i - 1 Column:j + 2].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
                /*    #
                     o
                      #   */
                if (i < matrixSize - 1 && [self squareAtRow:i + 1 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
            }
            /*    #
                 o    */
            if (i < matrixSize - 1 && j < matrixSize - 1 && [self squareAtRow:i + 1 Column:j + 1].squareType == square.squareType) {
                /*    #
                      #
                     o   */
                if (i < matrixSize - 2 && [self squareAtRow:i + 2 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
                /*    ##
                     o   */
                if (j < matrixSize - 2 && [self squareAtRow:i + 1 Column:j + 2].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
                /*  # #
                     o   */
                if (j > 0 && [self squareAtRow:i + 1 Column:j - 1].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
            }
            /*  #
                 o   */
            if (i < matrixSize - 1 && j > 0 && [self squareAtRow:i + 1 Column:j - 1].squareType == square.squareType) {
                /*  #
                    #
                     o   */
                if (i < matrixSize - 2 && [self squareAtRow:i + 2 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
                /* ##
                     o   */
                if (j > 1 && [self squareAtRow:i + 1 Column:j - 2].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
                /*  #
                     o
                    #    */
                if (i > 0 && [self squareAtRow:i - 1 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
            }
            /*  #
                #
             
                o   */
            if (i < matrixSize - 3 && [self squareAtRow:i + 3 Column:j].squareType == square.squareType && [self squareAtRow:i + 2 Column:j].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                return YES;
            }
            /*  o
             
                #
                #   */
            if (i > 2 && [self squareAtRow:i - 3 Column:j].squareType == square.squareType && [self squareAtRow:i - 2 Column:j].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                return YES;
            }
            //  o ##
            if (j < matrixSize - 3 && [self squareAtRow:i Column:j + 3].squareType == square.squareType && [self squareAtRow:i Column:j + 2].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                return YES;
            }
            //  ## o
            if (j > 2 && [self squareAtRow:i Column:j - 3].squareType == square.squareType && [self squareAtRow:i Column:j - 2].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                return YES;
            }
        }
    }
    return NO;
}

-(void) createAtRow:(int)row Column:(int)column WithType:(SquareTypes)type canMove:(BOOL)move isSpecial:(BOOL)special
{
    SquareSprite* square;
    CCARRAY_FOREACH(squares, square)
    {
        if (square.isUsing == NO) {
            [square setType:type isSpecial:special];
            [[matrix objectAtIndex:column] insertObject:square atIndex:row];
            square.isUsing = YES;
            CCSprite* ice = (CCSprite*)[square getChildByTag:@"ice"];
            if (ice != nil) {
                ice.visible = NO;
                [ice removeFromParentAndCleanup:YES];
            }
            return;
        }
    }
}

-(CCSprite*) generateIce{
    CCSprite* ice;
    CCARRAY_FOREACH(ices, ice)
    {
        if (ice.visible == NO) {
            [ice removeFromParentAndCleanup:YES];
            ice.visible = YES;
            return ice;
        }
    }
    return nil;
}

-(CCSprite*) generateStar{
    CCSprite* star;
    CCARRAY_FOREACH(stars, star)
    {
        if (star.visible == NO) {
            star.visible = YES;
            return star;
        }
    }
    return nil;
}

-(CCSprite*) lineSpriteWithType:(lineTypes)type
{
    CCSprite* sprite;
    CCARRAY_FOREACH(lineSprites, sprite)
    {
        if (sprite.visible == NO) {
            sprite.scale = 1;
            sprite.visible = YES;
            NSString* frameName;
            switch (type) {
                case hleft:
                    frameName = @"hleft.png";
                    break;
                case hright:
                    frameName = @"hright.png";
                    break;
                case vdown:
                    frameName = @"vdown.png";
                    break;
                case vup:
                    frameName = @"vup.png";
                    break;
                    
                default:
                    [NSException exceptionWithName:@"lineSprite exception!" reason:@"Unhandled sprite type" userInfo:nil];
                    break;
            }
            sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            break;
        }
    }
    return sprite;
}

-(void) removeAnimate
{
    if (removing.count == 0 || isRemoving) {
        return;
    }
    isRemoving = YES;
    isAnimating = YES;
    SquareSprite* square;
    CCARRAY_FOREACH(removing, square)
    {
        square.isUsing = YES;
        if (!square.canMove) {
            square.canMove = YES;
            CCSprite* ice = (CCSprite*)[square getChildByTag:@"ice"];
            ice.visible = NO;
            [ice removeFromParentAndCleanup:YES];
        }
        if (square.squareType == SignalSquare) {
            [square runAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, -square.contentSize.height)]];
        }else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"eliminate.mp3"];
            if (square.squareType == DefenceSquare && square.isSpecial){
                [[SimpleAudioEngine sharedEngine] playEffect:@"line.mp3"];
                CCSprite* hl = [self lineSpriteWithType:hleft];
                CCSprite* hr = [self lineSpriteWithType:hright];
                hl.position = square.position;
                hr.position = square.position;
                CGPoint leftEnd = square.position;
                CGPoint rightEnd = square.position;
                leftEnd.x = [self positionOfItemAtRow:0 Column:-8].x;
                rightEnd.x = [self positionOfItemAtRow:0 Column:15].x;
                CCEaseOut* extendLeft = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:8 scaleY:0.7] rate:3];
                CCEaseOut* extendRight = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:8 scaleY:0.7] rate:3];
                CCEaseOut* moveLeft = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:leftEnd] rate:3];
                CCEaseOut* moveRight = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:rightEnd] rate:3];
                [hl runAction:extendLeft];
                [hl runAction:moveLeft];
                [hr runAction:extendRight];
                [hr runAction:moveRight];
                [usedSprites addObject:hl];
                [usedSprites addObject:hr];
            }else if (square.squareType == Watersquare && square.isSpecial){
                [[SimpleAudioEngine sharedEngine] playEffect:@"line.mp3"];
                CCSprite* vd = [self lineSpriteWithType:vdown];
                CCSprite* vu = [self lineSpriteWithType:vup];
                vd.position = square.position;
                vu.position = square.position;
                CGPoint downEnd = square.position;
                CGPoint upEnd = square.position;
                downEnd.y = [self positionOfItemAtRow:-8 Column:0].y;
                upEnd.y = [self positionOfItemAtRow:15 Column:0].y;
                CCEaseOut* extendDown = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:0.7 scaleY:8] rate:3];
                CCEaseOut* extendUp = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:0.7 scaleY:8] rate:3];
                CCEaseOut* moveDown = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:downEnd] rate:3];
                CCEaseOut* moveUp = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:upEnd] rate:3];
                [vd runAction:extendDown];
                [vd runAction:moveDown];
                [vu runAction:extendUp];
                [vu runAction:moveUp];
                [usedSprites addObject:vd];
                [usedSprites addObject:vu];
            }else if (square.squareType == FoodSquare && square.isSpecial){
                CCSprite* star = [self generateStar];
                CGPoint worldTimePosition = [status convertToWorldSpace:foodMiddle.position];
                worldTimePosition.x += foodMiddle.contentSize.width * foodMiddle.scaleX;
                CGPoint worldStarPosition = [batch convertToWorldSpace:square.position];
                star.position = [batch convertToNodeSpace:worldStarPosition];
                [star runAction:[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(worldTimePosition.x - worldStarPosition.x, worldTimePosition.y - worldStarPosition.y)] rate:3]];
                [timeStars addObject:star];
                [[SimpleAudioEngine sharedEngine] playEffect:@"star.mp3"];
            }else if (square.squareType == HeatSquare && square.isSpecial)
            {
                BOOL playSound = NO;
                for (int i = 0; i < matrixSize; i++) {
                    for (int j = 0; j < matrixSize; j++) {
                        SquareSprite* frozenSquare = [self squareAtRow:i Column:j];
                        if (frozenSquare.canMove == NO) {
                            playSound = YES;
                            CCSprite* star = [self generateStar];
                            star.position = square.position;
                            [star runAction:[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.1 position:ccp(frozenSquare.position.x - star.position.x, frozenSquare.position.y - star.position.y)] rate:3]];
                            frozenSquare.canMove = YES;
                            CCSprite* ice = (CCSprite*)[frozenSquare getChildByTag:@"ice"];
                            ice.visible = NO;
                            [ice removeFromParentAndCleanup:YES];
                            CCParticleSystemQuad* sys = [CCParticleSystemQuad particleWithFile:@"remove-ice.plist"];
                            sys.position = frozenSquare.position;
                            sys.autoRemoveOnFinish = YES;
                            [self addChild:sys z:10];
                        }
                    }
                }
                if (playSound) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"biu.mp4"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"icebreak.mp3"];
                }
            }
            [square runAction:[CCScaleTo actionWithDuration:0.2 scale:0]];
            NSString* file = [NSString stringWithFormat:@"remove-%i.plist", square.squareType + 1];
            CCParticleSystemQuad* sys = [CCParticleSystemQuad particleWithFile:file];
            sys.position = square.position;
            sys.autoRemoveOnFinish = YES;
            [self addChild:sys z:10];
        }
    }
}

-(void) dropSquareAtRow:(int)row Column:(int)column From:(CGPoint)startPoint
{
    isAnimating = YES;
    SquareSprite* square = [self squareAtRow:row Column:column];
    CGPoint endPoint = [self positionOfItemAtRow:row Column:column];
    square.position = startPoint;
    square.visible = YES;
    square.scale = 1;
    float duration = 0.1 * (startPoint.y - endPoint.y) / square.contentSize.height + 0.01 * row;
    [square runAction:[CCMoveTo actionWithDuration:duration position:endPoint]];
}

-(CGPoint) positionOfItemAtRow:(int)row Column:(int)column
{
    SquareSprite* square = [squares objectAtIndex:0];
    CGSize squareSize = square.contentSize;
    float x = (column - matrixSize/2 + 0.5f) * squareSize.width;
    float y = (row - matrixSize/2 + 0.5f) * squareSize.height;
    return ccp(x, y);
}

-(CGPoint) existHorizontalChainAt:(int)row Column:(int)column
{
    SquareSprite* square = [self squareAtRow:row Column:column];
    if (!square.canMerge) {
        return ccp(0, 0);
    }
    int left = column;
    while (left > 0) {
        SquareSprite* leftNeighbor = [self squareAtRow:row Column:left - 1];
        if (leftNeighbor.squareType == square.squareType) {
            left--;
        }else{
            break;
        }
    }
    int right = column;
    while (right < matrixSize - 1) {
        SquareSprite* rightNeighbor = [self squareAtRow:row Column:right + 1];
        if (rightNeighbor.squareType == square.squareType) {
            right++;
        }else{
            break;
        }
    }
    return ccp(left, right);
}

-(CGPoint) existVerticalChainAt:(int)row Column:(int)column
{
    SquareSprite* square = [self squareAtRow:row Column:column];
    if (!square.canMerge) {
        return ccp(0, 0);
    }
    int up = row;
    while (up < matrixSize - 1) {
        SquareSprite* upNeighbor = [self squareAtRow:up + 1 Column:column];
        if (upNeighbor.squareType == square.squareType) {
            up++;
        }else{
            break;
        }
    }
    int down = row;
    while (down > 0) {
        SquareSprite* downNeighbor = [self squareAtRow:down - 1 Column:column];
        if (downNeighbor.squareType == square.squareType) {
            down--;
        }else{
            break;
        }
    }
    return ccp(down, up);
}


-(void)checkSpecial
{
    if (gameOver) {
        return;
    }
    BOOL needRecurse = NO;
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.toBeRemove == YES && square.isSpecial && square.squareType == Watersquare) {
                for (int k = 0; k < matrixSize; k++) {
                    SquareSprite* rowSquare = [self squareAtRow:k Column:j];
                    if (rowSquare.squareType == SignalSquare) {
                        continue;
                    }
                    if (rowSquare.toBeRemove == NO && rowSquare.isSpecial) {
                        needRecurse = YES;
                    }
                    rowSquare.toBeRemove = YES;
                }
            }else if (square.toBeRemove == YES && square.isSpecial && square.squareType == DefenceSquare) {
                for (int k = 0; k < matrixSize; k++) {
                    SquareSprite* columnSquare = [self squareAtRow:i Column:k];
                    if (columnSquare.squareType == SignalSquare) {
                        continue;
                    }
                    if (columnSquare.toBeRemove == NO && columnSquare.isSpecial) {
                        needRecurse = YES;
                    }
                    columnSquare.toBeRemove = YES;
                }
            }
        }
    }
    if (needRecurse) {
        [self checkSpecial];
    }
}

-(void) scanSquares
{
    //prevent visible squares appear
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            CGPoint horizontal = [self existHorizontalChainAt:i Column:j];
            CGPoint vertical = [self existVerticalChainAt:i Column:j];
            if (horizontal.y - horizontal.x + 1 >= 3) {
                for (int k = horizontal.x; k <= horizontal.y; k++) {
                    SquareSprite* square = [self squareAtRow:i Column:k];
                    square.toBeRemove = YES;
                    needFill = YES;
                }
                if (!isInit && horizontal.y - horizontal.x + 1 >= 5) {
                    if (squareSrc.x == i) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSignal = YES;
                    }else if (squareDest.x == i) {
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSignal = YES;
                    }else {
                        [self squareAtRow:i Column:horizontal.y].generateSignal = YES;
                    }
                }else if (!isInit && horizontal.y - horizontal.x + 1 == 4){
                    if (squareSrc.x == i) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSpecial = YES;
                    }else if (squareDest.x == i) {
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSpecial = YES;
                    }else {
                        [self squareAtRow:i Column:horizontal.y].generateSpecial = YES;
                    }
                }
            }
            if (vertical.y - vertical.x + 1 >= 3) {
                for (int k = vertical.x; k <= vertical.y; k++) {
                    SquareSprite* square = [self squareAtRow:k Column:j];
                    square.toBeRemove = YES;
                    needFill = YES;
                }
                if (!isInit && vertical.y - vertical.x + 1 >= 5) {
                    if (squareSrc.y == j) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSignal = YES;
                    }else if (squareDest.y == j){
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSignal = YES;
                    }else{
                        [self squareAtRow:vertical.x Column:j].generateSignal = YES;
                    }
                }else if (!isInit && vertical.y - vertical.x + 1 == 4){
                    if (squareSrc.y == j) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSpecial = YES;
                    }else if (squareDest.y == j){
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSpecial = YES;
                    }else{
                        [self squareAtRow:vertical.x Column:j].generateSpecial = YES;
                    }
                }
            }
            //eliminate SignalSquare!!!!!!
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (i == 0 && square.squareType == SignalSquare) {
                square.toBeRemove = YES;
                needFill = YES;
            }
        }
    }
    if (isInit && !needFill) {
        isInit = NO;
        return;
    }
    if (needFill) {
        [self checkSpecial];
        [self removeSquare];
    }
}

-(void) removeSquare
{
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.toBeRemove == YES) {
                
                //add to removeArray except special to be generate
                if (!isInit && square.visible == YES) {
                    [removing addObject:square];
                }
            }
        }
    }
    [self removeAnimate];
    [self fillVacancies];
}

-(void) recycle
{
    SquareSprite* square;
    CCARRAY_FOREACH(removing, square)
    {
        if ([square numberOfRunningActions] == 0) {
            square.generateSignal = NO;
            square.generateSpecial = NO;
            square.isSpecial = NO;
            square.canMove = YES;
            square.scale = 1;
            square.visible = NO;
            [removing removeObject:square];
        }
    }
    if (removing.count == 0) {
        isRemoving = NO;
    }
    CCSprite* sprite;
    CCARRAY_FOREACH(usedSprites, sprite)
    {
        if ([sprite numberOfRunningActions] == 0) {
            sprite.visible = NO;
            sprite.scale = 1;
            [usedSprites removeObject:sprite];
        }
    }
    
    CCSprite* star;
    CCARRAY_FOREACH(signalStars, star)
    {
        if (star.numberOfRunningActions == 0) {
            [signalStars removeObject:star];
            int index = (int)((star.position.x + 110.5f) / 20.5f);
            CCSprite* sprite = (CCSprite*)[ownSignal objectAtIndex: index];
            if (sprite.visible == NO) {
                sprite.visible = YES;
                sprite.opacity = 0;
                [[SimpleAudioEngine sharedEngine] playEffect:@"ownSignal.mp3"];
                [sprite runAction:[CCFadeIn actionWithDuration:0.8]];
            }
            if (signal >= 0) {
                foodLeft.visible = NO;
                foodRight.visible = NO;
                foodMiddle.visible = NO;
                mask.visible = NO;
                //win
                if (!win) {
                    win = YES;
                    [[SimpleAudioEngine sharedEngine] playEffect:@"win.mp3"];
                    [batch runAction:[CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -boundingBox.size.height)] rate:3]];
                    [status runAction:[CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, boundingBox.size.height)] rate:3]];
                    
                    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:9];
                    for (int i = 0; i < 9; i++) {
                        NSString* file = [NSString stringWithFormat:@"win%i.png", i+1];
                        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                        [frames addObject:frame];
                    }
                    CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
                    CCAnimate* success = [CCAnimate actionWithAnimation:anim];
                    [astronaut stopAllActions];
                    [astronaut runAction:success];
                }
            }
        }
    }
    
    CCARRAY_FOREACH(timeStars, star)
    {
        if (star.numberOfRunningActions == 0) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"time.mp3"];
            [timeStars removeObject:star];
            [foodMiddle runAction:[CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scaleX:1 scaleY:1] rate:3]];
        }
    }
    
    for (int i = 0; i < matrixSize * matrixSize; i++) {
        CCSprite* star = (CCSprite*)[stars objectAtIndex:i];
        if (star.visible == YES && star.numberOfRunningActions == 0) {
            star.visible = NO;
            CCMotionStreak* streak = (CCMotionStreak*)[streaks objectAtIndex:i];
            [streaks removeObject:streak];
            [self removeChild:streak cleanup:YES];
            streak = [CCMotionStreak streakWithFade:0.5 minSeg:10 width:3 color:ccWHITE textureFilename:@"star.png"];
            [streaks insertObject:streak atIndex:i];
            [self addChild:streak z:5];
        }
    }
}

-(void) fillVacancies
{
    if (gameOver || isRemoving) {
        return;
    }
    isAnimating = YES;
    int increaseTime = 0;
    int increaseTemperature = 0;
    int increaseElectricity = 0;
    for (int j = 0; j < matrixSize; j++) {
        int vacancies = 0;
        CCArray* colum = (CCArray*)[matrix objectAtIndex:j];
        for (int i = 0; i < colum.count ; i++) {
            SquareSprite* square = (SquareSprite*)[colum objectAtIndex:i];
            if (square.toBeRemove == YES) {
                //calculate status increasement
                if (!isInit) {
                    if (square.squareType == Electricitysquare) {
                        increaseElectricity++;
                    }else if (square.squareType == HeatSquare) {
                        increaseTemperature++;
                    }else if (square.squareType == SignalSquare) {
                        if (signal < 5) {
                            CCSprite* star = [self generateStar];
                            star.position = square.position;
                            CGPoint worldSignalPosition = [status convertToWorldSpace:((CCSprite*)[ownSignal objectAtIndex:signal]).position];
                            CGPoint worldStarPosition = [self convertToWorldSpace:star.position];
                            [star runAction:[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(worldSignalPosition.x - worldStarPosition.x, worldSignalPosition.y - worldStarPosition.y)] rate:3]];
                            [[SimpleAudioEngine sharedEngine] playEffect:@"star.mp3"];
                            [signalStars addObject:star];
                            signal++;
                        }
                    }else if (square.squareType == FoodSquare) {
                        increaseTime += 2;
                    }
                }
                
                vacancies++;
                square.toBeRemove = NO;
                if (square.generateSignal == YES) {
                    square.generateSignal = NO;
                    [square setType:SignalSquare isSpecial:NO];
                    square.visible = YES;
                    square.scale = 1;
                    vacancies--;
                }else if (square.generateSpecial == YES && square.squareType != Electricitysquare){
                    square.generateSpecial = NO;
                    [square setType:square.squareType isSpecial:YES];
                    square.visible = YES;
                    square.scale = 1;
                    vacancies--;
                }else {
                    [colum removeObjectAtIndex:i];
                    square.isUsing = NO;
                }
                i--;
            }else if (!isInit && vacancies > 0){
                CGPoint endPoint = [self positionOfItemAtRow:i Column:j];
                float duration = 0.1 * vacancies;
                [square stopAllActions];
                [square runAction:[CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:duration position:endPoint] rate:3]];
            }
        }
        for (int k = 0; k < vacancies ; k++) {
            int type = arc4random() % (MAXSquare - 1);
            [self createAtRow:matrixSize - vacancies + k Column:j WithType:type canMove:YES isSpecial:NO];
            if (!isInit) {
                [self dropSquareAtRow:matrixSize - vacancies + k Column:j From:[self positionOfItemAtRow:matrixSize + k Column:j]];
            }
        }
    }
    
    //update status
    if (increaseTime > 0) {
        time += increaseTime;
        if (time > timeMax) {
            time = timeMax;
        }
        
        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            NSString* file = [NSString stringWithFormat:@"eat%i.png", i+1];
            CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [frames addObject:frame];
        }
        [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"astronaut.png"]];
        CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
        CCAnimate* eat = [CCAnimate actionWithAnimation:anim];
        [astronaut runAction:eat];
    }
    if (increaseTemperature > 0) {
        temperature += increaseTemperature;
        if (temperature > 5) {
            temperature = 5;
        }
    }
    if (increaseElectricity > 0) {
        electricity += increaseElectricity;
        if (electricity >= electricityMax) {
            if (signal < 5) {
                CCSprite* star = [self generateStar];
                CGPoint worldSignalPosition = [status convertToWorldSpace:((CCSprite*)[ownSignal objectAtIndex:signal]).position];
                CGPoint worldStarPosition = [status convertToWorldSpace:((CCSprite*)[electricityMiddle objectAtIndex:electricityMax / 2]).position];
                star.position = [batch convertToNodeSpace:worldStarPosition];
                [star runAction:[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(worldSignalPosition.x - worldStarPosition.x, worldSignalPosition.y - worldStarPosition.y)] rate:3]];
                [[SimpleAudioEngine sharedEngine] playEffect:@"star.mp3"];
                [signalStars addObject:star];
                signal++;
            }
            electricity %= electricityMax;
        }
        if (electricity > 0) {
            electricityLeft.visible = YES;
            CGPoint position = ((CCSprite*)[electricityMiddle objectAtIndex:electricity - 1]).position;
            position.x += ((CCSprite*)[electricityMiddle objectAtIndex:0]).contentSize.width;
            electricityRight.position = position;
            electricityRight.visible = YES;
        }else {
            electricityLeft.visible = NO;
            electricityRight.visible = NO;
        }
        for (int i = 0; i < electricity; i++) {
            CCSprite* sprite = (CCSprite*)[electricityMiddle objectAtIndex:i];
            sprite.visible = YES;
        }
        for (int i = electricity; i < electricityMax; i++) {
            CCSprite* sprite = (CCSprite*)[electricityMiddle objectAtIndex:i];
            sprite.visible = NO;
        }
    }
    CCLOG(@"!!!time: %f", time);
    CCLOG(@"!!!temperature: %i", temperature);
    CCLOG(@"!!!electricity: %i", electricity);
    
    needFill = NO;
    squareSrc = ccp(-1, -1);
    squareDest = ccp(-1, -1);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [GameScene locationFromTouch:touch];
    BOOL isTouchHandled = CGRectContainsPoint(boundingBox, touchLocation);
    if (isTouchHandled) {
        squareSrc = [self squareAtPoint:touchLocation];
        isTouchEnable = YES;
    }else {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CCSprite* star = [self generateStar];
        star.position = ccp(boundingBox.size.width/2 + 1, screenSize.height - boundingBox.size.height/2 - arc4random() % 100);
        [star runAction:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:2 position:ccp(-boundingBox.size.width/2 - 100, boundingBox.size.height/2 + arc4random() % 100)] rate:3]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"star.mp3"];
    }
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (squareSrc.x == -1 || squareSrc.y == -1 || !isTouchEnable) {
        return;
    }
    CGPoint touchLocation = [GameScene locationFromTouch:touch];
    int row = squareSrc.x;
    int column = squareSrc.y;
    CGRect upRect = [self rectAtRow:row + 1 Column:column];
    CGRect downRect = [self rectAtRow:row - 1 Column:column];
    CGRect leftRect = [self rectAtRow:row Column:column - 1];
    CGRect rightRect = [self rectAtRow:row Column:column + 1];
    if (CGRectContainsPoint(upRect, touchLocation)) {
        if (row + 1 < matrixSize) {
            squareDest = ccp(row + 1, column);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row + 1, column);
            return;
        }
    }
    if (CGRectContainsPoint(downRect, touchLocation)) {
        if (row - 1 >= 0) {
            squareDest = ccp(row - 1, column);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row - 1, column);
            return;
        }
    }
    if (CGRectContainsPoint(leftRect, touchLocation)) {
        if (column - 1 >= 0) {
            squareDest = ccp(row, column - 1);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row, column - 1);
            return;
        }
    }
    if (CGRectContainsPoint(rightRect, touchLocation)) {
        if (column + 1 < matrixSize) {
            squareDest = ccp(row, column + 1);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row, column + 1);
            return;
        }
    }
}

-(CGPoint) squareAtPoint:(CGPoint)location
{
    float left = boundingBox.origin.x;
    float width = boundingBox.size.width;
    float bottom = boundingBox.origin.y;
    float height= boundingBox.size.height;
    int column = (location.x - left) / (width / matrixSize);
    int row = (location.y - bottom) / (height / matrixSize);
    CCLOG(@"row: %i, column: %i", row, column);
    return ccp(row, column);
}

-(CGRect) rectAtRow:(int)row Column:(int)column
{
    float left = boundingBox.origin.x;
    float width = boundingBox.size.width;
    float bottom = boundingBox.origin.y;
    float height= boundingBox.size.height;
    float originX = left + column * (width / matrixSize);
    float originY = bottom + row * (height / matrixSize);
    return CGRectMake(originX, originY, (width / matrixSize), (height / matrixSize));
}

-(void) swapSquare
{
    if (needReset || win || gameOver || isRemoving || isAnimating || squareSrc.x == -1 || squareDest.x == -1) {
        return;
    }
    isAnimating = YES;
    isTouchEnable = NO;
    
    CCArray* srcColumn = (CCArray*)[matrix objectAtIndex:squareSrc.y];
    CCArray* destColumn = (CCArray*)[matrix objectAtIndex:squareDest.y];
    SquareSprite* src = (SquareSprite*)[srcColumn objectAtIndex:squareSrc.x];
    SquareSprite* dest = (SquareSprite*)[destColumn objectAtIndex:squareDest.x];
    if (!src.canMove || !dest.canMove) {
        return;
    }
    [srcColumn removeObjectAtIndex:squareSrc.x];
    [srcColumn insertObject:dest atIndex:squareSrc.x];
    [destColumn removeObjectAtIndex:squareDest.x];
    [destColumn insertObject:src atIndex:squareDest.x];
    
    CGPoint horizontalSrc = [self existHorizontalChainAt:squareSrc.x Column:squareSrc.y];
    CGPoint verticalSrc = [self existVerticalChainAt:squareSrc.x Column:squareSrc.y];
    CGPoint horizontalDest = [self existHorizontalChainAt:squareDest.x Column:squareDest.y];
    CGPoint verticalDest = [self existVerticalChainAt:squareDest.x Column:squareDest.y];
    if (horizontalSrc.y - horizontalSrc.x + 1 >= 3 || verticalSrc.y - verticalSrc.x + 1 >= 3 || horizontalDest.y - horizontalDest.x + 1 >= 3 || verticalDest.y - verticalDest.x + 1 >= 3) {
        //valid movement
        CCMoveTo* moveSrc = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCMoveTo* moveDest = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        [src runAction:[CCEaseInOut actionWithAction:moveSrc rate:3]];
        [dest runAction:[CCEaseInOut actionWithAction:moveDest rate:3]];
        
        //temperature decay in every turn
        temperature--;
        if (temperature <= 0) {
            temperature = 0;
            frozen = YES;
        }
    }else{
        //invalid movement
        [srcColumn removeObjectAtIndex:squareSrc.x];
        [srcColumn insertObject:src atIndex:squareSrc.x];
        [destColumn removeObjectAtIndex:squareDest.x];
        [destColumn insertObject:dest atIndex:squareDest.x];
        
        CCMoveTo* moveSrc = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCMoveTo* moveDest = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        CCMoveTo* moveSrcBack = [CCMoveTo actionWithDuration:0.3 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        CCMoveTo* moveDestBack = [CCMoveTo actionWithDuration:0.3 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCSequence* SrcSequence = [CCSequence actions:moveSrc, moveSrcBack, nil];
        CCSequence* DestSequence = [CCSequence actions:moveDest, moveDestBack, nil];
        [src runAction:[CCEaseInOut actionWithAction:SrcSequence rate:3]];
        [dest runAction:[CCEaseInOut actionWithAction:DestSequence rate:3]];
    }
}

-(void) update:(ccTime)delta
{
    if (!win) {
        time -= delta;
    }
    
    //streaks
    for (int i = 0; i < matrixSize * matrixSize; i++) {
        CCSprite* star = (CCSprite*)[stars objectAtIndex:i];
        if (star.visible == YES) {
            CCMotionStreak* streak = (CCMotionStreak*)[streaks objectAtIndex:i];
            [streak setPosition:star.position];
        }
    }
    
    if (isAnimating) {
        isAnimating = NO;
        for (int i = 0; i < matrixSize; i++) {
            for (int j = 0; j < matrixSize; j++) {
                SquareSprite* square = [self squareAtRow:i Column:j];
                if ([square numberOfRunningActions] > 0) {
                    isAnimating = YES;
                    break;
                }
            }
        }
        //CCLOG(@"is animating");
    }
    if (!isInit && !isAnimating) {
        [self scanSquares];
        if (![self isAvailable] && needReset == NO && !isAnimating && !isRemoving && !needFill) {
            //no square can be move to remove
            needReset = YES;
            [shake runAction:[CCFadeIn actionWithDuration:0.5]];
            //[self resetSquares];
        }
        [self recycle];
        //CCLOG(@"is not animating");
    }
    
    //check temperature
    if (temperature > 0) {
        temperatureLeft.visible = YES;
        CGPoint position = ((CCSprite*)[temperatureMiddle objectAtIndex:temperature -1]).position;
        position.x += ((CCSprite*)[temperatureMiddle objectAtIndex:temperature -1]).contentSize.width;
        temperatureRight.position = position;
        temperatureRight.visible = YES;
    }else {
        temperatureLeft.visible = NO;
        temperatureRight.visible = NO;
    }
    for (int i = 0; i < temperature; i++) {
        CCSprite* sprite = (CCSprite*)[temperatureMiddle objectAtIndex:i];
        sprite.visible = YES;
    }
    for (int i = temperature; i < temperatureMax; i++) {
        CCSprite* sprite = (CCSprite*)[temperatureMiddle objectAtIndex:i];
        sprite.visible = NO;
    }
    
    //check time
    if (time < 0) {
        foodLeft.visible = NO;
        foodRight.visible = NO;
        foodMiddle.visible = NO;
        mask.visible = NO;
        //game over
        if (!gameOver) {
            gameOver = YES;
            [[SimpleAudioEngine sharedEngine] playEffect:@"lose.mp3"];
            [batch runAction:[CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -boundingBox.size.height)] rate:3]];
            [status runAction:[CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, boundingBox.size.height)] rate:3]];
            
            NSMutableArray* frames = [NSMutableArray arrayWithCapacity:4];
            for (int i = 0; i < 4; i++) {
                NSString* file = [NSString stringWithFormat:@"dead%i.png", i+1];
                CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                [frames addObject:frame];
            }
            CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
            CCAnimate* dead = [CCAnimate actionWithAnimation:anim];
            [astronaut stopAllActions];
            [astronaut runAction:dead];
        }
        if (batch.numberOfRunningActions == 0 && status.numberOfRunningActions == 0 && astronaut.numberOfRunningActions == 0) {
            delay -= delta;
            if (delay < 0) {
                [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
                [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5 scene:[LoseScene scene] withColor:ccWHITE]];
            }
        }
    }else if (foodMiddle.numberOfRunningActions == 0){
        foodMiddle.scaleX = time/timeMax;
        CGPoint position = foodMiddle.position;
        position.x += foodMiddle.contentSize.width * foodMiddle.scaleX;
        foodRight.position = position;
    }else {
        time = timeMax;
    }
    
    //check win
    if (win && batch.numberOfRunningActions == 0 && status.numberOfRunningActions == 0 && astronaut.numberOfRunningActions == 0) {
        delay -= delta;
        if (delay < 0) {
            [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5 scene:[WinScene scene] withColor:ccWHITE]];
        }
    }
    
    //check temperature
    //temperature = 0;
    if (temperature > 0) {
        frozen = NO;
    }
    //frozen = YES;
    if (!isAnimating && !isRemoving && !needFill && frozen) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"frozen.mp3"];
        CCLOG(@"!!!!!!!!!!!!frozen");
        for (int i = 0; i < 3; i++) {
            int row = arc4random() % matrixSize;
            int column = arc4random() % matrixSize;
            SquareSprite* square = [self squareAtRow:row Column:column];
            if (square.canMove) {
                square.canMove = NO;
                CCSprite* ice = [self generateIce];
                [square addChild:ice z:1 tag:@"ice"];
            }
        }
        frozen = NO;
    }
}

-(void) setAstronautPositionX:(int)x
{
    CGPoint position = astronaut.position;
    position.x = x;
    if (x > 10) {
        position.x = 10;
    }
    if (x < -10) {
        position.x = -10;
    }
    astronaut.position = position;
}

-(void) resetByShake
{
    if (needReset) {
        [shake runAction:[CCFadeOut actionWithDuration:0.5]];
        [self resetSquares];
        needReset = NO;
    }
}

-(void) dealloc
{
    [electricityMiddle release];
    [temperatureMiddle release];
    [ownSignal release];
    [squares release];
    [matrix release];
    [removing release];
    [usedSprites release];
    [signalStars release];
    [timeStars release];
    [lineSprites release];
    [ices release];
    [stars release];
    [streaks release];
    [super dealloc];
}
@end