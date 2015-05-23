//
//  DetailViewController.h
//  BitcoinTrader3
//
//  Created by Danny G on 2015-05-22.
//  Copyright (c) 2015 DGInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

