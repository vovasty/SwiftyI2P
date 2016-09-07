//
//  i2pwrapper.c
//  SwiftyI2P
//
//  Created by Solomenchuk, Vlad on 12/18/15.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

#include "i2pwrapper.h"

#include <i2pd/Transports.h>
#include <i2pd/NetDb.h>
#include <i2pd/ClientContext.h>
#include <i2pd/Config.h>
#include <i2pd/Log.h>
#include <i2pd/I2NPProtocol.h>

extern "C" {

int i2p_init(I2PConfig cfg) {
    char socks_proxy_port_str[100];
    sprintf(socks_proxy_port_str, "--socksproxy.port=%d", cfg.socksProxyPort);

    char socks_proxy_enabled_str[100];
    sprintf(socks_proxy_enabled_str, "--socksproxy.enabled=%d", cfg.socksProxyEnabled);

    
    char http_proxy_port_str[100];
    sprintf(http_proxy_port_str, "--httpproxy.port=%d", cfg.socksProxyPort);
    
    char http_proxy_enabled_str[100];
    sprintf(http_proxy_enabled_str, "--httpproxy.enabled=%d", cfg.httpProxyEnabled);

    char *argv[] = {(char*)"i2pd", socks_proxy_port_str, socks_proxy_enabled_str, http_proxy_port_str, http_proxy_enabled_str, NULL};
    int argc = sizeof(argv) / sizeof(char*) - 1;
    
    i2p::config::Init();
    i2p::config::ParseCmdline(argc, argv);
    
    i2p::fs::DetectDataDir(cfg.datadir, true);
    i2p::fs::Init();

    i2p::config::ParseConfig("");
    i2p::config::Finalize();
    
    i2p::log::Logger().SetLogLevel("error");
    i2p::log::Logger().Ready();
    
    bool precomputation; i2p::config::GetOption("precomputation.elgamal", precomputation);
    i2p::crypto::InitCrypto (precomputation);
    i2p::context.Init ();
    
    if (cfg.port)
        i2p::context.UpdatePort (cfg.port);
    
    if (cfg.host && cfg.host[0])
        i2p::context.UpdateAddress (boost::asio::ip::address::from_string (cfg.host));
    
    bool ipv6;		i2p::config::GetOption("ipv6", ipv6);
    bool ipv4;		i2p::config::GetOption("ipv4", ipv4);
    bool transit; i2p::config::GetOption("notransit", transit);
    
    i2p::context.SetSupportsV6		 (ipv6);
    i2p::context.SetSupportsV4		 (ipv4);
    i2p::context.SetAcceptsTunnels (!transit);
    
    uint16_t transitTunnels; i2p::config::GetOption("limits.transittunnels", transitTunnels);
    i2p::SetMaxNumTransitTunnels (transitTunnels);
    
    i2p::context.SetFloodfill (true);
    
    i2p::context.SetBandwidth (i2p::data::CAPS_FLAG_EXTRA_BANDWIDTH1);
    
    std::string family; i2p::config::GetOption("family", family);
    i2p::context.SetFamily (family);
    
    return 1;
}

int i2p_start()
{
    i2p::data::netdb.Start();
    i2p::transport::transports.Start();
    i2p::tunnel::tunnels.Start();
    i2p::client::context.Start ();
    return 1;
}

int i2p_stop()
{
    i2p::client::context.Stop();
    i2p::tunnel::tunnels.Stop();
    i2p::transport::transports.Stop();
    i2p::data::netdb.Stop();
    //i2p::crypto::TerminateCrypto ();
    return 1;
}

I2PError i2p_is_reachable(const char* address) {
    i2p::data::IdentHash destination;
    if (!i2p::client::context.GetAddressBook ().GetIdentHash (address, destination)) {
        return I2PErrorUnresolvable;
    }
    
    auto leaseSet = i2p::client::context.GetSharedLocalDestination ()->FindLeaseSet (destination);
    if (leaseSet && !leaseSet->IsExpired ())
    {
        return I2PErrorOK;
    }
    else
    {
        i2p::client::context.GetSharedLocalDestination ()->RequestDestination (destination);
        return I2PErrorTryAgain;
    }
}
    
} /* extern "C" */