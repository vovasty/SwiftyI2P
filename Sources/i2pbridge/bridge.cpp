//
//  Client.cpp
//
//
//  Created by Vladimir Solomenchuk on 3/6/24.
//

#include "bridge.hpp"
#include <i2pd/ClientContext.h>
#include <i2pd/ClientContext.h>
#include <i2pd/Config.h>
#import "DaemonApple.hpp"

char * char_ptr(std::string str)
{
	char* cp = new char[str.length()+1];
	strcpy(cp, str.c_str());
	return cp;
}

char * i2pd_start()
{
	return char_ptr(i2p::ios::start());
}

void i2pd_stop()
{
	i2p::ios::stop();
}


void i2pd_set_data_dir(char const * path) {
	i2p::ios::SetDataDir(path);
}

char * i2pd_get_data_dir() {
	return char_ptr(i2p::ios::GetDataDir());
}

char * i2pd_get_string_option(const char * option) {
	std::string res; i2p::config::GetOption(option, res);
	return char_ptr(res.c_str());
}

int i2pd_get_int_option(const char * option) {
	uint16_t res; i2p::config::GetOption(option, res);
	return res;
}
