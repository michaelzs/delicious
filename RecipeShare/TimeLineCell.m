//
//  TimeLineCell.m
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "TimeLineCell.h"
#import <QuartzCore/QuartzCore.h>
#define CELL_HEIGHT self.contentView.frame.size.height
#define CELL_WIDTH self.contentView.frame.size.width
@implementation TimeLineCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _userHead =[[UIImageView alloc]initWithFrame:CGRectZero];
        _bubbleBg =[[UIImageView alloc]initWithFrame:CGRectZero];
        _messageConent=[[UILabel alloc]initWithFrame:CGRectZero];
        _headMask =[[UIImageView alloc]initWithFrame:CGRectZero];
        _chatImage =[[UIImageView alloc]initWithFrame:CGRectZero];
        _messageConent=[[UILabel alloc]initWithFrame:CGRectZero];
        _user=[[UILabel alloc]initWithFrame:CGRectZero];
        _time=[[UILabel alloc]initWithFrame:CGRectZero];
        [_messageConent setBackgroundColor:[UIColor clearColor]];
        [_messageConent setFont:[UIFont systemFontOfSize:15]];
        //[_messageConent setTextColor:[UIColor darkGrayColor]];
        [_messageConent setNumberOfLines:20];
        [_user setBackgroundColor:[UIColor clearColor]];
        [_user setFont:[UIFont systemFontOfSize:12]];
        [_user setTextColor:[UIColor darkGrayColor]];
        [_user setNumberOfLines:1];
        [_time setBackgroundColor:[UIColor clearColor]];
        [_time setFont:[UIFont systemFontOfSize:11]];
        [_time setTextColor:[UIColor darkGrayColor]];
        [_time setNumberOfLines:1];
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
        [self.contentView addSubview:_headMask];
        [self.contentView addSubview:_messageConent];
        [self.contentView addSubview:_chatImage];
        [self.contentView addSubview:_user];
        [self.contentView addSubview:_time];
        // [_chatImage setBackgroundColor:[UIColor redColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_headMask setImage:[[UIImage imageNamed:@"UserHeaderImageBox"]stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark layout configuration
-(void)layoutSubviews
{
    [super layoutSubviews];
    NSString *textC=_messageConent.text;
    CGSize textSize=[textC boundingRectWithSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] context:nil].size;
    //CGSize textSize=[textC sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *textU=_user.text;
    CGSize userTextSize=[textU boundingRectWithSize:CGSizeMake(320, TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], NSFontAttributeName,nil] context:nil].size;
    //CGSize userTextSize=[textU sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(((320-HEAD_SIZE-3*INSETS-40)/2), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *textT=_time.text;
    CGSize timeTextSize=[textT boundingRectWithSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil] context:nil].size;
    //CGSize timeTextSize=[textT sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    switch (_msgStyle) {
            //if it is a plain text message
            case messageCellStyleText:
        {
            [_chatImage setHidden:YES];
            [_messageConent setHidden:NO];
            [_userHead setFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
            [_messageConent setFrame:CGRectMake(3*INSETS+HEAD_SIZE+INSETS, INSETS*2, textSize.width, textSize.height)];
            [_user setFrame:CGRectMake(INSETS, INSETS*2+HEAD_SIZE,HEAD_SIZE, userTextSize.height)];
            [_time setFrame:CGRectMake(CELL_WIDTH-INSETS*2-timeTextSize.width, INSETS*5+INSETS+textSize.height,timeTextSize.width, timeTextSize.height)];
            [_bubbleBg setImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-2*INSETS, _messageConent.frame.origin.y-INSETS, textSize.width+INSETS*4, textSize.height+4*INSETS);
        }
            break;
            //if it is a message with text and image
            case messageCellStyleImage:
        {
            [_chatImage setHidden:NO];
            [_messageConent setHidden:NO];
            [_userHead setFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
            [_messageConent setFrame:CGRectMake(3*INSETS+HEAD_SIZE+INSETS, 2*INSETS+100+INSETS, textSize.width, textSize.height)];
            [_chatImage setFrame:CGRectMake(4*INSETS+HEAD_SIZE, INSETS*2,140,100)];
            [_user setFrame:CGRectMake(INSETS, INSETS*2+HEAD_SIZE,userTextSize.width, userTextSize.height)];
            [_time setFrame:CGRectMake(CELL_WIDTH-INSETS*2-timeTextSize.width, INSETS*2+INSETS+textSize.height+100+INSETS,timeTextSize.width, timeTextSize.height)];
            [_bubbleBg setImage:[[self image:[UIImage imageNamed:@"ReceiverTextNodeBkg"] withColor:[UIColor redColor]]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            //NSInteger * bubbleWidth = textSize.width>100?textSize.width:100;
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-2*INSETS, _chatImage.frame.origin.y-INSETS, (textSize.width>140?textSize.width:140)+4*INSETS, textSize.height+100+4*INSETS);
        }
            break;
            case 3:
        {
                    }
            break;
            case 4:
        {
        
        }
            break;
        default:
            break;
    }
    
    
    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



-(void)setMessage:(NSString*)aMessage
{
    [_messageConent setText:aMessage];
    //NSLog(@"set text in cell");
    
}
-(void)setHeadImage:(NSString*)image tag:(int)aTag
{
    [_userHead setTag:aTag];
    NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
    CGSize size = CGSizeMake(50.0f, 50.0f);
    if(imageData1==NULL){
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"chef-icon"]];
        [_userHead setImage:newImage];
    }else{
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageWithData:imageData1]];
        [_userHead setImage:newImage];
    }
}
                          
-(void)setChatImage:(NSData*)image withText:(NSString*)text tag:(int)aTag
{
    [_chatImage setTag:aTag];
    [_messageConent setTag:aTag];
    [_messageConent setText:text];
    [_chatImage setImage:[UIImage imageWithData:image]];
}
-(void)setChatTime:(NSString*)time withUser:(NSString*)user tag:(int)aTag
{
    [_time setText:time];
    [_time setTag:aTag];
    [_user setTag:aTag];
    [_user setText:user];
}
#pragma mark image resize method
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize from:(UIImage*)image
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark set image color
- (UIImage *)image:(UIImage *)image1 withColor:(UIColor *)color1
{
    UIGraphicsBeginImageContextWithOptions(image1.size, NO, image1.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image1.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image1.size.width, image1.size.height);
    CGContextClipToMask(context, rect, image1.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
