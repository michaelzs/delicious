//
//  TimeLineCell.h
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObject.h"
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
#define INSETS 8.0f
@interface TimeLineCell : UITableViewCell
{
    UIImageView *_userHead;
    UIImageView *_bubbleBg;
    UIImageView *_headMask;
    UIImageView *_chatImage;
    UILabel *_messageConent;
    UILabel *_user;
    UILabel *_time;
}
@property (nonatomic) enum messageCellStyle msgStyle;
@property (nonatomic) int height;
-(void)setMessage:(NSString*)aMessage;
-(void)setHeadImage:(NSURL*)headImage tag:(int)aTag;
-(void)setChatImage:(NSData*)image withText:(NSString*)text tag:(int)aTag;
-(void)setChatTime:(NSString*)time withUser:(NSString*)user tag:(int)aTag;

@end
