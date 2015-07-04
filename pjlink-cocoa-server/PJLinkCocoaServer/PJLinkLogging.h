/**
 * In order to provide fast and flexible logging, this project uses Cocoa Lumberjack.
 * 
 * The Google Code page has a wealth of documentation if you have any questions.
 * https://github.com/robbiehanson/CocoaLumberjack
 * 
**/

#import "DDLog.h"

// Define logging context for every log message coming from the HTTP server.
// The logging context can be extracted from the DDLogMessage from within the logging framework,
// which gives loggers, formatters, and filters the ability to optionally process them differently.

#define PJ_LOG_CONTEXT 80

// Configure log levels.

#define PJ_LOG_FLAG_ERROR   (1 << 0) // 0...00001
#define PJ_LOG_FLAG_WARN    (1 << 1) // 0...00010
#define PJ_LOG_FLAG_INFO    (1 << 2) // 0...00100
#define PJ_LOG_FLAG_VERBOSE (1 << 3) // 0...01000

#define PJ_LOG_LEVEL_OFF     0                                              // 0...00000
#define PJ_LOG_LEVEL_ERROR   (PJ_LOG_LEVEL_OFF   | PJ_LOG_FLAG_ERROR)   // 0...00001
#define PJ_LOG_LEVEL_WARN    (PJ_LOG_LEVEL_ERROR | PJ_LOG_FLAG_WARN)    // 0...00011
#define PJ_LOG_LEVEL_INFO    (PJ_LOG_LEVEL_WARN  | PJ_LOG_FLAG_INFO)    // 0...00111
#define PJ_LOG_LEVEL_VERBOSE (PJ_LOG_LEVEL_INFO  | PJ_LOG_FLAG_VERBOSE) // 0...01111

// Setup fine grained logging.
// The first 4 bits are being used by the standard log levels (0 - 3)
// 
// We're going to add tracing, but NOT as a log level.
// Tracing can be turned on and off independently of log level.

#define PJ_LOG_FLAG_TRACE   (1 << 4) // 0...10000

// Setup the usual boolean macros.

#define PJ_LOG_ERROR   (pjlinkLogLevel & PJ_LOG_FLAG_ERROR)
#define PJ_LOG_WARN    (pjlinkLogLevel & PJ_LOG_FLAG_WARN)
#define PJ_LOG_INFO    (pjlinkLogLevel & PJ_LOG_FLAG_INFO)
#define PJ_LOG_VERBOSE (pjlinkLogLevel & PJ_LOG_FLAG_VERBOSE)
#define PJ_LOG_TRACE   (pjlinkLogLevel & PJ_LOG_FLAG_TRACE)

// Configure asynchronous logging.
// We follow the default configuration,
// but we reserve a special macro to easily disable asynchronous logging for debugging purposes.

#define PJ_LOG_ASYNC_ENABLED   YES

#define PJ_LOG_ASYNC_ERROR   ( NO && PJ_LOG_ASYNC_ENABLED)
#define PJ_LOG_ASYNC_WARN    (YES && PJ_LOG_ASYNC_ENABLED)
#define PJ_LOG_ASYNC_INFO    (YES && PJ_LOG_ASYNC_ENABLED)
#define PJ_LOG_ASYNC_VERBOSE (YES && PJ_LOG_ASYNC_ENABLED)
#define PJ_LOG_ASYNC_TRACE   (YES && PJ_LOG_ASYNC_ENABLED)

// Define logging primitives.

#define PJLogError(frmt, ...)    LOG_OBJC_MAYBE(PJ_LOG_ASYNC_ERROR,   pjlinkLogLevel, PJ_LOG_FLAG_ERROR,  \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogWarn(frmt, ...)     LOG_OBJC_MAYBE(PJ_LOG_ASYNC_WARN,    pjlinkLogLevel, PJ_LOG_FLAG_WARN,   \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogInfo(frmt, ...)     LOG_OBJC_MAYBE(PJ_LOG_ASYNC_INFO,    pjlinkLogLevel, PJ_LOG_FLAG_INFO,    \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogVerbose(frmt, ...)  LOG_OBJC_MAYBE(PJ_LOG_ASYNC_VERBOSE, pjlinkLogLevel, PJ_LOG_FLAG_VERBOSE, \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogTrace()             LOG_OBJC_MAYBE(PJ_LOG_ASYNC_TRACE,   pjlinkLogLevel, PJ_LOG_FLAG_TRACE, \
                                                  PJ_LOG_CONTEXT, @"%@[%p]: %@", THIS_FILE, self, THIS_METHOD)

#define PJLogTrace2(frmt, ...)   LOG_OBJC_MAYBE(PJ_LOG_ASYNC_TRACE,   pjlinkLogLevel, PJ_LOG_FLAG_TRACE, \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)


#define PJLogCError(frmt, ...)      LOG_C_MAYBE(PJ_LOG_ASYNC_ERROR,   pjlinkLogLevel, PJ_LOG_FLAG_ERROR,   \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogCWarn(frmt, ...)       LOG_C_MAYBE(PJ_LOG_ASYNC_WARN,    pjlinkLogLevel, PJ_LOG_FLAG_WARN,    \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogCInfo(frmt, ...)       LOG_C_MAYBE(PJ_LOG_ASYNC_INFO,    pjlinkLogLevel, PJ_LOG_FLAG_INFO,    \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogCVerbose(frmt, ...)    LOG_C_MAYBE(PJ_LOG_ASYNC_VERBOSE, pjlinkLogLevel, PJ_LOG_FLAG_VERBOSE, \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define PJLogCTrace()               LOG_C_MAYBE(PJ_LOG_ASYNC_TRACE,   pjlinkLogLevel, PJ_LOG_FLAG_TRACE, \
                                                  PJ_LOG_CONTEXT, @"%@[%p]: %@", THIS_FILE, self, __FUNCTION__)

#define PJLogCTrace2(frmt, ...)     LOG_C_MAYBE(PJ_LOG_ASYNC_TRACE,   pjlinkLogLevel, PJ_LOG_FLAG_TRACE, \
                                                  PJ_LOG_CONTEXT, frmt, ##__VA_ARGS__)

