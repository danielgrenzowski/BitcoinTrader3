#import "AddPositionViewController.h"


@interface AddPositionViewController ()
@property (strong, nonatomic) NSString *selectedCurrency;
@property (strong, nonatomic) NSString *currentQuantity;
@end


@implementation AddPositionViewController

#pragma mark - view load methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUpPurchaseButton];
    [self setUpCancelButton];
    
    
    self.currencyPicker.delegate = self;
    self.currencyPicker.dataSource = self;
    
    [self updateSelectedCurrencyAccordingToPickerValue];
    [self updateCurrentQuantityAccordingToSliderValue];
    [self setUpPriceLabel];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - custom methods

- (NSString *)convertToCurrency:(double)quantity {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *positionValue = [NSNumber numberWithDouble:quantity];
    NSString *numberAsString = [numberFormatter stringFromNumber:positionValue];
    return numberAsString;
}

#pragma mark - ViewController property methods

- (void)updateCurrentQuantityAccordingToSliderValue {
    
    self.currentQuantity = [NSString stringWithFormat:@"%.2f", self.quantitySlider.value];
}

- (void)updateSelectedCurrencyAccordingToPickerValue {
    
    NSInteger row;
    row = [self.currencyPicker selectedRowInComponent:0];
    self.selectedCurrency = self.currenciesArray[row];
}

#pragma mark - purchase button methods

- (void)setUpPurchaseButton {
    
    [self.purchaseButton addTarget:self
                            action:@selector(purchaseButtonTouchUpInside)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.purchaseButton setBackgroundColor:[UIColor orangeColor]];
}

- (void)purchaseButtonTouchUpInside {
    
    [self updateCurrentQuantityAccordingToSliderValue];
    [self updateSelectedCurrencyAccordingToPickerValue];
    
    [self.delegate AddPositionViewController:self didMakePurchaseFromCurrency:self.selectedCurrency withQuantity:self.currentQuantity];
}

#pragma mark - cancel button methods

- (void)setUpCancelButton {
    
    [self.cancelButton addTarget:self
                          action:@selector(cancelButtonTouchUpInside)
                forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundColor:[UIColor orangeColor]];
}

- (void)cancelButtonTouchUpInside {
    
    [self.delegate AddPositionViewControllerDidCancelPurchase:self];
}

#pragma mark - slider methods

- (IBAction)sliderValueChanged:(id)sender {
    
    [self updateCurrentQuantityAccordingToSliderValue];
    [self updatePriceLabelWithBitcoinQuantity:[self.currentQuantity intValue]];
}

#pragma mark - currencyPicker delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.currenciesArray count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.selectedCurrency = self.currenciesArray[row];
    [self updateCurrentQuantityAccordingToSliderValue];
    [self updatePriceLabelCurrency];
    
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = self.currenciesArray[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
    
}

#pragma - displayPriceLabel methods

- (void)setUpPriceLabel {
    
    [self updatePriceLabelCurrency];
    [self.displayPriceLabel setAdjustsFontSizeToFitWidth:YES];
    self.displayPriceLabel.textColor = [UIColor orangeColor];
    
}

- (void)updatePriceLabelCurrency {
    
    [self.delegate AddPositionViewController:self didSetExchangeRateFromCurrency:self.selectedCurrency withQuantity:self.currentQuantity];
}

- (void)updatePriceLabelWithBitcoinQuantity:(int)quantity {
    
    float currentPrice = [self.currentPrice floatValue];
    NSString *positionValueUnformatted = [NSString stringWithFormat:@"%.2f", quantity * currentPrice];
    NSString *positionValue = [self convertToCurrency:[positionValueUnformatted doubleValue]];
    NSString *displayMessage = [NSString stringWithFormat:@"%d BTC = %@ %@", quantity, positionValue, self.selectedCurrency];
    self.displayPriceLabel.text = displayMessage;
}

@end