Imports CoreTemp.Plugin
Imports System.IO

Public Class CoreTempPlugin
    Implements IPlugin

    Private _CoreTempPluginProxyReference As CoreTempPluginProxy

    Private stateFile As String

    ''' <summary>
    ''' Configures this instance.
    ''' </summary>
    ''' <returns>
    ''' A <see cref="T:eConfigureStatus" />, indicating whether the configuration option has been handled or is not supported by the plugin.
    ''' </returns>
    Public Function Configure() As eConfigureStatus Implements IPlugin.Configure
        Return eConfigureStatus.Unsupported
    End Function

    ''' <summary>
    ''' Gets or sets the core temp plugin proxy reference. You should not modify this value!
    ''' </summary>
    ''' <value>The core temp plugin proxy reference.</value>
    Public Property CoreTempPluginProxyReference As CoreTempPluginProxy Implements IPlugin.CoreTempPluginProxyReference
        Get
            Return Me._CoreTempPluginProxyReference
        End Get
        Set(ByVal value As CoreTempPluginProxy)
            Me._CoreTempPluginProxyReference = value
        End Set
    End Property

    ''' <summary>
    ''' Gets the description of this plugin.
    ''' </summary>
    ''' <value>The plugin description.</value>
    Public ReadOnly Property Description As String Implements IPlugin.Description
        Get
            Return "CoreTemp Extension for monitoring in CheckMK"
        End Get
    End Property

    ''' <summary>
    ''' Gets the name of this plugin.
    ''' </summary>
    ''' <value>The plugin name.</value>
    Public ReadOnly Property Name As String Implements IPlugin.Name
        Get
            Return "CoreTempCheckMK Plugin"
        End Get
    End Property

    ''' <summary>
    ''' Removes the specified path.
    ''' </summary>
    ''' <param name="Path">The path to the folder ctaining the plugin files.</param>
    Public Sub Remove(ByVal Path As String) Implements IPlugin.Remove
        ' TODO: Implement your clean up code here.
    End Sub

    ''' <summary>
    ''' Starts this instance.
    ''' </summary>
    ''' <returns>
    ''' A <see cref="T:eStartStatus" /> which describes the start status of the plugin
    ''' </returns>
    Public Function Start() As eStartStatus Implements IPlugin.Start
        If Environment.GetEnvironmentVariable("CheckMKstateDir") <> "" Then
            Me.stateFile = Environment.GetEnvironmentVariable("CheckMKstateDir") & "\coretemp.log"
        Else
            Me.stateFile = My.Computer.FileSystem.CurrentDirectory() & "\coretemp.log"
        End If
        Return eStartStatus.Success
    End Function

    ''' <summary>
    ''' Stops this instance.
    ''' </summary>
    Public Sub [Stop]() Implements IPlugin.Stop
        ' TODO: Handle call for stopping the plugin.
    End Sub

    ''' <summary>
    ''' Updates the plugin with the data provided by Core Temp.
    ''' </summary>
    ''' <param name="Data">Core Temp's shared data.</param>
    Public Sub Update(ByVal Data As CoreTempSharedData) Implements IPlugin.Update
        Using outfile As New StreamWriter(Me.stateFile)
            For i = 0 To (Data.uiCPUCnt * Data.uiCoreCnt) - 1
                outfile.WriteLine("CPU#" & i & " " & Data.fTemp(i))
            Next
            'outfile.Write(Data.ToString())
        End Using
    End Sub

    ''' <summary>
    ''' Gets the version of this plugin.
    ''' </summary>
    ''' <value>The plugin version string.</value>
    Public ReadOnly Property Version As String Implements IPlugin.Version
        Get
            Return "1.0"
        End Get
    End Property
End Class
