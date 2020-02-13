using System;
using System.IO;
using PdfiumSharp;
using Newtonsoft.Json;
namespace ConsoleApp1

{
    class Program
    {
        public class TestParams
        {

            public string pathToFile="";

        }

        public static TestParams LoadJson()
        {
            string jsonPath = Environment.GetEnvironmentVariable("JsonFilePath") as string;
            using (StreamReader r = new StreamReader(jsonPath))
            {
                string json = r.ReadToEnd();
                TestParams param = JsonConvert.DeserializeObject<TestParams>(json);
                return param;
            }

        }


        static void Main(string[] args)
        {
            Pdfium pdf = new Pdfium();

            TestParams param = LoadJson();



            //string file = path + fileName;
            string file = param.pathToFile;

            Console.WriteLine("\nOpen PDF file: " + file);

            pdf.LoadFile(file);

            Console.WriteLine("\nNumber of Pages:" + pdf.PageCount().ToString());

            var info = pdf.GetInformation();
            Console.WriteLine("\nCreator: " + info.Creator);
            Console.WriteLine("\nTitle: " + info.Title);
            Console.WriteLine("\nAuthor: " + info.Author);
            Console.WriteLine("\nSubject: " + info.Subject);
            Console.WriteLine("\nKeywords: " + info.Keywords);
            Console.WriteLine("\nProducer: " + info.Producer);
            Console.WriteLine("\nCreationDate: " + info.CreationDate);
            Console.WriteLine("\nModDate: " + info.ModificationDate);
        }

       

       
    }
}
