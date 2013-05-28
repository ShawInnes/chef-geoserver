#
# Author:: Stefano Giaccio (<stefano.giaccio@fao.org>)
# Cookbook Name:: unredd-nfms-portal
# Definition:: geoserver
#
# (C) 2013, FAO Forestry Department (http://www.fao.org/forestry/)
#
# This application is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# version 3.0 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.


# As we might need many instances of GeoServer we are using a definition

require 'pathname'

define :geoserver do
  include_recipe "tomcat::base"

  tomcat_user = node['tomcat']['user']

  geoserver_instance_name = params[:name]
  geoserver_data_dir      = params[:data_dir]
  geoserver_log_location  = params[:log_location]
  tomcat_instance_name    = params[:tomcat_instance_name]

  geoserver_log_dir = Pathname.new(geoserver_log_location).parent.to_s


  # tomcat "pentaho" do
  #   user tomcat_user
  #   http_port  4321
  #   #version    "7"
  #   provider :tomcat
  # end

  tomcat tomcat_instance_name do
    user tomcat_user
    http_port     params[:tomcat_http_port]
    ajp_port      params[:tomcat_ajp_port]
    shutdown_port params[:tomcat_shutdown_port]
    jvm_opts [
      "-server",
      "-Xms#{params[:xms]}",
      "-Xmx#{params[:xmx]}",
      "-XX:MaxPermSize=128m",
      "-XX:PermSize=64m",
      "-XX:+UseConcMarkSweepGC",
      "-XX:NewSize=48m",
      "-Dorg.geotools.shapefile.datetime=true",
      "-DGEOSERVER_DATA_DIR=#{params[:data_dir]}",
      "-DGEOSERVER_LOG_LOCATION=#{params[:log_location]}",
      "-Duser.timezone=GMT",
      "-Djava.awt.headless=true"
    ]
    manage_config_file true
  end

  # Solve the problem described here ([FIX] GeoTools and GeoServer ( < 2.1.4) not able to load raster plugins with latest Tomcat):
  # http://geo-solutions.blogspot.it/2010/05/fix-geotools-and-geoserver-not-able-to.html
  execute "add appContextProtection attribute to #{tomcat_instance_name}" do
    tomcat_base = resources(:tomcat => tomcat_instance_name).base
    user "root"
    command <<-EOH
      sed -i 's+<Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />+<Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" appContextProtection="false"/>+g' #{tomcat_base}/conf/server.xml
    EOH
  end

#   # Create GeoServer data and log directories

  # Permission of some directories are not set correctly by the remote_directory resource
  # so set them using chown/chmod

  # directory geoserver_data_dir do
  #   owner     tomcat_user
  #   group     tomcat_user
  #   recursive true
  # end
  directory geoserver_log_dir do
    owner     tomcat_user
    group     tomcat_user
    recursive true
  end

  execute "set #{geoserver_data_dir} permissions" do
    user "root"
    command <<-EOH
      chown -R #{tomcat_user}:#{tomcat_user} #{geoserver_data_dir}
      find #{geoserver_data_dir} -type d -exec chmod 755 {} \\;
      find #{geoserver_data_dir} -type f -exec chmod 644 {} \\;
    EOH

    action :nothing
  end

  remote_directory geoserver_data_dir do
    source      "data_dir"
    #files_owner tomcat_user
    #owner       tomcat_user
    #group       tomcat_user
    #mode        "644"
    #files_owner tomcat_user
    #files_group tomcat_user
    #files_mode  "755"

    overwrite false
    purge false

    not_if { ::File.exists?(geoserver_data_dir) }

    notifies :run, resources(:execute => "set #{geoserver_data_dir} permissions")
  end

  # Set custom admin password updating the users.xml file
  template "#{geoserver_data_dir}/security/usergroup/default/users.xml" do
    source "users.xml.erb"
    owner tomcat_user
    group tomcat_user
    mode "0644"
    variables(
      :web_admin_user     => params[:web_admin_user],
      :web_admin_password => params[:web_admin_password]
    )

    action :create_if_missing
  end
  template "#{geoserver_data_dir}/security/role/default/roles.xml" do
    source "roles.xml.erb"
    owner tomcat_user
    group tomcat_user
    mode "0644"
    variables(
      :web_admin_user => params[:web_admin_user]
    )

    action :create_if_missing
  end

  # Download and deploy GeoServer
  # unredd_nfms_portal_app geoserver_instance_name do
  #   tomcat_instance tomcat_instance_name
  #   download_url    params[:download_url]
  #   user            tomcat_user
  # end

  # ark geoserver_instance_name do
  #   catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
  #   base = "#{catalina_parent}/#{tomcat_instance_name}"

  #   path ::File.join(base, 'webapps')
  #   url params[:download_url]
  #   #checksum '89ba5fde0c596db388c3bbd265b63007a9cc3df3a8e6d79a46780c1a39408cb5'
  #   action :put
  # end

  catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
  base = "#{catalina_parent}/#{tomcat_instance_name}"
  app_path = ::File.join(base, 'webapps', geoserver_instance_name + '.war')

  remote_file app_path do
    user tomcat_user
    source params[:download_url]
    mode 00644
    action :create_if_missing
  end
end
