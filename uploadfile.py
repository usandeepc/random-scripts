"""python based cgi script to upload file to apache web server"""
import cgi
import cgitb
import os

cgitb.enable()
form = cgi.FieldStorage()
# Get filename here.
fileitem = form['filename']
# Test if the file was uploaded
if fileitem.filename:
    # strip leading path from file name to avoid
    # directory traversal attacks
    fn = os.path.basename(fileitem.filename)
    open('/tmp/' + fn, 'wb').write(fileitem.file.read())
    message = 'The file "' + fn + '" was uploaded successfully'
else:
    message = 'No file was uploaded'
print("Content-Type: text/plain\n\n")
print(message)
#   Upload using Curl
#   curl -F filename=@node_exporter-0.18.1.linux-amd64.tar.gz http://192.168.
#   224.198/cgi-bin/uploadfile.py
