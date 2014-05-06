//
//  Locations.m
//  TourMyTown
//
//  Created by Michael Katz on 8/15/13.
//  Copyright (c) 2013 mikekatz. All rights reserved.
//

#import "Locations.h"
#import "Location.h"

static NSString* const kBaseURL = @"http://localhost:3000/";
//static NSString* const kBaseURL = @"lephuocdaiMacBookPro.local/3000/";
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
    
    // Set the end point for image file with id
    NSURL *url = [NSURL URLWithString:[[kBaseURL stringByAppendingPathComponent:kFiles]
                                       stringByAppendingPathComponent:location.imageId]];
    
    // Create session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Create task to get image data then notify delegate
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *fileLocation, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *imageData = [NSData dataWithContentsOfURL:fileLocation];
            UIImage *image = [UIImage imageWithData:imageData];
            if (!image) {
                NSLog(@"unable to build image");
            }
            location.image = image;
            if (self.delegate) {
                [self.delegate modelUpdated];
            }
        }
    }];
    
    [task resume];
}

- (void)parseAndAddLocations:(NSArray*)locations toArray:(NSMutableArray*)destinationArray {
    for (NSDictionary *item in locations) {
        Location *location = [[Location alloc] initWithDictionary:item];
        [destinationArray addObject:location];
        
        if (location.imageId) {
            [self loadImage:location];
        }
    }
    
    // Notify delegate
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
    
    // If there is an image, save it first
    if (location.image != nil && location.imageId == nil) {
        [self saveNewLocationImageFirst:location];
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
    
    // Create data task for the request, if success add to local
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddLocations:responseArray toArray:_objects];
        }
    }];
    
    [dataTask resume];
}

- (void)saveNewLocationImageFirst:(Location*)location {
    
    // Set the POST request with content-type
    NSURL *url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kFiles]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    
    // Creat session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Create data and upload task for the request, if success persist the new location
    NSData *bytes = UIImagePNGRepresentation(location.image);
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bytes completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil && [(NSHTTPURLResponse*)response statusCode] < 300) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            location.imageId = responseDict[@"_id"];
            [self persist:location];
        }
    }];
    [task resume];
}

@end















