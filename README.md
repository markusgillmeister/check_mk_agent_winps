Project "check_mk_agent_winps"
==============================

CheckMK agent for windows written in powershell. Goal is to realize a faster checking for Check_MK 
under windows OS due to native methods and caching. 
At the moment the agent is not a full replacement for the original windows agent but has implented
most of the features (see below for limitations).

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
|---checkmkagent.ps1        => The main agent part. 
|---config.ps1              => Config File
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
  This check uses the "Core Temp"-tool (http://www.alcpu.com/CoreTemp/) for gathering temperature information.
  For integration in the windows agent I developed a plugin for Core Temp (included in repository here). 
  Please note: Due to license restrication you have to download the "Core Temp" software by yourself and place it in the agent\components\coretemp directory.
  Do not overwrite the ini-configuration-file. Do not forget to license the tool if you are using it for commercial purpose. 
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
