Imports System
Imports System.Diagnostics
Imports System.IO

Imports System.Collections.ObjectModel


'Imports System.Windows.Forms   'for sendkeys

'Imports System.Management.Automation
'Imports System.Management.Automation.Runspaces
'Imports System.Text
'Imports System.IO

Public Class Agent
    Dim agentprocess As Process
    Dim appname As String = My.Application.Info.Title
    Dim agentlocation As String = My.Settings.AgentLocation
    'Dim PowershellExecutable As String = My.Settings.PowershellExecutable


    Declare Function GenerateConsoleCtrlEvent Lib "kernel32" ( _
                        ByVal dwCtrlEvent As Integer, _
                        ByVal dwProcessGroupId As Integer _
                        ) As Integer

    Private Const CTRL_C_EVENT As Integer = 0

    Declare Auto Function FindWindow Lib "USER32.DLL" ( _
        ByVal lpClassName As String, _
        ByVal lpWindowName As String) As IntPtr

    ' Activate an application window. 
    Declare Auto Function SetForegroundWindow Lib "USER32.DLL" _
        (ByVal hWnd As IntPtr) As Boolean


    Protected Overrides Sub OnStart(ByVal args() As String)
        Try
            ' check if directory exists
            If (Directory.Exists(agentlocation)) Then
                ' add "\" in path if needed
                If (agentlocation.Substring(agentlocation.Length - 1) <> "\") Then
                    agentlocation = agentlocation & "\"
                End If

                ' check if file exists
                If (File.Exists(agentlocation & "checkmkagent.ps1")) Then

                    Dim ProcessProperties As New ProcessStartInfo
                    ProcessProperties.FileName = "powershell.exe"
                    ProcessProperties.Arguments = ". '" & agentlocation & "checkmkagent.ps1" & "'"
                    ProcessProperties.WorkingDirectory = Chr(34) & agentlocation & Chr(34)
                    ProcessProperties.WindowStyle = ProcessWindowStyle.Hidden

                    'ProcessProperties.RedirectStandardInput = True
                    'ProcessProperties.UseShellExecute = False

                    'Dim ProcessProperties As New ProcessStartInfo
                    'ProcessProperties.FileName = PowershellExecutable
                    'ProcessProperties.Arguments = ". '" & agentlocation & "checkmkagent.ps1" & "'"
                    'ProcessProperties.WorkingDirectory = Chr(34) & agentlocation & Chr(34)
                    'ProcessProperties.WindowStyle = ProcessWindowStyle.Hidden
                    'ProcessProperties.RedirectStandardInput = True
                    'ProcessProperties.UseShellExecute = False

                    agentprocess = Process.Start(ProcessProperties)
                Else
                    writeEventLog("CheckMK Powershell file is missing. Agent can not start.", EventLogEntryType.Error)
                    Me.Stop()
                End If
            Else
                writeEventLog("CheckMK Directory config is incorrect, please check settings. Agent can not start.", EventLogEntryType.Error)
                Me.Stop()
            End If
        Catch ex As Exception
            writeEventLog("CheckMK error. Message is: " & ex.Message, EventLogEntryType.Error)
            Me.Stop()
        End Try
    End Sub

    Protected Overrides Sub OnStop()
        Try
            'SetForegroundWindow(agentprocess.Handle)
            'SendKeys.SendWait("E")
            'SendKeys.SendWait("^C")
            'agentprocess.StandardInput.AutoFlush = True
            'agentprocess.StandardInput.WriteLine("E")
            'agentprocess.StandardInput.Close()
            'GenerateConsoleCtrlEvent(CTRL_C_EVENT, agentprocess.Handle)

            'agentprocess.CloseMainWindow()
            'agentprocess.WaitForExit(5000)
            'agentprocess.CloseMainWindow()
            agentprocess.Kill()
            'agentprocess.Close()

            Dim ItemProcess() As Process = Process.GetProcessesByName("Core Temp.exe")
            If Not ItemProcess Is Nothing Then
                For Each SubProcess As Process In ItemProcess
                    SubProcess.Kill()
                Next
            End If

        Catch ex As Exception
            writeEventLog("CheckMK error. Message is: " & ex.Message, EventLogEntryType.Error)
            Me.Stop()
        End Try
    End Sub

    Private Sub writeEventLog(strText As String, evType As EventLogEntryType)
        Try
            If Not EventLog.SourceExists(appname) Then
                EventLog.CreateEventSource(appname, "Application")
            End If

            Dim evlog As New EventLog("Application", ".", appname)
            evlog.WriteEntry(strText, evType, 1200)
        Catch ex As Exception

        End Try
    End Sub

End Class
