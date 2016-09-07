//
//  i2pwrapper.h
//  SwiftyI2P
//
//  Created by Solomenchuk, Vlad on 12/18/15.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

#ifndef i2pwrapper_h
#define i2pwrapper_h

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(int, I2PError) {
    I2PErrorOK,
    I2PErrorTryAgain,
    I2PErrorUnresolvable,
    I2PErrorServiceNotStarted,
    I2PErrorTimeout
};

typedef struct I2PConfig {
    const char  *host;
    const char  *datadir;
    int         port;
    int         httpProxyPort;
    int         httpProxyEnabled;
    int         socksProxyPort;
    int         socksProxyEnabled;
    int         floodfill;
} I2PConfig;

int i2p_init(I2PConfig config);
int i2p_start();
int i2p_stop();
I2PError i2p_is_reachable(const char* address);

#ifdef __cplusplus
}
#endif

#endif /* i2pwrapper_h */
