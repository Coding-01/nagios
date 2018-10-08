一、简介
Nagios是一款开源的免费网络监视工具，能有效监控Windows、Linux和Unix的主机状态，交换机路由器等网络设置，打印机等。

在系统或服务状态异常时发出邮件或短信报警，第一时间通知网站运维人员，在状态恢复后发出正常的邮件或短信通知。
Nagios是一个监视系统运行状态和网络信息的监视系统。Nagios能监视所指定的本地或远程主机以及服务，同时提供异常通知功能等。
Nagios可运行在Linux/Unix平台之上，同时提供一个可选的基于浏览器的WEB界面以方便系统管理人员查看网络状态，各种系统问题，以及日志等等。

Nagios 可以监控的功能：

    监控网络服务（SMTP、POP3、HTTP、PING等）；
    监控主机资源（处理器负荷、磁盘利用率等）；
    简单地插件设计使得用户可以方便地扩展自己服务的检测方法；
    当服务或主机问题产生与解决时将告警发送给联系人（通过EMail、短信、用户定义方式）；
    可以定义一些处理程序，使之能够在服务或者主机发生故障时起到预防作用；
    自动的日志滚动功能；
    可选的WEB界面用于查看当前的网络状态、通知和故障历史、日志文件等；

Nagios-plugins
 nagios-plugins是nagios官方提供的一套插件程序，nagios监控主机的功能其实都是通过执行插件程序来实现的。
 nagios本身并没有监控的功能，所有的监控是由插件完成的，插件将监控的结果返回给nagios，nagios分析这些结果以web的方式展现给我们，同时提供相应的报警功能。
 所有的这些插件是一些实现特定功能的可执行程序，默认安装的路径是/usr/local/nagios/libexec，可以自己查看。

二、工作流程

    NRPE

    NRPE是一款用来监控被控端主机资源的工具，没有它，nagios将无法对被控端服务器的主机资源进行监控！
    NRPE总共由两部分组成:

     check_nrpe 插件,位于在监控主机上
     NRPE daemon,运行在远程的linux主机上(通常就是被监控机)

nagios监控远程linux主机的服务或者资源的一般过程：
   1.nagios 会运行 check_nrpe 这个插件,告诉它要检查什么;
   2.check_nrpe 插件会连接到远程的 NRPE daemon ,所用的方式是SSL;
   3.NRPE daemon 会运行相应的 nagios 插件来执行检查;
   4.NRPE daemon 将检查的结果返回给 check_nrpe 插件，插件将其递交给 nagios 做处理。 
  Nagios 根据插件返回来的值，来判断监控对象的状态，并通过 web 显示出来，以供管理员及时发现故障。

nagios-plugins是nagios官方提供的一套插件程序，nagios监控主机的功能其实都是通过执行插件程序来实现

 

安装

服务端需要安装：Nagios+nagios-plugins+nrpe
客户端需要安装 ：nagios-plugins+nrpe


Nagios可以识别4种状态返回信息:
            0    (OK)        表示状态正常/绿色;
            1    (WARNING)    表示出现警告/黄色;
            2    (CRITICAL)    表示出现非常严重的错误/红色;
            3    (UNKNOWN)    表示未知错误/深黄色。

三、准备环境

  Nagios 　  版本      　　 主机名      IP                      　　运行服务        
 Server  　CentOS 6.7   CenttOS-01    192.168.0.41   　　 Nginx + Php + Nagios + Nagios-plugins + Nrpe
 Client　　CentOS 6.7   CenttOS-02    192.168.0.42     　 Nagios-plugins + Nrpe

四、开始安装
    软件版本
        nagios-4.1.1.tar.gz

#下载地址：https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.2.tar.gz#_ga=2.115671173.2044594939.1500257798-662916766.1500257798
     nagios-plugins-2.0.3.tar.gz
     nrpe-2.15.tar.gz

Nagios 服务端

1、创建用户
[root@CentOS-01 ~]# useradd nagios -s /sbin/nologin    

2、安装依赖
[root@CentOS-01 ~]# yum install -y gcc-* glibc glibc-common gd gd-devel openssl-devel httpd-tools unzip  perl perl-devel perl-Params-Validate perl-Math-Calc-Units perl-Regexp-Common perl-Class-Accessor perl-Config-Tiny perl-Nagios-Plugin.noarch perl-FCGI* perl-IO* 

3、编译安装NAGIOS
[root@CentOS-01 ~]# cd /usr/local/src/nagios/soft/
[root@CentOS-01 soft]# tar fx nagios-4.1.1.tar.gz
[root@CentOS-01 soft]# cd nagios-4.1.1
[root@CentOS-01 nagios-4.1.1]# ./configure --prefix=/usr/local/nagios
[root@CentOS-01 nagios-4.1.1]# make all
[root@CentOS-01 nagios-4.1.1]# make install
[root@CentOS-01 nagios-4.1.1]# make install-init                　　　　　## 安装NAGIOS启动管理脚本
[root@CentOS-01 nagios-4.1.1]# make install-commandmode            ## NAGIOS 目录赋权
[root@CentOS-01 nagios-4.1.1]# make install-config                　　　## 生成 NAGIOS 所有配置文件
[root@CentOS-01 nagios]# ls /usr/local/nagios/
bin  etc  libexec  sbin  share  var

       bin         可执行程序目录
       etc         配置文件目录
       libexec     插件所在目录
       sbin        CGI文件所在目录(执行外部命令所需文件)
       share       web 页面文件目录
       var         日志文件、锁文件目录

4、安装插件 nagios-plugins
[root@CentOS-01 ~]# cd /usr/local/src/nagios/soft/
[root@CentOS-01 soft]# tar fx nagios-plugins-2.0.3.tar.gz 
[root@CentOS-01 soft]# cd nagios-plugins-2.0.3
[root@CentOS-01 nagios-plugins-2.0.3]# ./configure --prefix=/usr/local/nagios
[root@CentOS-01 nagios-plugins-2.0.3]# make && make install
[root@CentOS-01 nagios]# ls /usr/local/nagios/libexec

5、安装组件 NRPE
[root@CentOS-01 ~]# cd /usr/local/src/nagios/soft/
[root@CentOS-01 soft]# tar fx nrpe-2.15.tar.gz 
[root@CentOS-01 soft]# cd nrpe-2.15
[root@CentOS-01 nrpe-2.15]# ./configure --prefix=/usr/local/nagios
[root@CentOS-01 nrpe-2.15]# make && make install
[root@CentOS-01 nrpe-2.15]# ls /usr/local/nagios/libexec/check_nrpe 
/usr/local/nagios/libexec/check_nrpe

6、配置 NAGIOS WEB 界面
[root@CentOS-01 nagios]# cd /usr/local/nginx/conf/
[root@CentOS-01 conf]# mkdir conf.d
[root@CentOS-01 conf]# cd conf.d/
[root@CentOS-01 conf.d]# htpasswd -bc /usr/local/nagios/etc/htpasswd.pwd nagios nagios_test
[root@CentOS-01 conf.d]# cat nagios.conf
        
        server {
            listen         　　   80;
            server_name    　nagios.test.com;
            root        　　　　/usr/local/nagios/share/;
            index        　　　 index.php index.html;
            access_log          logs/nagios_access.log;
            error_log            logs/nagios_error.log;
            
            ## WEB 访问限制 
            auth_basic    "Nagios Access";
            auth_basic_user_file    /usr/local/nagios/etc/htpasswd.pwd;

            ## 用户访问限制
            location / {
                allow *.*.*.*/24;
                allow *.*.*.0/24;
                deny all;
            }
            
            location ~ \.php$ {
                fastcgi_pass    127.0.0.1:9000;
                fastcgi_index    index.php;
                fastcgi_param  SCRIPT_FILENAME /usr/local/nagios/share$fastcgi_script_name;
                include            fastcgi_params;
            }
            location /nagios {
                alias /usr/local/nagios/share/;
            }
            location /cgi-bin/ {
                alias /usr/local/nagios/sbin/;
            }
            location /stylesheets {
                gzip    off;
                alias   /usr/local/nagios/share/stylesheets;
            }
            location /pub {
                gzip    off;
                alias   /usr/local/nagios/share/docs;
            }
            location ~ .*\.(cgi|pl)?$ {
                gzip            off;
                root            /usr/local/nagios/sbin;
                rewrite            ^/nagios/cgi-bin/(.*)\.cgi /$1.cgi break;
                fastcgi_pass    unix:/usr/local/nagios/perl-fcgi/perl-fcgi.sock;
                fastcgi_param    SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_index    index.cgi;
                fastcgi_param    REMOTE_USER    $remote_user;
                fastcgi_param    HTTP_ACCEPT_LANGUAGE    zh_CN;
                include            fastcgi_params;
                fastcgi_read_timeout    60;
            }
        }

      

[root@CentOS-01 conf.d]# service nginxd restart
[root@CentOS-01 conf.d]# service php-fpm restart

7、更改 NAGIOS WEB 页面布局
[root@CentOS-01 nagios]# cd /usr/local/src/nagios/soft/
[root@CentOS-01 soft]# cp vautour_style.zip /usr/local/nagios/share/
[root@CentOS-01 soft]# cp -r perl-fcgi /usr/local/nagios/
[root@CentOS-01 soft]# cd /usr/local/nagios/
[root@CentOS-01 nagios]# mkdir ./sbin/cgi-bin && cp ./sbin/*.cgi ./sbin/cgi-bin/
[root@CentOS-01 nagios]# cd share/ 
[root@CentOS-01 share]# unzip vautour_style.zip
[root@CentOS-01 share]# service nginxd restart


五、配置监控本机资源
    
1、NAGIOS 配置文件说明
[root@CentOS-01 soft]# cd /usr/local/nagios/etc/
[root@CentOS-01 etc]# ls
  cgi.cfg  htpasswd.pwd  nagios.cfg  objects  resource.cfg

      cgi.cfg              控制CGI访问的配置文件
      nagios.cfg        NAGIOS主配置文件
      resource.cfg     NAGIOS资源配置文件,又称变量文件.在该文件中定义变量，以便于其他配置文件调用。
      objects            模板配置文件目录

[root@CentOS-01 etc]# ls objects
commands.cfg contacts.cfg localhost.cfg printer.cfg switch.cfg templates.cfg timeperiods.cfg windows.cfg

       commands.cfg           命令定义配置文件，其中定义的命令可以被其他配置文件引用
       contacts.cfg           定义联系人和联系人组的配置文件
       localhost.cfg          定义监控本地主机的配置文件
       printer.cfg            定义监控打印机的一个配置文件模板，默认没有启用此文件
       switch.cfg             定义监控交换机的一个配置文件模板，默认没有启用此文件
       templates.cfg          定义主机和服务的一个模板配置文件，可以在其他配置文件中引用
       timeperiods.cfg        定义Nagios 监控时间段的配置文件
       windows.cfg            监控Windows 主机的一个配置文件模板，默认没有启用此文件

2、配置文件之间的关系
在nagios的配置过程中涉及到的几个定义有：主机、主机组，服务、服务组，联系人、联系人组，监控时间，监控命令等，从这些定义可以看出，nagios各个配置文件之间是互为关联，彼此引用的。

成功配置出一台nagios监控系统，必须要弄清楚每个配置文件之间依赖与被依赖的关系，最重要的有四点：

a: 定义监控哪些主机、主机组、服务和服务组;
b: 定义这个监控要用什么命令实现;
c: 定义监控的时间段;
d: 定义主机或服务出现问题时要通知的联系人和联系人组.

为了能更清楚的说明问题，同时也为了维护方便，建议将nagios各个定义对象创建独立的配置文件：

     创建hosts.cfg文件来定义主机和主机组
     创建services.cfg文件来定义服务
     用默认的contacts.cfg文件来定义联系人和联系人组
     用默认的commands.cfg文件来定义命令
     用默认的timeperiods.cfg来定义监控时间段
     用默认的templates.cfg文件作为资源引用文件

3、配置监控本机
[root@CentOS-01 nagios]# cd /usr/local/nagios/etc/objects/
[root@CentOS-01 objects]# vim templates.cfg
###################### 定义邮件联系人 #####################
### 定义默认邮件联系人模板
    define contact{
          name                  generic-contact
          service_notification_period     24x7
          host_notification_period        24x7
          service_notification_options    w,u,c,r
          host_notification_options       d,u,r
          service_notification_commands   notify-service-by-email
          host_notification_commands      notify-host-by-email
          register                        0
        }
#########################################################
# 定义主机模板
#########################################################
            define host{
             name     　　　　　　generic-host
             notifications_enabled          1            
             event_handler_enabled          1            
             flap_detection_enabled         1            
             process_perf_data              1            
             retain_status_information      1            
             retain_nonstatus_information   1            
             check_interval                 1     # 检查时间间隔
             retry_interval                 2   # 重试检查时间间隔
             max_check_attempts             2 # 最大检查次数(发现主机故障时,检查多少次才会通知联系人异常)
             notification_interval           　　　　  30           # 再次发出通知的时间间隔
             notification_period             　　　　 24x7        # 通知时间段
             notification_options            　　　　d,u,r        # 通知选项(d:宕机;u:未知;r:恢复)
             contact_groups                  　　　　admins    # 通知的联系人 
             register                        　　　　     0             # DONT REGISTER THIS DEFINITION - ITS NOT A REAL HOST, JUST A TEMPLATE!
            }
      define host{
            name                        linux-server
            use                    　　 generic-host        ## 引用上边定义的 generic-host 模板
            check_command               check-host-alive
            process_perf_data           1
            register                    0
            }
#########################################################
# 定义服务模板
#########################################################
define service{
               name                     generic-service
               active_checks_enabled          1
               passive_checks_enabled         1
               parallelize_check              1
               obsess_over_service            1
               check_freshness                0
               notifications_enabled          1
               event_handler_enabled          1
               flap_detection_enabled         1
               process_perf_data              1
               retain_status_information      1
               retain_nonstatus_information   1
               is_volatile                    0
               check_period                   24x7
               max_check_attempts             2
               normal_check_interval          1
               retry_check_interval           2
               contact_groups                 admins
               notification_options           w,u,c,r
               notification_interval          360
               notification_period            24x7
               register                       0
          }
####################################################
## 针对不同部门制定不同模板策略
####################################################

### 定义'DSP'组监控策略
            define service {
               name                    generic-service-dsp
               use                     generic-service         ## 引用上边定义的 generic-service 模板
               contact_groups          admins,adminsdsp
               process_perf_data      1
               register                      0
            }

####################################################
# 定义本机资源模板
####################################################
            define service {
                    name                            generic-load-service
                    use                             generic-service
                    service_description             Current Load
                    check_command                 check_nrpe!check_load
                    register                             0
            }
            define service {
                    name                           generic-mem-service
                    use                            generic-service
                    service_description             MEM Useage
                    check_command                 check_nrpe!check_mem
                    register                             0
            }
            define service {
                    name                            generic-swap-service
                    use                             generic-service
                    service_description             Swap Useage
                    check_command                 check_nrpe!check_swap
                    register                             0
            }
            define service {
                name                            generic-disk-service
                use                             generic-service
                service_description             Disk Partition
                check_command                 check_nrpe!check_disk
                register                             0
            }

        define service {
              name                                generic-iostat-service
              use                                   generic-service
              service_description             Disk Iostat
              check_command                 check_nrpe!check_iostat
              register                             0
           }
[root@CentOS-01 objects]# vim contacts.cfg
        ##################################################
        ###                          ******* 定义联系人 *******  
        ##################################################

       ### Default
        define contact{
            contact_name            nagiosadmin
            use               generic-contact        ## 引用 templates.cfg 中定义的 generic-contact 模板
             alias                          Nagios Admin
             email                         yw@dianru.com
             }
        ##################################################
        ### 定义不同组邮件联系人
        ##################################################
        ### OPS
        define contact{
             contact_name            nagios-ops
             use                           generic-contact
             alias                          Ops
             email                         yw@dianru.com         ## 定义联系人邮箱,多个逗号分隔.
            }

      #############################################
      ###               ******* 定义联系人组 *******
      #############################################

############### 定义默认邮件联系人组 ################

### Defalut Contactgroup ###
      define contactgroup{
           contactgroup_name       admins
           alias                             Nagios Administrators
           members                      nagiosadmi
           }

############### 定义不同组邮件联系人组 ###############

          ### OPS
          define contactgroup{
          contactgroup_name       adminsops
          alias                   　　　  OpsGroups
          members                       nagios-ops
          }

[root@CentOS-01 objects]# vim hosts.cfg
         #########################################
         # HOST DEFINITION 
         #########################################
         ###定义本机策略

         #host:CentOS-01 |ip:192.168.101.181 |group:localhost
         define host {
         use       　　  linux-server                  ## 引用 templates.cfg 中定义的 linux-server 模板
         host_name         CentOS-01                    ## 主机名(随意)
         alias           　　  192.168.101.181           ## 别名(随意)
         address             192.168.101.181           ## IP地址
         contact_groups  admins                  ## 联系人组名. 引用 contacts.cfg 中定义的默认联系人组
         }

        define hostgroup {
               hostgroup_name  localhost
               alias                 localhost
               members         CentOS-01                    ## 要跟 host_name 一致
         }

[root@CentOS-01 objects]# mkdir /usr/local/nagios/services/192.168.101.181 -p
[root@CentOS-01 objects]# cd /usr/local/nagios/services/192.168.101.181
[root@CentOS-01 192.168.101.181]# ls 
disk.cfg  iostat.cfg  load.cfg  mem.cfg  swap.cfg

[root@CentOS-01 192.168.101.181]# cat disk.cfg
       ####################################
       # SERVICE DEFINITION 
       ####################################

       define service {
       use         generic-disk-service        ## 引用 templates.cfg 中定义的 generic-disk-service 模板
       host_name    CentOS-01                    ## 要跟 hosts.cfg 中定义的 host_name 一致
            }
[root@CentOS-01 192.168.101.181]# cat iostat.cfg
       ####################################
       # SERVICE DEFINITION 
       ####################################

       define service {
       use       generic-iostat-service      ## 引用 templates.cfg 中定义的 generic-iostat-service 模板
       host_name    CentOS-01                    ## 要跟 hosts.cfg 中定义的 host_name 一致
       }
[root@CentOS-01 192.168.101.181]# cat load.cfg
      ####################################
      # SERVICE DEFINITION 
      ####################################

      define service {
      use          generic-load-service       ## 引用 templates.cfg 中定义的 generic-load-service 模板
      host_name    CentOS-01                    ## 要跟 hosts.cfg 中定义的 host_name 一致
      }
[root@CentOS-01 192.168.101.181]# cat mem.cfg
     ###################################
     # SERVICE DEFINITION 
     ###################################

     define service {
     use               generic-mem-service       ## 引用 templates.cfg 中定义的 generic-mem-service 模板
     host_name    CentOS-01                    ## 要跟 hosts.cfg 中定义的 host_name 一致
     }
[root@CentOS-01 192.168.101.181]# cat swap.cfg
    ##################################
    # SERVICE DEFINITION 
    ##################################
    define service {
    use               generic-swap-service      ## 引用 templates.cfg 中定义的 generic-swap-service 模板
    host_name    CentOS-01                    ## 要跟 hosts.cfg 中定义的 host_name 一致
            }
[root@CentOS-01 192.168.101.181]# cd /usr/local/nagios/etc/objects
[root@CentOS-01 objects]# vim ../nagios.cfg
        .......
        cfg_file=/usr/local/nagios/etc/objects/commands.cfg
	cfg_file=/usr/local/nagios/etc/objects/contacts.cfg
        cfg_file=/usr/local/nagios/etc/objects/timeperiods.cfg
        cfg_file=/usr/local/nagios/etc/objects/templates.cfg
        cfg_file=/usr/local/nagios/etc/objects/hosts.cfg             
        cfg_dir=/usr/local/nagios/services/192.168.101.181
        .......

vim /usr/local/nagios/etc/nrpe.cfg
	log_facility=daemon
	pid_file=/var/run/nrpe.pid
	server_port=5666
	nrpe_user=nagios
	nrpe_group=nagios
	allowed_hosts=192.168.101.181
	dont_blame_nrpe=0
	debug=0
	command_timeout=60
	connection_timeout=300
	command[check_load]=/usr/local/nagios/libexec/check_load -w 12,8,5 -c 25,20,15
	command[check_mem]=/usr/local/nagios/libexec/check_memory -w 10% -c 3%
	command[check_swap]=/usr/local/nagios/libexec/check_swap -w 20% -c 10%
	command[check_iostat]=/usr/local/nagios/libexec/check_iostat -w 10 -c 15
	command[check_disk]=/usr/local/nagios/libexec/check_disk.sh

[root@CentOS-01 nagios]# cp check_disk.sh check_memory check_iostat /usr/local/nagios/libexec/
[root@CentOS-01 nagios]# chmod 755 /usr/local/nagios/libexec/{check_disk.sh,check_memory,check_iostat}
[root@CentOS-01 nagios]# /usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
[root@CentOS-01 nagios]# service nagios restart
