//
//  Locations.m
//  TourMyTown
//
//  Created by Michael Katz on 8/15/13.
//  Copyright (c) 2013 mikekatz. All rights reserved.
//

#import "Locations.h"
#import "Location.h"

//static NSString* const kBaseURL = @"http://localhost:3000/";
static NSString* const kBaseURL = @"lephuocdaiMacBookPro.local";
static NSString* const kLocations = @"locations";
static NSString* const kFiles = @"files";


@interface Locations ()
@property (nonatomic, strong) NSMutableArray* objects;
@end

@implementation Locations

- (id)init {
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSArray*) filteredLocations {
    return [self objects];
}

- (void) addLocation:(Location*)location {
    [self.objects addObject:location];
}

- (void)loadImage:(Location*)location{
    
}

- (void)parseAndAddLocations:(NSArray*)locations toArray:(NSMutableArray*)destinationArray {
    for (NSDictionary *item in locations) {
        Location *location = [[Location alloc] initWithDictionary:item];
        [destinationArray addObject:location];
    }
    if (self.delegate)
        [self.delegate modelUpdated];
}

- (void)import {
    // Set the GET request
    NSURL *url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Create session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Create task to get data then parse it to an array of Location
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [self parseAndAddLocations:responseArray toArray:_objects];
        }
    }];
    
    [dataTask resume];  // Start the task
}

- (void) runQuery:(NSString *)queryString {
 
}

- (void) queryRegion:(MKCoordinateRegion)region {
    
}

- (void) persist:(Location*)location{
    // Input safety check
    if (!location || location.name == nil || location.name.length == 0) {
        return;
    }
    
    // Set the URLString for the collection, in this case it is /locations
    NSString *collectionURLString = [kBaseURL stringByAppendingPathComponent:kLocations];
    
    // Route to /locations endpoint for new location which doesn't have an _id
    // Instead route to /locations/_id for existing location
    BOOL isExistingLocation = location._id != nil;
    NSURL *url = (isExistingLocation) ? [NSURL URLWithString:[collectionURLString stringByAppendingPathComponent:location._id]] :
    [NSURL URLWithString:collectionURLString];
    
    // Set the PUT or POST request with body and header
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = (isExistingLocation) ? @"PUT" : @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:location.toDictionary options:0 error:NULL];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Create sesssion
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Create data task for the request
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddLocations:responseArray toArray:_objects];
        }
    }];
    
    [dataTask resume];
}

@end















