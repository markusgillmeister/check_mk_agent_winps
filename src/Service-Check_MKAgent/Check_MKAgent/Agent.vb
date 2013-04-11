Imports System
Imports System.Diagnostics
Imports System.IO


Public Class Agent
    Dim agentprocess As Process
    Dim appname As String = My.Application.Info.Title
    Dim agentlocation As String = My.Settings.AgentLocation

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
                    ProcessProperties.Arguments = agentlocation & "checkmkagent.ps1"
                    ProcessProperties.WorkingDirectory = agentlocation
                    ProcessProperties.WindowStyle = ProcessWindowStyle.Hidden
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
            agentprocess.Kill()
        Catch ex As Exception

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
