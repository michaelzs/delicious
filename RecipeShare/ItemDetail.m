//
//  ItemDetail.m
//  RecipeShare
//
//  Created by SongShiyu on 5/4/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "ItemDetail.h"
#import "Entity.h"
#import "ss4556AppDelegate.h"

@interface ItemDetail ()
@property (strong, nonatomic) IBOutlet UIImageView *photoimage;

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *ingredient;
@property (strong, nonatomic) IBOutlet UILabel *process1;
@property (strong, nonatomic) IBOutlet UILabel *process2;
@property (strong, nonatomic) IBOutlet UILabel *process3;

@end

@implementation ItemDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    Entity *ent=appDelegate.entity;
    self.name.text=ent.name;
    self.ingredient.text=ent.ingredient;
    self.process1.text=ent.process1;
    self.process2.text=ent.process2;
    self.process3.text=ent.process3;
    id image =ent.image;
    NSLog(@"caonima:%@",ent.image);
    if ([image isKindOfClass:[NSString class]]) {
        NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
        UIImage *imageView = [UIImage imageWithData:imageData];
        _photoimage.image = imageView;
        
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
