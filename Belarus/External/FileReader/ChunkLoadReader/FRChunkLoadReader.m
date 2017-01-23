//
// FRChunkLoadReader.
//

#import "FRChunkLoadReader.h"
#import "NSData+FRAdditions.h"

@interface FRChunkLoadReader ()

@property (nonatomic, copy) NSString* filePath; /**< File path. */
@property (nonatomic, strong) NSFileHandle* fileHandle; /**< File handle. */
@property (nonatomic, assign) unsigned long long currentOffset; /**< Current offset is needed for forwards reading. */
@property (nonatomic, assign) unsigned long long currentInset;  /**< Current inset is needed for backwards reading. */
@property (nonatomic, assign) NSRange prevDelimiterRange;   /**< Position and length of the last delimiter. */
@property (nonatomic, assign) unsigned long long totalFileLength;   /**< Total number of bytes in file. */
@property (nonatomic, strong) NSString*	lineDelimiter;  /**< Character for line break or page break. */
@property (nonatomic, assign) NSUInteger chunkSize;

@end

@implementation FRChunkLoadReader

- (id)initWithFilePath:(NSString*)filePath {

    self = [super init];
    if (self != nil) {
        if (!filePath || [filePath length] <= 0) {
            return nil;
        }
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        if (_fileHandle == nil) {
            return nil;
        }
        // TODO: How can I use NSLineSeparatorCharacter instead of \n here?
        _lineDelimiter = @"\n";
        _filePath = filePath;
        _currentOffset = 0ULL;
        _chunkSize = 10;
        [_fileHandle seekToEndOfFile];
        _totalFileLength = [_fileHandle offsetInFile];
        _currentInset = _totalFileLength;
        _prevDelimiterRange = NSMakeRange((NSUInteger)_currentInset, 1);
    }
    return self;
}

- (NSString*)readLine
{
    if (self.isDone) {
        return nil;
    }

    NSData* newLineData = [self.lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileHandle seekToFileOffset:self.currentOffset];
    NSMutableData* currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;

    while (shouldReadMore) {
        if (self.currentOffset >= self.totalFileLength) {
            break;
        }
        NSData* chunk = [self.fileHandle readDataOfLength:self.chunkSize]; // always length = 10
        // Find the location and length of the next line delimiter.
        NSRange newLineRange = [chunk rangeOfData:newLineData];
        if (newLineRange.location != NSNotFound) {
            // Include the length so we can include the delimiter in the string.
            NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
            chunk = [chunk subdataWithRange:subDataRange];
            shouldReadMore = NO;
        }
        [currentData appendData:chunk];
        self.currentOffset += [chunk length];
    }

    NSString * line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    return line;
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
    BOOL isDone = self.totalFileLength == 0 || self.currentOffset >= self.totalFileLength;
    return isDone;
}

- (BOOL)hasMore
{
    return self.isDone == NO;
}

@end