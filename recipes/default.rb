geoserver "geoserver" do
  download_url         node['geoserver']['geoserver_download_url']
  tomcat_instance_name node['geoserver']['tomcat']['instance_name']
  tomcat_http_port     node['geoserver']['tomcat']['http_port']
  tomcat_ajp_port      node['geoserver']['tomcat']['ajp_port']
  tomcat_shutdown_port node['geoserver']['tomcat']['shutdown_port']
  data_dir             node['geoserver']['data_dir']
  log_location         node['geoserver']['log_location']
  xms                  node['geoserver']['jvm']['xms']
  xmx                  node['geoserver']['jvm']['xmx']
  web_admin_password   node['geoserver']['web_admin_password']
  web_admin_user       node['geoserver']['web_admin_user']
end
