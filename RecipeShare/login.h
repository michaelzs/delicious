//
//  login.h
//  RecipeShare
//
//  Created by SongShiyu on 4/25/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "ACPButton.h"

@interface login : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (strong, nonatomic) IBOutlet ACPButton *loginbutton;

@end
