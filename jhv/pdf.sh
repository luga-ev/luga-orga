#!/bin/sh

# Vorher libreoffice starten:
# libreoffice "-accept=socket,host=127.0.0.1,port=2002,tcpNoDelay=1;urp;" -headless -nodefault -nofirststartwizard -nolockcheck -nologo -norestore

cd output
for file in *.odt; do
  echo $file
  python3 ../ooo2any.py --extension pdf --format writer_pdf_Export $file;
done

cd ..

pdftk output/*.pdf cat output output.pdf
