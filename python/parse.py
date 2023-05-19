import typing
from borb.pdf import Document
from borb.pdf import PDF
from borb.toolkit import SimpleTextExtraction


def check_for_signatures(file: str) -> bool:

    # read the PDF
    doc: typing.Optional[Document] = None
    with open("input.pdf", "rb") as fh:
        doc = PDF.loads(fh)

    # check whether anything has been read
    # this may fail due to IO error
    # or a corrupt PDF
    assert doc is not None

    # check whether signatures are in the PDF
    return doc.get_document_info().has_signatures()

def read_doc_page(file: str, n: int):

    # read the Document
    doc: typing.Optional[Document] = None
    l: SimpleTextExtraction = SimpleTextExtraction()
    with open(file, "rb") as in_file_handle:
        doc = PDF.loads(in_file_handle, [l])

    # check whether we have read a Document
    assert doc is not None

    # print the text on the first Page
    print(l.get_text()[n])

def main():
    f = "python\input.pdf"
    check_for_signatures(f)
    read_doc_page(f, 0)

if __name__ == "__main__":
    main()