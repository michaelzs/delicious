//
//  Entrance.m
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "Entrance.h"

@interface Entrance ()

@end

@implementation Entrance
@synthesize loginbutton=_loginbutton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Add the button
    [self.loginbutton setStyle:[UIColor whiteColor]  andBottomColor:[UIColor whiteColor]];
    [self.loginbutton setLabelTextColor:[UIColor darkGrayColor] highlightedColor:[UIColor blackColor] disableColor:nil];
    [self.loginbutton setCornerRadius:10];
    [self.loginbutton setBorderStyle:[UIColor whiteColor] andInnerColor:nil];
    
    [self.registerbutton setStyle:[UIColor redColor]  andBottomColor:[UIColor redColor]];
    [self.registerbutton setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor blackColor] disableColor:nil];
    [self.registerbutton  setCornerRadius:10];
    [self.registerbutton  setBorderStyle:[UIColor redColor] andInnerColor:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
