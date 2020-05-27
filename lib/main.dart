import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: imgToText(),
      ),
    );

class imgToText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: ImgText(),
    );
  }
}

class ImgText extends StatefulWidget {
  @override
  _ImgTextState createState() => _ImgTextState();
}

class _ImgTextState extends State<ImgText> {
  File gimage;
  File cimage;
  File drawnimg;

  bool nselected = true;
  bool bgselect = true;
  bool gotText = false;
  bool dispfinal = false;
  bool gg = false;
  bool cam = false;
  String str = ' ';

  Future pickFromGallery() async {
    var gtemp = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      gimage = gtemp;
      nselected = false;
      gg = true;
      cam = false;
      dispfinal = false;
    });
  }

  Future clickImage() async {
    var ctemp = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      cimage = ctemp;
      nselected = false;
      dispfinal = false;
      cam = true;
      gg = false;
    });
  }

  Future drawText() async {
    FirebaseVisionImage myImage;
    str = '';
    if (gg) {
      myImage = FirebaseVisionImage.fromFile(gimage);
    } else if (cam) {
      myImage = FirebaseVisionImage.fromFile(cimage);
    }
    TextRecognizer recognize = FirebaseVision.instance.textRecognizer();
    VisionText read = await recognize.processImage(myImage);
    setState(() {
      for (TextBlock block in read.blocks) {
        //str = str + block.text;
        for (TextLine line in block.lines) {
          //im.drawString(i, im.arial_24, 0, pos, line.text);
          str = str + line.text;
          print(line.text);
        }
      }
    });

    dispfinal = true;
  }

  Future<void> createpdf() async {
    var document = PdfDocument();
    PdfPage page = document.pages.add();
    PdfTextElement textElement = PdfTextElement(
        text: str, font: PdfStandardFont(PdfFontFamily.timesRoman, 20));

    PdfLayoutFormat layoutFormat = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage);

    PdfLayoutResult result = textElement.draw(
        page: page,
        bounds: Rect.fromLTWH(0, 0, page.getClientSize().width / 1.1,
            page.getClientSize().height),
        format: layoutFormat);

    var bytes = document.save();
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path;
    File file = File('$path/Output.pdf');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/Output.pdf');
    document.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                  child: Text('Choose from gallery'),
                  onPressed: pickFromGallery),
              SizedBox(width: 10),
              RaisedButton(
                child: Text('Click a photo'),
                onPressed: clickImage,
              ),
              SizedBox(width: 10),
            ],
          ),
          Center(
            child: Row(
              children: <Widget>[
                SizedBox(width: 10),
                RaisedButton(
                  child: Text('get text'),
                  onPressed: drawText,
                ),
                SizedBox(width: 70),
                RaisedButton(
                  child: Text('Get PDF'),
                  onPressed: createpdf,
                ),
              ],
            ),
          ),
          nselected
              ? Container()
              : (dispfinal
                  ? Expanded(
                      child: Center(
                        child: Container(
                          child: Text(str,
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                        ),
                      ),
                    )
                  : (gg
                      ? Expanded(
                          child: Container(
                              //height: 500,
                              //width: 400,
                              decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(gimage), fit: BoxFit.cover),
                          )),
                        )
                      : Expanded(
                          child: Container(
                              //height: 500,
                              //width: 400,
                              decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(cimage), fit: BoxFit.cover),
                          )),
                        )))
        ],
      ),
    );
  }
}
