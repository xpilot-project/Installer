using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GetProductVersion
{
    class Program
    {
        static void Main(string[] args)
        {
            File.WriteAllText("Version.txt", $"!define Version \"{System.Diagnostics.FileVersionInfo.GetVersionInfo(@"..\Pilot-Client\bin\Release\xPilot.exe").ProductVersion}\"");
        }
    }
}
