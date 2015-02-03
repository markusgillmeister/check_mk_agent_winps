Project "check_mk_agent_winps"
==============================

CheckMK agent for windows written in powershell. 

Goals
-----
- faster checking than native CheckMK agent
- intelligent plugins: the plugin itself tests if the check can run on the client
  (with the native agent and plugins you have to select wisely and consider
   OS version, language, roles etc.)
- use powershell methods as much as possible
- caching of some check outputs (like windows updates)
- compatible to the native agent
- auto-update of agent without extra deployment systems

At the moment the agent is not a full replacement for the original windows agent
but has implented most of the features (see below for limitations).

Feel free to use it and report feedback.


News/Updates
------------

<pre>
2013-04-15  added output for "TCP Connections"-check
2013-04-11  initial start
2014-09-13  many improvements:
            - agent auto-update feature (lightweight)
            - temperature monitoring 
            - stability improvements
            - eventlog monitoring (still working on that)
2015-02-03  next milestone:
            - Temperature monitoring: exchanged CoreTemp with OpenHardwareMonitor
            - Windows Service: exchanged selfwritten service wrapper with NSSM 
              (Non Sucking Service Manager)
            - improved auto-update
            - mk_inventory feature implemented
</pre>


Overview directory structure
--------------------------------
<pre>
|-agent/                    => Windows agent
|---checks/                 => Directory with ps1-files. All files will be called by agent
|---components/             => Addons/Scripts which can be executed by checks
|---service/                => A compiled exe which can be installed as windows service
|---state/                  => Directory for temporary files of checks
|---tools/                  => Small scripts (e.g. to open firewall ports)
|---autoupgrade.ps1         => Automatic upgrade script
|---checkmkagent.ps1        => The main agent part. 
|---config.ps1              => Config File
|---install.ps1             => Installs the service
|---uninstall.ps1           => Uninstalls the service
|-checks/                   => Server-side checks
|-src/                      => Sourcecode for sub-projects
|---Service-Check_MKAgent/  => Visual Studio sourcecode of windows service 
</pre>


Capabilities
------------
Unless not mentioned all of the listed checks adapt the behavior of the original checkMK agent.

- CPU Utilization
- Disk I/O
- Disk Utilization
- Eventlog-Monitoring
   * at the moment there is no configuration option in config file. Filtering is done in check
- Memory Utilization
- MK_Inventory
- MSSQL-Server 
   * should work on all mssql versions beginning from 2008
   * works on normal, clustered and failover machines. In last case the agent tries to get information
     from active partner.
   * gets DB-sizes, backup-timestamp and mssql version
- Process list
- Scheduled Tasks
  This checks does currently not exist in original checkMK agent. It collects information of scheduled tasks
  in the system and reports back if jobs failed running. The serverside check-script is in /checks/-directory.
- Temperature Monitoring
  This check uses the "OpenHardwareMonitor"-tool (http://openhardwaremonitor.org/) for gathering temperature information.
- Windows Service
- Systemtime (NTP)
- System-Uptime
- Windows Updates
  The check gathers windows updates which must be installed on the machine. Due to the fact that the checks is
  time-intensive (>10 seconds) the check will be performed only every 24 hours or after the start of the agent. (caching feature)
- TCP connections
  
  
Note: Checks which cannot run on every machine (e.g. mssql) are written "intelligent": They don't provide any 
output or error if they cannot be used (so you don't have to delete the checks on particular machines).

Note: The "only_from"-parameter in the original agent is not part of this agent. I advise you to restrict access
via windows firewall which can be set via script (see tools-directory) or via GPO if you have an Active Directory.


ToDo-List
---------

- improve eventlog monitoring
- further checks for windows systems (dfs, exchange....)
- classical mrpe-checks (perhaps)
