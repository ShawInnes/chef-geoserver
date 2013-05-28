# Download URLs
default['geoserver']['geoserver_download_url']  = 'http://nfms4redd.org/downloads/geoserver/geoserver-2.2+gdal+pyramid+flow.war'

default['geoserver']['root_dir']                = '/var'
default['geoserver']['tomcat']['instance_name'] = 'stg_geoserver'
default['geoserver']['tomcat']['http_port']     = 8201
default['geoserver']['tomcat']['ajp_port']      = 8101
default['geoserver']['tomcat']['shutdown_port'] = 8021
default['geoserver']['jvm']['xms']              = '1024m'
default['geoserver']['jvm']['xmx']              = '1024m'
default['geoserver']['data_dir']                = '/var/stg_geoserver/data'
default['geoserver']['log_location']            = '/var/stg_geoserver/logs/geoserver.log'
default['geoserver']['web_admin_user']          = 'admin'
default['geoserver']['web_admin_password']      = 'Unr3dd'
