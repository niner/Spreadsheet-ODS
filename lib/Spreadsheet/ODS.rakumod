use Libarchive::Simple;
use LibXML::Document;
use LibXML::Element;

class Spreadsheet::ODS::TableCell {
    has LibXML::Element $.element;
    method content() {
        $!element.childNodes.grep(LibXML::Element).grep(*.name eq 'text:p').map: -> LibXML::Element $element {
            $element
        };
    }
}
class Spreadsheet::ODS::TableRow {
    has LibXML::Element $.element;
    has Spreadsheet::ODS::TableCell @.cells;
    submethod TWEAK() {
        @!cells = flat $!element.childNodes.grep(LibXML::Element).grep(*.name eq 'table:table-cell').map: -> LibXML::Element $element {
            Spreadsheet::ODS::TableCell.new(:$element) xx ($element.getAttribute('table:number-columns-repeated') // 1)
        };
    }
}
class Spreadsheet::ODS::Table {
    has LibXML::Element $.element;
    has @.columns;
    has Spreadsheet::ODS::TableRow @.rows;
    submethod TWEAK() {
        @!rows = $!element.childNodes.grep(LibXML::Element).grep(*.name eq 'table:table-row').map: -> LibXML::Element $element {
            Spreadsheet::ODS::TableRow.new: :$element
        };
    }
}
class Spreadsheet::ODS::Spreadsheet {
    has LibXML::Element $.element;
    has @.tables;
    submethod TWEAK() {
        @!tables = $!element.childNodes.grep(LibXML::Element).grep(*.name eq 'table:table').map: -> LibXML::Element $element {
            Spreadsheet::ODS::Table.new: :$element
        };
    }
}
class Spreadsheet::ODS::DocumentContent {
    has LibXML::Document $!doc;
    has Spreadsheet::ODS::Spreadsheet @.spreadsheets;
    method from-xml(Str $xml) {
        my LibXML::Document $doc .= parse(:string($xml));
        my LibXML::Element $document = $doc.documentElement;
        die $document.name unless $document.name eq 'office:document-content';

        my Spreadsheet::ODS::Spreadsheet @spreadsheets;
        with $document.childNodes.list.first(*.name eq 'office:body') -> LibXML::Element $body-node {
            @spreadsheets = $body-node.childNodes.grep(*.name eq 'office:spreadsheet').map: -> LibXML::Element $element {
                Spreadsheet::ODS::Spreadsheet.new: :$element
            }
        }

        self.new(:$doc, :@spreadsheets)
    }
}
class Spreadsheet::ODS {

    #| Map of files in the decompressed archive we read from, if any.
    has Hash $!archive;

    has Spreadsheet::ODS::DocumentContent $.content;

    #| Load an ODS workbook from the file path identified by the given string.
    multi method load(Str $file --> Spreadsheet::ODS) {
        self.load($file.IO)
    }

    #| Load an ODS workbook in the specified file.
    multi method load(IO::Path $file --> Spreadsheet::ODS) {
        self.load($file.slurp(:bin))
    }

    #| Load an ODS workbook from the specified blob. This is useful in
    #| the case it was sent over the network, and so never written to disk.
    multi method load(Blob $content --> Spreadsheet::ODS) {
        my %archive = do for archive-read($content, :format<zip>) {
            .pathname => .data if .is-file
        }
        self.new(:%archive)
    }

    submethod TWEAK(Hash :$!archive) {
        with $!archive {
            with $!archive<content.xml> -> Blob $content {
                $!content = Spreadsheet::ODS::DocumentContent.from-xml($content.decode("utf-8"));
            }
        }
    }
}
