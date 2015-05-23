#import <UIKit/UIKit.h>


@interface PositionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *positionValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionChangeLabel;

@end

