Flow for generating the PDF

- There is a controller named PDFGeneratorController and function GeneratePdfAsync in APILayer.
  -  We are using Highcharts Server Side Api to convert the Chart, line  and Bars into Images.
  -  The Highcharts give the url of the generated Image of given Bar, lines and chart
  -  We are using Itext sharp to genrate the PDF .
  -  Will append these images URL to the Gerated Pdf.

- We will call this method from UI and  able to  generate the Pdf.

