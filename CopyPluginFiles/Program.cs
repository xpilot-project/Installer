using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CopyPluginFiles
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                var installFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "x-plane_install_11.txt");
                if (File.Exists(installFile))
                {
                    using (StreamReader sr = File.OpenText(installFile))
                    {
                        string xpPath = string.Empty;
                        while ((xpPath = sr.ReadLine()) != null)
                        {
                            if (Directory.Exists(Path.Combine(xpPath, "Resources")))
                            {
                                string path = Path.Combine(xpPath, @"Resources\plugins\xPilot");
                                DirectoryInfo di = Directory.CreateDirectory(path);
                                CopyFilesRecursively(new DirectoryInfo(args[0].ToString() + @"\Plugin"), di);
                            }
                        }
                    }
                }
            }
        }

        static void CopyFilesRecursively(DirectoryInfo source, DirectoryInfo target)
        {
            foreach (DirectoryInfo dir in source.GetDirectories())
                CopyFilesRecursively(dir, target.CreateSubdirectory(dir.Name));
            foreach (FileInfo file in source.GetFiles())
                file.CopyTo(Path.Combine(target.FullName, file.Name), true);
        }
    }
}
