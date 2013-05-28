maintainer       "Stefano Giaccio"
maintainer_email "stefano.giaccio@fao.org"
#license          "Apache 2.0"
description      "Installs/Configures GeoServer"
#long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

%w{ tomcat }.each do |cb|
  depends cb
end

%w{ ubuntu }.each do |os|
  supports os
end

recipe "geoserver::default", "Installs and configures GeoServer"
