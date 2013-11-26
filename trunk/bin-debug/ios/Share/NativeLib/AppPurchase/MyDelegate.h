//
//  MyDelegate.h
//  AppPurchase
//
//  Created by Saumitra Bhave on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern FREContext g_ctx;
NSMutableString* generateXml(SKPaymentTransaction*);


@interface MyDelegate : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate> {

}
//// SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

//// SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
@end
