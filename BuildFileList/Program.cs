using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BuildFileList
{
    class Program
    {
        static void Main(string[] args)
        {
            StringBuilder sb = new StringBuilder();

            DirectoryInfo di = new DirectoryInfo(@"..\Pilot-Client\bin\Release");
            FileInfo[] files = di.GetFiles("*");
            foreach(FileInfo file in files)
            {
                sb.AppendLine($"File \"..\\Pilot-Client\\bin\\Release\\{Path.GetFileName(file.FullName)}\"");
            }

            di = new DirectoryInfo(@".\Sounds");
            files = di.GetFiles("*");
            foreach (FileInfo file in files)
            {
                sb.AppendLine($"File \"Sounds\\{Path.GetFileName(file.FullName)}\"");
            }

            File.WriteAllText("files.txt", sb.ToString());
        }
    }
}
