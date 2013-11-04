//
//  MyDelegate.m
//  AppPurchase
//
//  Created by Saumitra Bhave on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "FlashRuntimeExtensions.h"
#import "MyDelegate.h"
#import "UIKit/UIKit.h"

@implementation MyDelegate
////SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    NSLog(@"Updated Transactions Called..");
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<transactions>"];
	NSLog(@"obj Created");
	for (SKPaymentTransaction *t in transactions)
    {
		NSMutableString* tr = generateXml(t);
		[retXML appendString:tr];
		[tr release];
		NSLog(@"Out of loop");
	}
	
	[retXML appendFormat:@"</transactions>"];
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"updatedTransactions", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
	NSLog(@"Removed Transactions Called..");
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<transactions>"];
	NSLog(@"obj Created");
	for (SKPaymentTransaction *t in transactions)
    {
		NSMutableString* tr = generateXml(t);
		[retXML appendString:tr];
		[tr release];
		NSLog(@"Out of loop");
	}
	
	[retXML appendFormat:@"</transactions>"];
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"removedTransactions", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"Restore Error");
	
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"restoreFailed", (const uint8_t*)[[error localizedDescription] stringByAppendingFormat:@":%d",[error code]]);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
	NSLog(@"Restore Done");
	
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"restoreComplete", (const uint8_t*)"");
}

////SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
	NSLog(@"Products Received");
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<products>"];
	for (SKProduct* p in response.products) {
		[retXML appendFormat:@"<product><title>%@</title><desc>%@</desc><price>%@</price><locale>%@</locale><id>%@</id></product>",p.localizedTitle,p.localizedDescription,p.price,[p.priceLocale localeIdentifier],p.productIdentifier];
	}
	[retXML appendFormat:@"<invalid>"];
	for(NSString* s in response.invalidProductIdentifiers){ 
		[retXML appendFormat:@"<id>%@</id>",s];
	}
	[retXML appendFormat:@"</invalid></products>"]; 
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"productsReceived", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
	[request release]; 
}
@end
