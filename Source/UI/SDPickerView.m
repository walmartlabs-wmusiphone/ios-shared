//
//  SDPickerView.m
//  ios-shared

//
//  Created by Douglas Pedley on 12/13/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDPickerView.h"
#import "UIColor+SDExtensions.h"
#import "SDMacros.h"

typedef NS_ENUM(NSUInteger, SDPickerViewMode)
{
    SDPickerViewMode_DatePicker,
    SDPickerViewMode_ItemPicker,
    SDPickerViewMode_DefaultPicker,
    SDPickerViewMode_Uninitialized
};

@interface SDPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray <NSString>*items;
@property (nonatomic, assign) NSInteger initialItem;
@property (nonatomic, copy) SDPickerViewDateCompletionBlock dateCompletion;
@property (nonatomic, copy) SDPickerViewItemSelectionCompletionBlock itemCompletion;
@property (nonatomic, copy) SDPickerViewItemSelectionDefaultCompletionBlock defaultCompletion;

@property (nonatomic, strong) UIView *modalScreenView;
@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, strong) UIToolbar *pickerBar;

@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *defaultPicker;

@property (nonatomic, readonly) SDPickerViewMode pickerMode;

@end

@implementation SDPickerView

-(SDPickerViewMode)pickerMode
{
    if (self.itemPicker)
    {
        return SDPickerViewMode_ItemPicker;
    }
    
    if (self.datePicker)
    {
        return SDPickerViewMode_DatePicker;
    }
    
    if (self.defaultPicker) {
        return SDPickerViewMode_DefaultPicker;
    }
    
    return SDPickerViewMode_Uninitialized;
}

#pragma mark - Actions

-(void)dismissPickerWithCompletion:(void (^)(BOOL finished))completion
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    @weakify(self);
    // Animate away
    // First fade in
    [UIView animateWithDuration:0.5f animations:^{
        self.pickerContainerView.frame = CGRectMake(0,
                                                    mainWindow.frame.size.height,
                                                    mainWindow.frame.size.width,
                                                    self.pickerContainerView.frame.size.height);
    } completion:^(BOOL finished) {
        // Now animate the screen down.
        [UIView animateWithDuration:0.2f animations:^{
            @strongify(self);
            self.modalScreenView.alpha = 1.0f;
        } completion:completion];
    }];
}

-(IBAction)doneAction:(id)sender
{
    @weakify(self);
    [self dismissPickerWithCompletion:^(BOOL fin) {
        @strongify(self);
        [self.modalScreenView removeFromSuperview];
        [self addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
        switch (self.pickerMode)
        {
            case SDPickerViewMode_DatePicker:
            {
                if (self.dateCompletion)
                {
                    SDPickerViewDateCompletionBlock completion = [self.dateCompletion copy];
                    completion(NO, self.datePicker.date);
                }
                break;
            }

            case SDPickerViewMode_ItemPicker:
            {
                if (self.itemCompletion)
                {
                    SDPickerViewItemSelectionCompletionBlock completion = [self.itemCompletion copy];
                    NSInteger selectedItem = [self.itemPicker selectedRowInComponent:0];
                    completion(NO, selectedItem, self.items[(NSUInteger)selectedItem]);
                }
                break;
            }
            
            case SDPickerViewMode_DefaultPicker: 
            {
                if (self.defaultCompletion) 
                {
                    SDPickerViewItemSelectionDefaultCompletionBlock completion = [self.defaultCompletion copy];
                    completion(NO, self);
                }
                break;
            }
                
            default:
                break;
        }
    }];
}

-(IBAction)cancelAction:(id)sender
{
    @weakify(self);
    [self dismissPickerWithCompletion:^(BOOL fin) {
        @strongify(self);
        [self.modalScreenView removeFromSuperview];
        [self addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
        switch (self.pickerMode)
        {
            case SDPickerViewMode_DatePicker:
            {
                if (self.dateCompletion)
                {
                    SDPickerViewDateCompletionBlock completion = [self.dateCompletion copy];
                    completion(YES, nil);
                }
                break;
            }
                
            case SDPickerViewMode_ItemPicker:
            {
                if (self.itemCompletion)
                {
                    SDPickerViewItemSelectionCompletionBlock completion = [self.itemCompletion copy];
                    completion(YES, -1, nil);
                }
                break;
            }
            
            case SDPickerViewMode_DefaultPicker:
            {
                if (self.defaultCompletion) 
                {
                    SDPickerViewItemSelectionDefaultCompletionBlock completion = [self.defaultCompletion copy];
                    completion(YES, self);
                }
                break;
            }
                
            default:
                break;
        }
    }];
}

-(IBAction)startAction:(id)sender
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    // Disable the button
    [self removeTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    self.modalScreenView.alpha = 0.0f;
    [mainWindow addSubview:self.modalScreenView];
    
    @strongify(self.delegate, strongDelegate);
    if ([strongDelegate respondsToSelector:@selector(pickerViewWillShow:)])
    {
        [strongDelegate performSelector:@selector(pickerViewWillShow:) withObject:self];
    }
    
    // First fade in
    [UIView animateWithDuration:0.2f animations:^{
        self.modalScreenView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Now animate the screen up.
        [UIView animateWithDuration:0.5f animations:^{
            self.pickerContainerView.frame = CGRectMake(0,
                                                        mainWindow.frame.size.height - self.pickerContainerView.frame.size.height,
                                                        mainWindow.frame.size.width,
                                                        self.pickerContainerView.frame.size.height);
        } completion:^(BOOL finished2) {
            if ([strongDelegate respondsToSelector:@selector(pickerViewDidShow:)])
            {
                [strongDelegate performSelector:@selector(pickerViewDidShow:) withObject:self];
            }
        }];
    }];
    
}

#pragma mark - Configuration

-(void)prepareForReuse
{
    self.itemPicker = nil;
    self.items = nil;
    self.initialItem = 0;
    self.datePicker = nil;
    self.defaultPicker = nil;
    [self addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)configureSharedViewsWithPicker:(UIView *)thePicker
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];

    // Set the picker frame first so other can adjust properly.
    thePicker.frame = CGRectMake(0, 44, mainWindow.frame.size.width, 216);

    if (!self.modalScreenView)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:mainWindow.frame];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        self.modalScreenView = bgView;
    }
    else
    {
        NSArray *subViews = [self.modalScreenView subviews];
        for (UIView *subView in subViews)
            [subView removeFromSuperview];
    }
    
    if (!self.pickerBar)
    {
        UIToolbar *theBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width, 44)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        UIBarButtonItem *fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpacer.width = 8.0f;
        [theBar setItems:[NSArray arrayWithObjects:fixedSpacer,cancelButton, spacer, doneButton, fixedSpacer, nil] animated:NO];
        self.pickerBar = theBar;
    }
    
    if (!self.pickerContainerView)
    {
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, mainWindow.frame.size.height, mainWindow.frame.size.width, thePicker.frame.size.height + self.pickerBar.frame.size.height)];
        container.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        self.pickerContainerView = container;
    }
    else
    {
        NSArray *subViews = [self.pickerContainerView subviews];
        for (UIView *subView in subViews)
            [subView removeFromSuperview];
    }
    
    [self.pickerContainerView addSubview:self.pickerBar];
    [self.pickerContainerView addSubview:thePicker];
    [self.modalScreenView addSubview:self.pickerContainerView];
}

-(void)configureAsDatePickerWithCompletion:(SDPickerViewDateCompletionBlock)completion
{
    [self configureAsDatePicker:nil datePickerMode:UIDatePickerModeDateAndTime completion:completion];
}

-(void)configureAsDatePicker:(NSDate *)initialDate completion:(SDPickerViewDateCompletionBlock)completion
{
    [self configureAsDatePicker:initialDate datePickerMode:UIDatePickerModeDateAndTime completion:completion];
}

-(void)configureAsDatePicker:(NSDate *)initialDate datePickerMode:(UIDatePickerMode)datePickerMode completion:(SDPickerViewDateCompletionBlock)completion
{
    [self prepareForReuse];
    UIDatePicker *theDatePicker = [[UIDatePicker alloc] init];
    theDatePicker.datePickerMode = datePickerMode;
    theDatePicker.date = (initialDate)?initialDate:[NSDate date];
    self.datePicker = theDatePicker;
    self.dateCompletion = completion;
    [self configureSharedViewsWithPicker:theDatePicker];
}

-(void)configureAsDatePicker:(NSDate *)initialDate finalDate:(NSDate *)finalDate datePickerMode:(UIDatePickerMode)datePickerMode completion:(SDPickerViewDateCompletionBlock)completion
{
    [self configureAsDatePicker:initialDate datePickerMode:datePickerMode completion:completion];
    self.datePicker.maximumDate = finalDate;
}

-(void)configureAsItemPicker:(NSArray <NSString>*)items completion:(SDPickerViewItemSelectionCompletionBlock)completion
{
    [self configureAsItemPicker:items initialItem:0 completion:completion];
}

-(void)configureAsItemPicker:(NSArray <NSString>*)items initialItem:(NSInteger)selectedItem completion:(SDPickerViewItemSelectionCompletionBlock)completion
{
    [self prepareForReuse];
    UIPickerView *itemPicker = [[UIPickerView alloc] init];
    self.items = items;
    itemPicker.delegate = self;
    itemPicker.dataSource = self;
    itemPicker.showsSelectionIndicator = YES;
    self.itemPicker = itemPicker;
    self.initialItem = selectedItem;
    self.itemCompletion = completion;
    [self configureSharedViewsWithPicker:itemPicker];
}

-(void)configureAsDefaultPicker:(id<UIPickerViewDataSource>)dataSource delegate:(id<UIPickerViewDelegate>)delegate completion:(SDPickerViewItemSelectionDefaultCompletionBlock)completion {
    [self prepareForReuse];
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = delegate;
    pickerView.dataSource = dataSource;
    pickerView.showsSelectionIndicator = YES;
    self.defaultPicker = pickerView;
    self.defaultCompletion = completion;
    [self configureSharedViewsWithPicker:pickerView];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (NSInteger)self.items.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[(NSUInteger)row];
}

@end
