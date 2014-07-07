//
//  SendTextTimeLineViewController.h
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendTextTimeLineViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textField;
- (IBAction)sendText:(id)sender;
- (IBAction)cancelEdit:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *charactorCounter;
@end
