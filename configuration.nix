# Edit this configuration file to define what should be installed on
# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd.kernelModules =
    [ # Specify all kernel modules that are necessary for mounting the root
      # filesystem.
      # "xfs" "ata_piix"
    ];
    
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  # Define on which hard drive you want to install Grub.
   boot.loader.grub.device = "/dev/sda";

  # networking.wireless.enable = true;  # Enables Wireless.
  networking = {
    hostName = "easterhegg14"; # Define your hostname.
    #bridges = {
    #  br0 = {
    #    interfaces = [ "enp0s3" ];
    #  };
    #};
    enableIPv6 = false;
    interfaces.enp0s3 = { 
      ipAddress = "192.168.56.102"; 
      prefixLength = 24;
    };
    defaultGateway = "192.168.56.1";
    nameservers = [ "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    extraHosts = ''
      192.168.56.102 webservice0 webservice1 webservice2 webservice3 webservice4 webservice5
    '';
  };

  # Add filesystem entries for each partition that you want to see
  # mounted at boot time.  This should include at least the root
  # filesystem.

  # fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".label = "system";

  # fileSystems."/data" =     # where you want to mount the device
  #   { device = "/dev/sdb";  # the device
  #     fsType = "ext3";      # the type of the partition
  #     options = "data=journal";
  #   };

  # List swap partitions activated at boot time.
  swapDevices =
    [ # { device = "/dev/disk/by-label/swap"; }
    ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # SECURITY WARNING SECURITY WARNING SECURITY WARNING
  #
  # do not use this in production, nixos-containers are not meant for that !!!
  #
  # SECURITY WARNING SECURITY WARNING SECURITY WARNING
  
  # for debugging use:
  #   journalctl status httpd.service
  #   journalctl -b -u httpd
  
  # and do not forget to start the containers manually (even the declarative containers)
  #
  # once you did nixos-rebuild switch; 
  # for i in `seq 1 5`; do nixos-confainter start web$i; done
  # for i in `seq 1 5`; do mkdir -p /var/lib/containers/web$i/webroot/; done
  # for i in `seq 1 5`; do echo "<?php phpinfo(); ?>" > /var/lib/containers/web$i/webroot/index.php; done
  # for i in `seq 1 5`; do echo "hello world from web$i" > /var/lib/containers/web$i/webroot/index.html; done

  services.httpd = {
    enable = true;
    enableSSL = false;
    adminAddr = "web0@example.org";
    virtualHosts =
    [ 
      # webservice0 vhost
      # index.html works, browsing to index.php shows that php is not enabled
      { 
        serverAliases = ["webservice0"];
        documentRoot = "/webroot/";
        extraConfig = ''
          <Directory "/webroot/">
            Options -Indexes
            AllowOverride None
            Order allow,deny
            Allow from all
          </Directory>

          <IfModule mod_dir.c>
          DirectoryIndex index.html
          </IfModule>
        '';
      }
      # webservice1 vhost
      { 
        hostName = "webservice1";
        serverAliases = ["webservice1"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          ProxyVia Off
          ProxyPreserveHost On 

          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.101.11:80/
          ProxyPassReverse / http://192.168.101.11:80/
        '';
      }
      ## webservice2 vhost
      { 
        hostName = "webservice2";
        serverAliases = ["webservice2"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          ProxyVia Off
          ProxyPreserveHost On 

          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.102.11:80/
          ProxyPassReverse / http://192.168.102.11:80/
        '';
      }
      # webservice3 vhost
      { 
        hostName = "webservice3";
        serverAliases = ["webservice3"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          ProxyVia Off
          ProxyPreserveHost On 

          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.103.11:80/
          ProxyPassReverse / http://192.168.103.11:80/
        '';
      }
      # webservice4 vhost
      { 
        hostName = "webservice4";
        serverAliases = ["webservice4"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          ProxyVia Off
          ProxyPreserveHost On 

          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.104.11:80/
          ProxyPassReverse / http://192.168.104.11:80/
        '';
      }
      # webservice5 vhost
      { 
        hostName = "webservice5";
        serverAliases = ["webservice5"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          ProxyVia Off
          ProxyPreserveHost On 

          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.105.11:80/
          ProxyPassReverse / http://192.168.105.11:80/
        '';
      }

    ];
  };

  containers.web1 = {
    privateNetwork = true;
    hostAddress = "192.168.101.10";
    localAddress = "192.168.101.11";
    
    config = { config, pkgs, ... }: { 
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };
      services.httpd = {
        enable = true;
        enableSSL = false;
        adminAddr = "web1@example.org";
        documentRoot = "/webroot";
        # we override the php version for all uses of pkgs.php with this, 
        #  nix-env -qa --xml | grep php
        # lists available versions of php
        extraModules = [
          { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; }
        ];
      };
    };
  };

  containers.web2 = {
    privateNetwork = true;
    hostAddress = "192.168.102.10";
    localAddress = "192.168.102.11";
    
    config = { config, pkgs, ... }: { 
      # two additional programs are installed in the environment
      environment.systemPackages = with pkgs; [
        wget
        nmap
      ];
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };
      services.httpd = {
        enable = true;
        enableSSL = false;
        adminAddr = "web2@example.org";
        documentRoot = "/webroot";
        extraModules = [
          # here we are using php-5.3.28 instead of php-5.4.23
          { name = "php5"; path = "${pkgs.php53}/modules/libphp5.so"; }
        ];
      };
    };
  };

  # container with a mediawiki instance
  containers.web3 = {
    privateNetwork = true;
    hostAddress = "192.168.103.10";
    localAddress = "192.168.103.11";
    
    config = { config, pkgs, ... }: { 
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };
      services.postgresql = {
        enable=true;
        package = pkgs.postgresql92;
        authentication = pkgs.lib.mkOverride 10 ''
          local mediawiki all ident map=mwusers
          local all all ident
        '';
        identMap = ''
          mwusers root   mediawiki
          mwusers wwwrun mediawiki
        '';
      };
      services.httpd = {
        enable = true;
        enableSSL = false;
        adminAddr = "web3@example.org";
        documentRoot = "/webroot";

        virtualHosts =
        [ 
          {
            serverAliases = ["webservice3"];

            extraConfig = ''
              RedirectMatch ^/$ /wiki
            '';
            extraSubservices =
            [
              {
                serviceType = "mediawiki";
                siteName = "webservice3";
              }
            ];
          }
        ];
      };
    };
  };

  # lighttpd hello world example
  containers.web4 = {
    privateNetwork = true;
    hostAddress = "192.168.104.10";
    localAddress = "192.168.104.11";
    config = { config, pkgs, ... }: { 
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };
      services.lighttpd = {
        enable = true;
        document-root = "/webroot";
      };
    };
  };

  # nginx hello world example
  containers.web5 = {
    privateNetwork = true;
    hostAddress = "192.168.105.10";
    localAddress = "192.168.105.11";
    config = { config, pkgs, ... }: { 
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };
      services.nginx = {
        enable = true;
        config = ''
          error_log  /webroot/error.log;
           
          events {}
           
          http {
            server {
              access_log /webroot/access.log;
              listen 80;
              root /webroot;
            }
          }
        '';
      };
    };
  };

}
