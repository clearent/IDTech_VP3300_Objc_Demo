//
//  ClearentTransactionToken.h
//  ClearentIdtechIOSFramework
//
//  Created by David Higginbotham on 3/30/20.
//  Copyright © 2020 Clearent, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ClearentTransactionToken <NSObject>

- (NSString*) jwt;
- (NSString*) cvm;
- (NSString*) lastFour;
- (NSString*) trackDataHash;

- (instancetype) initWithJson:(NSString*)jsonString;

@end

@interface ClearentTransactionToken: NSObject <ClearentTransactionToken>

@property (nonatomic) NSString *jwt;
@property (nonatomic) NSString *cvm;
@property (nonatomic) NSString *lastFour;
@property (nonatomic) NSString *trackDataHash;

- (instancetype) initWithJson:(NSString*)jsonString;

@end
