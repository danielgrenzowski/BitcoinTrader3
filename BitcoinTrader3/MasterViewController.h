#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AddPositionViewController.h"
#import "PositionTableViewCell.h"


@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,NSURLSessionDelegate, AddPositionViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

