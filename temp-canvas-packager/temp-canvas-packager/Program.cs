using Microsoft.PowerPlatform.Formulas.Tools;
using System.IO;

namespace temp_canvas_packager
{
    class Program
    {
        static void Main(string[] args)
        {
            var mode = args[0].ToLower();
            if (mode == "-unpack")
            {
                string msAppPath = args[1];
                string unpackedPath = args[2];
                msAppPath = Path.GetFullPath(msAppPath);
                (CanvasDocument msApp, ErrorContainer errors) = CanvasDocument.LoadFromMsapp(msAppPath);
                msApp.SaveToSources(unpackedPath);
            }
            if (mode=="-pack")
            {
                string outFile = args[1];
                string unpackedFolder = args[2];
                (CanvasDocument msApp, ErrorContainer errors) = CanvasDocument.LoadFromSources(unpackedFolder);
                msApp.SaveToMsApp(outFile);
            }            
        }
    }
}
