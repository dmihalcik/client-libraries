/*
 * Copyright 2012 Aetna, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0.html
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "HHSDrugsNDCPackagesResponseUnmarshaller.h"

@implementation HHSDrugsNDCPackagesResponseUnmarshaller

+(HHSDrugsNDCPackagesResponse *)unmarshall:(NSDictionary *)jsonObject {
    HHSDrugsNDCPackagesResponse *results = [[[HHSDrugsNDCPackagesResponse alloc] init] autorelease];
    
    if (jsonObject != nil && [jsonObject count] > 0) {
        // if we return anything other than a JKArray, make sure it's not just a message of some sort
        if (![jsonObject isKindOfClass:NSClassFromString(@"JKArray")]) {
            
            NSString *errorCode = [jsonObject objectForKey:@"errorCode"];
            NSString *message = [jsonObject objectForKey:@"message"];
            id error = [jsonObject objectForKey:@"error"];
            // error can be a string or another array
            if ([error isKindOfClass:NSClassFromString(@"JKArray")]) {
                errorCode = [error objectForKey:@"code"];
                message = [error objectForKey:@"message"];
            } 
            
            if (errorCode != nil || error != nil || message != nil) {
                if ([errorCode isEqualToString:@"000"]) {
                    // no activities for this user - return empty response
                    return results;
                } else {
                    // error retrieving data - kick up an exception
                    NSString *errorMessage = [NSString stringWithFormat:@"error retrieving HHS NDC Package data: %@ - %@", error, message];
                    [results setException:[CarePassServiceException exceptionWithMessage:errorMessage]];
                }
            } 
        } else {        // loop through the list values
            
            HHSDrugsNDCPackageResult *drugResult = [results searchResult];
            
            for (id result in jsonObject) {
                
                drugResult.ndc3Segment = [result objectForKey:@"ndc3Segment"];
                drugResult.packageDescription = [result objectForKey:@"packageDescription"];
                
                NSMutableDictionary *imprintDetails = [result objectForKey:@"imprint"];
                for (id imprintResult in imprintDetails) {
                    drugResult.imprint.size = [imprintResult objectForKey:@"size"];
                    drugResult.imprint.symbol = [imprintResult objectForKey:@"symbol"];
                    drugResult.imprint.score = [imprintResult objectForKey:@"score"];
                    drugResult.imprint.pillColor = [imprintResult objectForKey:@"pillColor"];
                    drugResult.imprint.shape = [imprintResult objectForKey:@"shape"];
                    drugResult.imprint.coating = [imprintResult objectForKey:@"coating"];
                    drugResult.imprint.textColor = [imprintResult objectForKey:@"textColor"];
                }
                
            }
        }
    }
    
    return results;
}

-(HHSDrugsNDCPackagesResponse *)response {
    if (nil == response) {
        response = [[HHSDrugsNDCPackagesResponse alloc] init];
    }
    return response;
}


-(void)dealloc {
    [response release];
    [super dealloc];
}

@end
