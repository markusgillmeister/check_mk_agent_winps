Imports System.ServiceProcess

<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Agent
    Inherits System.ServiceProcess.ServiceBase

    'UserService überschreibt den Löschvorgang, um die Komponentenliste zu bereinigen.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    ' Der Haupteinstiegspunkt für den Prozess
    <MTAThread()> _
    <System.Diagnostics.DebuggerNonUserCode()> _
    Shared Sub Main()
        Dim ServicesToRun() As System.ServiceProcess.ServiceBase

        ' Innerhalb eines Prozesses können mehrere NT-Dienste ausgeführt werden. Um einen
        ' weiteren Dienst zu diesem Prozess hinzuzufügen, ändern Sie die folgende Zeile,
        ' um ein zweites Dienstobjekt zu erstellen. Zum Beispiel
        '
        '   ServicesToRun = New System.ServiceProcess.ServiceBase () {New Service1, New MySecondUserService}
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase() {New Agent}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Wird vom Komponenten-Designer benötigt.
    Private components As System.ComponentModel.IContainer

    ' Hinweis: Die folgende Prozedur ist für den Komponenten-Designer erforderlich.
    ' Das Bearbeiten ist mit dem Komponenten-Designer möglich.  
    ' Das Bearbeiten mit dem Code-Editor ist nicht möglich.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        components = New System.ComponentModel.Container()
        Me.ServiceName = "Service1"
    End Sub

End Class
