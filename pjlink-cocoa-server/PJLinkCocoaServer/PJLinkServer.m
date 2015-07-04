#import "PJLinkServer.h"
#import "GCDAsyncSocket.h"
#import "PJLinkLogging.h"
#import "PJLinkConnection.h"
#import "PJLinkConfig.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int pjlinkLogLevel = PJ_LOG_LEVEL_INFO;

@interface PJLinkServer()

@end

@implementation PJLinkServer

- (id)init
{
    if ((self = [super init]))
    {
        PJLogTrace();

        // Setup underlying dispatch queues
        _serverQueue = dispatch_queue_create("PJLinkServer", NULL);
        _connectionQueue = dispatch_queue_create("PJLinkConnection", NULL);

        _isOnServerQueueKey     = &_isOnServerQueueKey;
        _isOnConnectionQueueKey = &_isOnConnectionQueueKey;

        void* nonNullUnusedPointer = (__bridge void *)self; // Whatever, just not null

        dispatch_queue_set_specific(_serverQueue, _isOnServerQueueKey, nonNullUnusedPointer, NULL);
        dispatch_queue_set_specific(_connectionQueue, _isOnConnectionQueueKey, nonNullUnusedPointer, NULL);

        // Initialize underlying GCD based tcp socket
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_serverQueue];

        // By default bind on all available interfaces, en1, wifi etc
        _interface = nil;

        // Use a default port of 4352
        // This will allow the kernel to automatically pick an open port for us
        _port = 4352;

        // Initialize arrays to hold all the HTTP and webSocket connections
        _connections = [[NSMutableArray alloc] init];
        _connectionsLock = [[NSLock alloc] init];

        // Register for notifications of closed connections
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectionDidDie:)
                                                     name:PJLinkConnectionDidDieNotification
                                                   object:nil];

        _isRunning = NO;
	}

    return self;
}

- (void)dealloc
{
    // This is a change on master! We need this change on master.
    PJLogTrace();

    // Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Stop the server if it's running
    [self stop];

#if !OS_OBJECT_USE_OBJC
    if (_serverQueue != NULL) {
        dispatch_release(_serverQueue);
        _serverQueue = NULL;
    }
    if (_connectionQueue != NULL) {
        dispatch_release(_connectionQueue);
        _connectionQueue = NULL;
    }
#endif

    [_asyncSocket setDelegate:nil delegateQueue:NULL];
}

- (NSString *)interface
{
    __block NSString *result;

    dispatch_sync(_serverQueue, ^{
        result = _interface;
    });

    return result;
}

- (void)setInterface:(NSString *)value
{
    NSString *valueCopy = [value copy];

    dispatch_async(_serverQueue, ^{
        _interface = valueCopy;
    });
}

- (UInt16)port
{
    __block UInt16 result;

    dispatch_sync(_serverQueue, ^{
        result = _port;
    });

    return result;
}

- (UInt16)listeningPort
{
    __block UInt16 result;

    dispatch_sync(_serverQueue, ^{
        if (_isRunning) {
            result = [_asyncSocket localPort];
        } else {
            result = 0;
        }
    });

    return result;
}

- (void)setPort:(UInt16)value
{
    PJLogTrace();

    dispatch_async(_serverQueue, ^{
        _port = value;
    });
}

- (BOOL)start:(NSError **)errPtr
{
    PJLogTrace();

    __block BOOL success = YES;
    __block NSError *err = nil;

    dispatch_sync(_serverQueue, ^{ @autoreleasepool {
        
        success = [_asyncSocket acceptOnInterface:_interface port:_port error:&err];
        if (success)
        {
            PJLogInfo(@"%@: Started PJLink server on port %hu", THIS_FILE, [_asyncSocket localPort]);
            
            _isRunning = YES;
        }
        else
        {
            PJLogError(@"%@: Failed to start PJLink Server: %@", THIS_FILE, err);
        }
    }});

    if (errPtr) {
        *errPtr = err;
    }

    return success;
}

- (void)stop
{
    [self stop:NO];
}

- (void)stop:(BOOL)keepExistingConnections
{
    PJLogTrace();

    dispatch_sync(_serverQueue, ^{ @autoreleasepool {

        // Stop listening / accepting incoming connections
        [_asyncSocket disconnect];
        _isRunning = NO;
        
        if (!keepExistingConnections)
        {
            // Stop all connections the server owns
            [_connectionsLock lock];
            for (PJLinkConnection *connection in _connections)
            {
                [connection stop];
            }
            [_connections removeAllObjects];
            [_connectionsLock unlock];
        }
    }});
}

- (BOOL)isRunning
{
    __block BOOL result;

    dispatch_sync(_serverQueue, ^{
        result = _isRunning;
    });

    return result;
}

- (PJLinkConfig *)config
{
    return [[PJLinkConfig alloc] initWithServer:self queue:_connectionQueue];
}

#pragma mark - GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    PJLinkConnection* newConnection = (PJLinkConnection*) [[PJLinkConnection alloc] initWithAsyncSocket:newSocket
                                                                                          configuration:[self config]];
    [_connectionsLock lock];
    [_connections addObject:newConnection];
    [_connectionsLock unlock];

    [newConnection start];
}

#pragma mark - GCDAsyncSocket delegate methods

- (void)connectionDidDie:(NSNotification *)notification
{
    // Note: This method is called on the connection queue that posted the notification

    [_connectionsLock lock];

    PJLogTrace();
    [_connections removeObject:[notification object]];

    [_connectionsLock unlock];
}

@end
