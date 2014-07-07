//
//  ACPButton.h
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ACPButton : UIButton

typedef enum {
    
    ACPButtonOK,
    ACPButtonOK2,
    ACPButtonCancel,
    ACPButtonCancel2,
    ACPButtonBlue,
    ACPButtonBlue2,
    ACPButtonGrey,
    ACPButtonGrey2,
    ACPButtonDarkGrey,
    ACPButtonDarkGrey2,
    ACPButtonPurple,
    ACPButtonPurple2
    
} ACPButtonType;

/*--------------------------------------------------------------------------
 Set up a predefine button
 --------------------------------------------------------------------------*/
- (void) setStyleType:(ACPButtonType)style;

/*--------------------------------------------------------------------------
 Create your own button using images.
 --------------------------------------------------------------------------*/
- (void) setStyleWithImage:(NSString*)image highlightedImage:(NSString*)hImage disableImage:(NSString*)dImage andInsets:(UIEdgeInsets)insets;

/*--------------------------------------------------------------------------
 Set up a predefine flat button
 --------------------------------------------------------------------------*/
- (void) setFlatStyleType:(ACPButtonType)style;

/*--------------------------------------------------------------------------
 Set up a custom flat button
 --------------------------------------------------------------------------*/
- (void) setFlatStyle:(UIColor*)normal andHighlightedColor:(UIColor*)highlighted;

/*--------------------------------------------------------------------------
 Define your own gradient style
 --------------------------------------------------------------------------*/
- (void) setStyle:(UIColor*)topColor andBottomColor:(UIColor*)bottomColor;

/*--------------------------------------------------------------------------
 Set color borders - External and inner
 --------------------------------------------------------------------------*/
- (void) setBorderStyle:(UIColor*)borderColor andInnerColor:(UIColor*)innerColor;


/*--------------------------------------------------------------------------
 Define the corner radius
 --------------------------------------------------------------------------*/
- (void) setCornerRadius:(NSInteger)value;

/*--------------------------------------------------------------------------
 Define the color of the label
 --------------------------------------------------------------------------*/
- (void) setLabelTextColor:(UIColor*)nColor highlightedColor:(UIColor*)hColor disableColor:(UIColor*)dColor;

/*--------------------------------------------------------------------------
 Define the color of the text shadow
 --------------------------------------------------------------------------*/
- (void) setLabelTextShadow:(CGSize)shadowOffSet normalColor:(UIColor*)nColor highlightedColor:(UIColor*)hColor disableColor:(UIColor*)dColor;

/*--------------------------------------------------------------------------
 Change font of the button
 --------------------------------------------------------------------------*/
- (void) setLabelFont:(UIFont*)font;

@end

