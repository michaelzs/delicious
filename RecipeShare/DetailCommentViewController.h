//
//  DetailCommentViewController.h
//  RecipeShare
//
//  Created by D L on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface DetailCommentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *charactorCount;
@property (strong, nonatomic) IBOutlet UITextView *textField;
- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *ruid;
@property (strong, nonatomic) NSString *rtime;
@property (strong, nonatomic) NSDictionary *detaildata;


@end
