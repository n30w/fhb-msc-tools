from parse import *

def main():
    fdms = r"I:\Bus Serv Merch\01-MERCHANTS\American Nails\2023.FDMS Conversion\account fee code listing.pdf"
    caps = r"I:\Bus Serv Merch\01-MERCHANTS\Aloha Shoyu Company LTD\2023.FDMS conversion\CAPS fees.pdf"
    #print(check_for_signatures(f))
    #pyPdfRead(fdms, 4)
    #pyPdfRead(caps, 1)
    get_dates(fdms)

if __name__ == "__main__":
    main()