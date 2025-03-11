//
//  UIViewController+tool.h
//  LightBluffLuckyAlgorithm
//
//  Created by LightBluff LuckyAlgorithm on 2025/3/11.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LBLAVerseType) {
    LBLAVerseTypePortrait = 0,
    LBLAVerseTypeLandRight = 1,
    LBLAVerseTypeLandLeft = 2,
    LBLAVerseTypeLandscape = 3,
    LBLAVerseTypeAll = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (tool)

- (NSDictionary *)getAFDic;
- (void)saveAFStringId:(NSString *)recordID;

- (NSString *)getAFIDStr;
- (NSNumber *)getNumber;
- (NSNumber *)getAFString;

- (NSNumber *)getStatus;
- (void)saveStatus:(NSNumber *)status;
- (NSString *)getad;

- (void)showAdsViewData;

- (NSArray *)adParams;

- (void)postEvent:(NSString *)eventName;
- (void)postEventWhtParams:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
