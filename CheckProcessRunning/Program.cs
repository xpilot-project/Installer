using System;
using System.Diagnostics;

namespace CheckProcessRunning
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                switch (args[0].ToString().ToLower())
                {
                    case "xpilot":
                        if (Process.GetProcessesByName("xPilot").Length > 0)
                        {
                            Environment.Exit(1);
                        }
                        break;
                    case "xplane":
                        if (Process.GetProcessesByName("X-Plane").Length > 0)
                        {
                            Environment.Exit(1);
                        }
                        break;
                }
            }
        }
    }
}
