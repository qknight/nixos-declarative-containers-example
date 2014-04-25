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
      192.168.56.102 easterhegg14 mediawiki webservice0 webservice1 webservice2 webservice3 webservice4 
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

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;


  # we override the php version for all uses of pkgs.php with this
  #nixpkgs.config.packageOverrides = pkgs : rec {
  #  # nix-env -qa --xml | grep php
  #  php = pkgs.php53;
  #};

  # journalctl status httpd.service
  # journalctl -b -u httpd

  #services.mysql = { 
  #  enable = true;
  #  package = pkgs.mysql;
  #  rootPassword = "foobar";
  #};

  services.postgresql = {
    enable=true;
    package = pkgs.postgresql90;
    #authentication = "local all all trust";
    authentication = pkgs.lib.mkOverride 10 ''
      local mediawiki all ident map=mwusers
      local all       all ident
    '';
    identMap = ''
      mwusers root   mediawiki
      mwusers wwwrun mediawiki
    '';
  };

  services.httpd = {
    enable = true;
    enableSSL = false;
    adminAddr = "web0@example.org";
    #documentRoot = "/webroot";
    #extraModules = [ 
    #  { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; } 
    #];
    virtualHosts =
    [ 
      # webservice0 vhost
      { 
        #hostName = "webservice0";
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
        # broken: this does not work as the database has wrong credentials (at least on this system)
        serverAliases = ["webservice1"];

        extraConfig = ''
          RedirectMatch ^/$ /wiki
        '';

        extraSubservices =
        [
          {
            serviceType = "mediawiki";
            siteName = "wiki9";
          }
        ];
      }
      # webservice2 vhost
      { 
        hostName = "webservice2";
        serverAliases = ["webservice2"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          # shinken will then return either the mobile or desktop version of the webpage!
          ProxyVia Off
          ProxyPreserveHost On 

          # since on ubuntu it is disabled by default, we have to reenable it here
          # i don't want to touch /etc/apache2/mods-enabled/proxy.conf
          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.99.11:80/
          ProxyPassReverse / http://192.168.99.11:80/
        '';
      }
      ## webservice3 vhost
      { 
        hostName = "webservice3";
        serverAliases = ["webservice3"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          # shinken will then return either the mobile or desktop version of the webpage!
          ProxyVia Off
          ProxyPreserveHost On 

          # since on ubuntu it is disabled by default, we have to reenable it here
          # i don't want to touch /etc/apache2/mods-enabled/proxy.conf
          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.100.11:80/
          ProxyPassReverse / http://192.168.100.11:80/
        '';
      }
      ## webservice4 vhost
      { 
        hostName = "webservice4";
        serverAliases = ["webservice4"];
        extraConfig = ''
          # prevent a forward proxy! 
          ProxyRequests off

          # User-Agent / browser identification is used from the original client
          # shinken will then return either the mobile or desktop version of the webpage!
          ProxyVia Off
          ProxyPreserveHost On 

          # since on ubuntu it is disabled by default, we have to reenable it here
          # i don't want to touch /etc/apache2/mods-enabled/proxy.conf
          <Proxy *>
          Order deny,allow
          Allow from all
          </Proxy>

          ProxyPass / http://192.168.101.11:80/
          ProxyPassReverse / http://192.168.101.11:80/
        '';
      }
    ];
  };

  containers.web2 = {
    privateNetwork = true;
    hostAddress = "192.168.99.10";
    localAddress = "192.168.99.11";
    
    config = { config, pkgs, ... }: { 
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
          { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; }
        ];
      };
    };
  };

  containers.web3 = {
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    
    config = { config, pkgs, ... }: { 
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
        adminAddr = "web3@example.org";
        documentRoot = "/webroot";
        extraModules = [
          { name = "php5"; path = "${pkgs.php53}/modules/libphp5.so"; }
        ];
      };
    };
  };

  # broken: this does not work as the database has wrong credentials (at least on this system)
  containers.web4 = {
    privateNetwork = true;
    hostAddress = "192.168.101.10";
    localAddress = "192.168.101.11";
    
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
        adminAddr = "bob@example.org";
        documentRoot = "/webroot";

        virtualHosts =
        [ 
          # wiki.invalidmagic.de
          {
            # Note: do not forget to add a DNS entry for wiki.lastlog.de at hetzner dns settings if needed
            #hostName = "wiki.invalidmagic.de";
            serverAliases = ["mywiki"];

            extraConfig = ''
              RedirectMatch ^/$ /wiki
            '';
            extraSubservices =
            [
              {
                serviceType = "mediawiki";
                siteName = "mywiki";
              }
            ];
          }
        ];
      };
    };
  };
}
