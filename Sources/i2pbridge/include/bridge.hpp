//
//  Client.hpp
//
//
//  Created by Vladimir Solomenchuk on 3/6/24.
//

#ifndef bridge_hpp
#define bridge_hpp

#ifdef __cplusplus
extern "C" {
#endif

char * i2pd_start();
void i2pd_stop();
void i2pd_set_data_dir(char const * path);
char * i2pd_get_data_dir();
char * i2pd_get_string_option(const char * option);
int i2pd_get_int_option(const char * option);

#ifdef __cplusplus
}
#endif

#endif /* bridge_hpp */
