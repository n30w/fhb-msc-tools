import typing
import os

from borb.pdf import Document
from borb.pdf import PDF
from borb.toolkit import SimpleTextExtraction

from pypdf import PdfReader

def check_for_signatures(file: str) -> bool:

    # read the PDF
    doc: typing.Optional[Document] = None
    p = os.getcwd()
    with open(file, "rb") as fh:
        doc = PDF.loads(fh)

    # check whether anything has been read
    # this may fail due to IO error
    # or a corrupt PDF
    assert doc is not None

    # check whether signatures are in the PDF
    return doc.get_document_info().has_signatures()

# reads a document page. N is indexed at 1 for natural typing.
def read_doc_page(file: str, n: int):

    # read the Document
    doc: typing.Optional[Document] = None
    l: SimpleTextExtraction = SimpleTextExtraction()
    with open(file, "rb") as in_file_handle:
        doc = PDF.loads(in_file_handle, [l])

    # check whether we have read a Document
    assert doc is not None

    # print the text on the n'th Page
    print(l.get_text()[n-1])

def get_dates(file: str):
    # read the PDF
    doc: typing.Optional[Document] = None
    p = os.getcwd()
    with open(file, "rb") as fh:
        doc = PDF.loads(fh)
    
    assert doc is not None

    create_date = doc.get_document_info().get_creation_date()
    mod_date = doc.get_document_info().get_modification_date()
    b = create_date == mod_date
    print(b)

def pyPdfRead(file: str, n: int):
    reader = PdfReader(file)
    #number_of_pages = len(reader.pages)
    page = reader.pages[n-1]
    print(page.extract_text())
