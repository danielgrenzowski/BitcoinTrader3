//
//  MasterViewController.h
//  BitcoinTrader3
//
//  Created by Danny G on 2015-05-22.
//  Copyright (c) 2015 DGInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

