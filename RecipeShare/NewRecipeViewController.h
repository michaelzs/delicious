//
//  NewRecipeViewController.h
//  RecipeShare
//
//  Created by Zhan Shu on 4/28/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface NewRecipeViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, retain) NSString *nextToken;
@property (nonatomic, strong)NSString *uID;

@end
