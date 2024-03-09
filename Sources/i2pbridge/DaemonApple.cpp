//
//  bridge.cpp
//
//
//  Created by Vladimir Solomenchuk on 3/6/24.
//

#include "DaemonApple.hpp"

#include <iostream>
#include <chrono>
#include <thread>
#include <exception>
#include <boost/exception/diagnostic_information.hpp>
#include <boost/exception_ptr.hpp>
#include <i2pd/FS.h>
#include <i2pd/Daemon.h>
#include <i2pd/I18N.h>

namespace i2p
{
namespace ios
{
std::string dataDir = "";
std::string language = "";

DaemonApple::DaemonApple ()
{
}

DaemonApple::~DaemonApple ()
{
}

bool DaemonApple::init(int argc, char* argv[])
{
	return Daemon.init(argc, argv);
}

void DaemonApple::start()
{
	Daemon.start();
}

void DaemonApple::stop()
{
	Daemon.stop();
}

void DaemonApple::restart()
{
	stop();
	start();
}

void DaemonApple::setDataDir(std::string path)
{
	Daemon.setDataDir(path);
}

static DaemonApple daemon;
static char* argv[1]={strdup("tmp")};
/**
 * returns error details if failed
 * returns "ok" if daemon initialized and started okay
 */
std::string start(/*int argc, char* argv[]*/)
{
	try
	{
		{
			// make sure assets are ready before proceed
			i2p::fs::DetectDataDir(dataDir, false);
			int numAttempts = 0;
			do
			{
				if (i2p::fs::Exists (i2p::fs::DataDirPath("assets.ready"))) break; // assets ready
				numAttempts++;
				std::this_thread::sleep_for (std::chrono::seconds(1)); // otherwise wait for 1 more second
			}
			while (numAttempts <= 10); // 10 seconds max

			// Set application directory
			daemon.setDataDir(dataDir);

			bool daemonInitSuccess = daemon.init(1, argv);
			if(!daemonInitSuccess)
			{
				return "Daemon init failed";
			}

			// Set webconsole language from application
			i2p::i18n::SetLanguage(language);

			daemon.start();
		}
	}
	catch (boost::exception& ex)
	{
		std::stringstream ss;
		ss << boost::diagnostic_information(ex);
		return ss.str();
	}
	catch (std::exception& ex)
	{
		std::stringstream ss;
		ss << ex.what();
		return ss.str();
	}
	catch(...)
	{
		return "unknown exception";
	}
	return "ok";
}

void stop()
{
	daemon.stop();
}

void SetDataDir(std::string jdataDir)
{
	dataDir = jdataDir;
}

std::string GetDataDir(void)
{
	return dataDir;
}

void SetLanguage(std::string jlanguage)
{
	language = jlanguage;
}


}
}
