using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using Xunit;
using PdfiumSharp;
using Newtonsoft.Json;


namespace PDFiumSharp.Test
{


    
    public class PdfiumTest
        {
        
        public Pdfium pdf;

        [Theory]
        [InlineData(1000)]
        public void TestMethod1(int val)
        {


            Assert.Equal(val, PageCount());
        }



        [Fact]
        public void ParserImageTest()
        {
            Image i = ReturnImage();
            Assert.Equal((ImageFormat.MemoryBmp), i.RawFormat);

            i.Dispose();

        }

        public  void SetupPDF()
        {
            pdf = new Pdfium();
            TestParams filePath = LoadJson();
            string file = filePath.pathToFile;
            Console.WriteLine("\nOpen PDF file: " + file);

            pdf.LoadFile(file);
        }

       public int PageCount()
        {
            SetupPDF();
            int pageCount = 0;
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
                pageCount = pdf.PageCount();
            

            return pageCount;
        }

        public Image ReturnImage()
        {
            SetupPDF();
            Image i = null;
                int pageNumber = 1;
                int width = 460;
                int height = 520;
                int dpiX = 460;
                int dpiY = 520;
                i= pdf.Render(pageNumber, width, height, dpiX, dpiY); 
           


            return i;

        }

        public static TestParams LoadJson()
        {
            //dotnet test �̏ꍇ
            string jsonPath = Environment.GetEnvironmentVariable("JsonFilePath") ;

            //dotnet vstest �̏ꍇ
            if (jsonPath == null)
            {
                jsonPath = "C:/Users/KINU04/Desktop/AllAckahProjs_2019/FreshStartMorisawa/testparams.json";
            }

            using (StreamReader r = new StreamReader(jsonPath))
            {
                string json = r.ReadToEnd();
                TestParams param=JsonConvert.DeserializeObject<TestParams>(json);
                return param;
            }
           
        }

        public class TestParams
        {
           
            public string pathToFile;
            
        }
        }
    }

