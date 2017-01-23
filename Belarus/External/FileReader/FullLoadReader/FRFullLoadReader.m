//
// FRFullLoadReader.
//

#import "FRFullLoadReader.h"

@interface FRFullLoadReader ()

@property (nonatomic, copy) NSString *file;
@property (nonatomic, strong) NSArray *lines;

@property (nonatomic, assign) NSUInteger currentLineIndex;

@end

@implementation FRFullLoadReader

- (instancetype)initWithFile:(NSString *)file
{
    self = [self init];
    if (self) {
        if (![self.fileManager fileExistsAtPath:file]) {
            self = nil;
        } else {
            self.file = file;
            [self setup];
        }

    }

    return self;
}

- (void)setup
{
    self.currentLineIndex = 0;
    NSString *contents = [NSString stringWithContentsOfFile:self.file encoding:NSUTF8StringEncoding error:nil];
    self.lines = [contents componentsSeparatedByString:@"\n"];
}

- (void)dealloc
{
    int i = 0; i++;
}

- (NSString *)readLine
{
    if (self.isDone) {
        return nil;
    }

    NSString *line = self.lines[self.currentLineIndex];
    self.currentLineIndex++;

    return line;
}

- (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

- (void)skipLine
{
    [self skipLines:1];
}
- (void)skipLines:(NSUInteger)numberOfLines
{
    for (NSUInteger i = 0; i < numberOfLines; i++) {
        [self readLine];
    }
}

- (BOOL)isDone
{
    return !self.hasMore;
}

- (BOOL)hasMore
{
    BOOL hasMore = self.currentLineIndex < self.lines.count;
    return hasMore;
}


@end