//
//  MessageObject.h
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMESSAGE_TYPE @"messageType"
#define kMESSAGE_FROM @"messageFrom"
#define kMESSAGE_TO @"messageTo"
#define kMESSAGE_CONTENT @"messageContent"
#define kMESSAGE_DATE @"messageDate"
#define kMESSAGE_ID @"messageId"
//types of messages, only implemented first 2
enum messageType {
    messageTypeText = 1,
    messageTypeImage = 2,
    messageTypeRecipe =3,
    messageTypeLocation=4
};

enum messageCellStyle {
    messageCellStyleText = 1,
    messageCellStyleImage = 2,
    messageCellStyleRecipe = 3,
    messageCellStyleLocation = 4
};

@interface MessageObject : NSObject

@end
