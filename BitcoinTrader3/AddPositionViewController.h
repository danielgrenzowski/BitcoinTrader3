#import <UIKit/UIKit.h>


@class AddPositionViewController;

@protocol AddPositionViewControllerDelegate <NSObject>

- (void) AddPositionViewController:(AddPositionViewController *)controller didMakePurchaseFromCurrency:(NSString *)currency withQuantity:(NSString *)currencyQuantity;

- (void) AddPositionViewController:(AddPositionViewController *)controller didSetExchangeRateFromCurrency:(NSString *)currency withQuantity:(NSString *)currencyQuantity;

- (void) AddPositionViewControllerDidCancelPurchase:(AddPositionViewController *)controller;

@end

@interface AddPositionViewController : UIViewController <UIPickerViewDelegate, UIPickerViewAccessibilityDelegate, UIPickerViewDataSource>

@property NSMutableArray *currenciesArray;
@property (strong, nonatomic) NSString *currentPrice;

@property (nonatomic, weak) id <AddPositionViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *displayPriceLabel;
@property (weak, nonatomic) IBOutlet UISlider *quantitySlider;

- (void) updatePriceLabelWithBitcoinQuantity:(int)quantity;

@end

