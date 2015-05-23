#import "MasterViewController.h"


@interface MasterViewController ()

@property NSMutableArray *currenciesArray;
@property (strong, nonatomic) NSString *currentPrice;

@end


@implementation MasterViewController

#pragma mark - view load methods

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureRefresher];
    [self configureNavBar];
    
    self.currenciesArray =
    [[NSMutableArray alloc] initWithObjects:@"USD", @"CAD", @"JPY", @"EUR", @"GBP", @"AED", nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - refresher methods

- (void)configureRefresher {
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestPositions)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)getLatestPositions {
    
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - nav bar methods

- (void)configureNavBar {
    
    [self configureLeftButton];
    [self configureNavBarTitle];
    [self configureRightButton];
    [self setBackgroundImage];
}

- (void)configureLeftButton {
    
    [self.editButtonItem setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)configureRightButton {
    
    if ([self numberofPositionsInPortfolio] <= 7){
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        [addButton setTintColor:[UIColor orangeColor]];
        self.navigationItem.rightBarButtonItem = addButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)configureNavBarTitle {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor orangeColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"BitcoinTrader";
    [label sizeToFit];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

- (void)setBackgroundImage {
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bitcoinBlack.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tableView.backgroundView = tempImageView;
}

#pragma mark - segue methods

- (void)insertNewObject:(id)sender {
    
    [self performSegueWithIdentifier:@"addPositionSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"addPositionSegue"])
    {
        AddPositionViewController *addPositionViewController = (AddPositionViewController *)segue.destinationViewController;
        addPositionViewController.delegate = self;
        addPositionViewController.currenciesArray = self.currenciesArray;
    }
}

#pragma mark - network requests

- (NSURLSessionDataTask *)postCall:(NSString *)strURL completionHandler:(void (^)(NSDictionary *dataDict, NSURLResponse *response, NSError *error))completionHandler {
    
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithURL:url
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (error) {
                   completionHandler(nil, nil, error);
               } else {
                   NSError *parseError = nil;
                   NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:&parseError];
                   completionHandler(responseDictionary, response, parseError);
               }
           }];
    
    [dataTask resume];
    return dataTask;
}

- (void) savePostion:(NSString *)quantity inCurrency:(NSString *)currency {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:currency forKey:@"currencySymbol"];
    [newManagedObject setValue:quantity forKey:@"bitcoinQuantity"];
    [newManagedObject setValue:[NSDate date] forKey:@"purchaseDate"];
    [newManagedObject setValue:self.currentPrice forKey:@"priceInCurrency"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


#pragma mark - AddStockViewController delegate Methods

- (void) AddPositionViewController:(AddPositionViewController *)controller didMakePurchaseFromCurrency:(NSString *)currency withQuantity:(NSString *)currencyQuantity {
    
    [self savePostion:currencyQuantity inCurrency:currency];
    [self configureNavBar];
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) AddPositionViewControllerDidCancelPurchase:(AddPositionViewController *)controller {
    
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) AddPositionViewController:(AddPositionViewController *)controller didSetExchangeRateFromCurrency:(NSString *)currency withQuantity:(NSString *)quantity {
    
    NSString *strURL = @"https://api.coinbase.com/v1/currencies/exchange_rates";
    
    NSURLSessionTask *task = [self postCall:strURL completionHandler:^(NSDictionary *dataDict, NSURLResponse *response, NSError *error) {
        
        NSString *key = [[NSString stringWithFormat:@"%@_to_btc", currency] lowercaseString];
        NSString *currentExchangeRate = [dataDict objectForKey:key];
        self.currentPrice = [self strInvertExchangeRate:currentExchangeRate];
        controller.currentPrice = self.currentPrice;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [controller updatePriceLabelWithBitcoinQuantity:[quantity intValue]];
        });
    }];
    
    if (!task) {
        // handle failure to create task any way you want
    }
}

#pragma mark - custom methods

- (NSString *)strInvertExchangeRate:(NSString *)rate {
    
    float oldRate = [rate floatValue];
    float newRate = 1/oldRate;
    return [NSString stringWithFormat:@"%.2f", newRate];
}

- (double)positionValueOf:(NSString *)quantity atPrice:(NSString *)price {
    
    double currentQuantity = [quantity doubleValue];
    double currentPrice = [price doubleValue];
    return [self roundToTwo:(currentPrice * currentQuantity)];
}

- (double)positionChangeFrom:(NSString *)oldPrice atNewPrice:(NSString *)newPrice {
    
    double theOldPrice = [oldPrice doubleValue];
    double theNewPrice = [newPrice doubleValue];
    double positionChangeSigned = [self roundToTwo:(theNewPrice - theOldPrice)/theOldPrice];
    
    if (positionChangeSigned == 0 && theOldPrice > theNewPrice)
        positionChangeSigned = -1 * positionChangeSigned;
    
    return positionChangeSigned;
}

- (double)roundToTwo:(double)num {
    
    return round(100 * num) / 100;
}

- (NSString *)convertToCurrency:(double)quantity {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *positionValue = [NSNumber numberWithDouble:quantity];
    NSString *numberAsString = [numberFormatter stringFromNumber:positionValue];
    return numberAsString;
}

- (NSInteger) numberofPositionsInPortfolio {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Position" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    
    NSError *err;
    NSInteger count = [context countForFetchRequest:request error:&err];
    
    if(count == NSNotFound) {
        //Handle error
    } else {
        return count;
    }
    
    return 0;
}

#pragma mark - tableview delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PositionTableViewCell *cell = (PositionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self configureNavBar];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - tableview cell methods

- (void)configureCell:(PositionTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor blackColor];
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *currencySymbol = [[object valueForKey:@"currencySymbol"] description];
    NSString *purchasePrice = [[object valueForKey:@"priceInCurrency"] description];
    NSString *quantity = [[object valueForKey:@"bitcoinQuantity"] description];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MMM-yy"];
    NSString *dateString = [df stringFromDate:[object valueForKey:@"purchaseDate"]];
    
    [self configureLabel:cell.positionDateLabel withText:dateString withColor:[UIColor whiteColor]];
    [self configureLabel:cell.positionCurrencyLabel withText:currencySymbol withColor:[UIColor whiteColor]];
    [self configurePositionLabelsWithCurrency:currencySymbol withOldPrice:purchasePrice withQuantity:quantity atCell:cell];
}

#pragma mark - label setters

- (void)configureLabel:(UILabel *)myLabel withText:(NSString *)labelMessage withColor:(UIColor*)color {
    
    myLabel.text = labelMessage;
    myLabel.textColor = color;
    [myLabel setAdjustsFontSizeToFitWidth:YES];
}

- (void) configurePositionLabelsWithCurrency:(NSString *)currency withOldPrice:(NSString *)oldPrice withQuantity:(NSString *)quantity atCell:(PositionTableViewCell *)cell {
    
    NSString *strURL = @"https://api.coinbase.com/v1/currencies/exchange_rates";
    
    NSURLSessionTask *task = [self postCall:strURL completionHandler:^(NSDictionary *dataDict, NSURLResponse *response, NSError *error) {
        
        NSString *key = [[NSString stringWithFormat:@"%@_to_btc", currency] lowercaseString];
        NSString *newExchangeRate = [dataDict objectForKey:key];
        NSString *newPrice = [self strInvertExchangeRate:newExchangeRate];
        
        double positionValue = [self positionValueOf:quantity atPrice:newPrice];
        double positionChange = [self positionChangeFrom:oldPrice atNewPrice:newPrice];
        
        NSString *positionValueString = [self convertToCurrency:positionValue];
        NSString *positionChangeString = [NSString stringWithFormat:@"%.2f%%", positionChange];
        UIColor *positionChangeStringColor = [UIColor new];
        
        if (positionChange > 0){
            positionChangeStringColor = [UIColor greenColor];
        } else if (positionChange == 0){
            positionChangeStringColor = [UIColor whiteColor];
        } else {
            positionChangeStringColor = [UIColor redColor];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureLabel:cell.positionValueLabel withText:positionValueString withColor:positionChangeStringColor];
            [self configureLabel:cell.positionChangeLabel withText:positionChangeString withColor:positionChangeStringColor];
        });
    }];
    
    if (!task) {
        // handle failure to create task any way you want
    }
}

#pragma mark - fetched results controller methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:8];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"purchaseDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PositionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

@end
