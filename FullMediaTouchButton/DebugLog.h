//
//  DebugLog.h
//  FullMediaTouchButton
//
//  Created by Dennis Skinner on 5/30/18.
//  Copyright © 2018 Dennis Skinner. All rights reserved.
//

#ifdef DEBUG

#define Debug(...) NSLog(__VA_ARGS__)
#else
#define Debug(...)

#endif
