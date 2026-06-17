query convertFileToPdf verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text base64File? filters=trim
    text fileName? filters=trim
    text base64Image? filters=trim
  }

  stack {
    // text2pdf
    !api.lambda {
      code = """
        const PDFKit = await import('npm:pdfkit');
        const PDFDocument = PDFKit.default;
        
        const text = $input.base64File;
        
        // Create a new PDF document
        const doc = new PDFDocument();
        
        // Store chunks here
        let buffer = [];
        
        // Capture PDF output as it's generated
        doc.on('data', chunk => buffer.push(chunk));
        doc.on('end', () => {});
        
        // Add text to the document
        doc.text(text, 100, 100);
        
        // Finalize PDF file
        doc.end();
        
        // Convert to base64 once finished
        const base64String = await new Promise((resolve) => {
          doc.on('end', () => {
            const pdfData = Buffer.concat(buffer);
            const base64 = pdfData.toString('base64');
            resolve(base64);
          });
        });
        
        return base64String;
        """
      timeout = 10
    } as $x1
  
    !api.lambda {
      code = """
        try {
          const base64File = $input.base64File || $input.base64Image;
          const fileName = $input.fileName;
        
          if (!base64File) {
            throw new Error("No file data provided.");
          }
        
          if (!fileName) {
            throw new Error("No filename provided.");
          }
        
          let fileExtension = fileName.split('.').pop().toLowerCase();
        
          if (fileExtension !== 'docx' && fileExtension !== 'xlsx' && fileExtension !== 'xls') {
            throw new Error("Unsupported file type. Only docx, xlsx, and xls files are supported.");
          }
        
          const Mammoth = await import('npm:mammoth');
          const XLSX = await import('npm:xlsx');
        
          let html = '';
        
          if (fileExtension === 'docx') {
            const buffer = Buffer.from(base64File, 'base64');
            const result = await Mammoth.convertToHtml({
              buffer: buffer
            });
            html = result.value;
          } else if (fileExtension === 'xlsx' || fileExtension === 'xls') {
            const buffer = Buffer.from(base64File, 'base64');
            const workbook = XLSX.read(buffer, { type: 'buffer' });
            html = XLSX.utils.sheet_to_html(workbook.Sheets[workbook.SheetNames[0]]);
          } else {
            throw new Error("Unsupported file type.");
          }
        
          return {
            success: true,
            html: html
          };
        
        } catch (error) {
          console.error("Error converting file:", error);
          return {
            success: false,
            message: error.message || 'Failed to convert file.',
            error: error.toString()
          };
        }
        """
      timeout = 10
    } as $x2
  
    api.lambda {
      code = """
        try {
          const base64File = $input.base64File || $input.base64Image;
          const fileName = $input.fileName;
        
          if (!base64File) {
            throw new Error("No file data provided.");
          }
        
          if (!fileName) {
            throw new Error("No filename provided.");
          }
        
          let fileExtension = fileName.split('.').pop().toLowerCase();
        
          if (fileExtension !== 'docx' && fileExtension !== 'xlsx' && fileExtension !== 'xls') {
            throw new Error("Unsupported file type. Only docx, xlsx, and xls files are supported.");
          }
        
          const Mammoth = await import('npm:mammoth');
          const XLSX = await import('npm:xlsx');
        
          let html = '';
        
          if (fileExtension === 'docx') {
            const buffer = Buffer.from(base64File, 'base64');
        
            const options = {
              convertImage: Mammoth.images.imgElement(function(image) {
                return image.read("base64").then(function(imageBuffer) {
                  return {
                    src: "data:" + image.contentType + ";base64," + imageBuffer
                  };
                });
              })
            };
        
            const result = await Mammoth.convertToHtml({ buffer }, options);
            html = result.value;
        
          } else if (fileExtension === 'xlsx' || fileExtension === 'xls') {
            const buffer = Buffer.from(base64File, 'base64');
            const workbook = XLSX.read(buffer, { type: 'buffer' });
            html = XLSX.utils.sheet_to_html(workbook.Sheets[workbook.SheetNames[0]]);
          }
        
          return {
            success: true,
            html: html
          };
        
        } catch (error) {
          console.error("Error converting file:", error);
          return {
            success: false,
            message: error.message || 'Failed to convert file.',
            error: error.toString()
          };
        }
        """
      timeout = 10
    } as $x2
  }

  response = $x2
}