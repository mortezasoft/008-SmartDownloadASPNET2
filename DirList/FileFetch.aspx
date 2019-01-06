<%@ Page Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>

<script language="VB" runat="server">
    '------------------------------------------------------------------------+
    Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        Dim dlDir As String = "downloadfiles/"
        Dim strFileName As String = Request.QueryString("FileName")
        If (strFileName <> "") Then
            ' Once we have determined that a download was requested we need to 
            ' confirm that the FileName argument is valid and not a canonicalization 
            ' attempt. Check for Valid file name and forbid "/", "\", and ".." occurances.              ' 
            If (Regex.IsMatch(strFileName, "[/]") Or Regex.IsMatch(strFileName, "[\\]") Or _
                InStr(strFileName, "..") Or _
                Regex.IsMatch(strFileName, "^[^\\\./:\*\?\&quot;&lt;&gt;\|]{1}[^\\/:\*\?\&quot;&lt;&gt;\|]{0,254}$ ")) Then
                    
                ' NOTE: The only way we should get here is if the user is fiddling with the query string
                ' TODO: Add instrumentation to detect hacking attempts. 
            
            Else
                Dim path As String = Server.MapPath(dlDir + Request.QueryString("FileName"))
                Dim file As System.IO.FileInfo = New System.IO.FileInfo(path)
                If file.Exists Then 'set appropriate headers  
                    Response.Clear()
                    Response.AddHeader("Content-Disposition", "attachment; filename=" & file.Name)
                    Response.AddHeader("Content-Length", file.Length.ToString())
                    Response.ContentType = "application/octet-stream"
                    Response.WriteFile(file.FullName)
                    Response.End() 'if file does not exist
                Else
                    Response.Write("This file does not exist.")
                End If 'nothing in the URL as HTTP GET  
            End If
        Else
            BindFileDataToGrid("Name")
        End If
        
    End Sub

    '------------------------------------------------------------------------+
	Sub SortFileList(sender as Object, e as DataGridSortCommandEventArgs)
		BindFileDataToGrid(e.SortExpression)
	End Sub

    '------------------------------------------------------------------------+
	Sub BindFileDataToGrid(strSortField As String)
        Dim strPath As String = "downloadfiles/"

		Dim myDirInfo    As DirectoryInfo
		Dim arrFileInfo  As Array
		Dim myFileInfo   As FileInfo

		Dim filesTable   As New DataTable
		Dim myDataRow    As DataRow
		Dim myDataView   As DataView

        ' Add the clumns to the gris
		filesTable.Columns.Add("Name", Type.GetType("System.String"))
		filesTable.Columns.Add("Length", Type.GetType("System.Int32"))
		filesTable.Columns.Add("LastWriteTime", Type.GetType("System.DateTime"))
		filesTable.Columns.Add("Extension", Type.GetType("System.String"))

        ' Get Directory & File Info
		myDirInfo = New DirectoryInfo(Server.MapPath(strPath))
        arrFileInfo = myDirInfo.GetFiles()

        ' Iterate the FileInfo objects and extract te data
		For Each myFileInfo In arrFileInfo
			myDataRow = filesTable.NewRow()
			myDataRow("Name")          = myFileInfo.Name
			myDataRow("Length")        = myFileInfo.Length
			myDataRow("LastWriteTime") = myFileInfo.LastWriteTime
			myDataRow("Extension")     = myFileInfo.Extension
			
			filesTable.Rows.Add(myDataRow)
		Next myFileInfo

        ' Create a new DataView.
		myDataView = filesTable.DefaultView
		myDataView.Sort = strSortField

		' Set DataGrid's data source and data bind.
		dgFileList.DataSource = myDataView
		dgFileList.DataBind()
	End Sub

</script>

<html>
<head>
   <title>Build Dynamic File Links</title>
</head>
<body>

<form runat="server">
<asp:DataGrid id="dgFileList" runat="server"
	BorderColor           = "blue"
	CellSpacing           = 0
	CellPadding           = 2
    HeaderStyle-BackColor = "#0051E5"
    HeaderStyle-ForeColor = "#FFFFFF"
    HeaderStyle-Font-Bold = "True"
    ItemStyle-BackColor   = "silver"
    AutoGenerateColumns   = "False"
	AllowSorting          = "True"
	OnSortCommand         = "SortFileList">

	<Columns>
		<asp:HyperLinkColumn DataNavigateUrlField="Name" DataNavigateUrlFormatString="FileFetch.aspx?FileName={0}" DataTextField="Name" HeaderText="File Name:" SortExpression="Name" />
		<asp:BoundColumn DataField="Length" HeaderText="File Size (bytes):" ItemStyle-HorizontalAlign="Right" SortExpression="Length" />
		<asp:BoundColumn DataField="LastWriteTime" HeaderText="Date Created:" SortExpression="LastWriteTime" />
		<asp:BoundColumn DataField="Extension" HeaderText="File Type:" SortExpression="Extension" />
	</Columns>
</asp:DataGrid>

</form>


<hr />
</body>
</html>
