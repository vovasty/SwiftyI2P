//
//  DaemonApple.hpp
//
//
//  Created by Vladimir Solomenchuk on 3/6/24.
//

#ifndef Daemon_hpp
#define Daemon_hpp

#include <string>

namespace i2p
{
namespace ios
{
    class DaemonApple
    {
    public:

        DaemonApple ();
        ~DaemonApple ();

        /**
         * @return success
         */
        bool init (int argc, char* argv[]);
        void start ();
        void stop ();
        void restart ();

        void setDataDir (std::string path);
    };

    /**
     * returns "ok" if daemon init failed
     * returns errinfo if daemon initialized and started okay
     */
    std::string start ();

    void stop ();

    // set datadir received from jni
    void SetDataDir (std::string jdataDir);
    // get datadir
    std::string GetDataDir (void);
    // set webconsole language
    void SetLanguage (std::string jlanguage);
}
}


#endif /* DaemonApple_hpp */
