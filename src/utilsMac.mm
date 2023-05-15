#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

extern "C" {    
    void fillApplicationDirectory(char* vmPath);
}

void fillApplicationDirectory(char* vmPath){
    NSURL *appFolder = [[[NSBundle mainBundle] bundleURL] URLByDeletingLastPathComponent];
    strcpy(vmPath, [appFolder fileSystemRepresentation]);
}
