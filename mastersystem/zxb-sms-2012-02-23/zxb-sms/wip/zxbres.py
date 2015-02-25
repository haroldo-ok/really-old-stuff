from version import VERSION;

import os, sys, optparse;



STANDARD_RESOURCE_TEMPLATE = """
.section "Resource: {label}" superfree
    .dw rsc_end__{label} - rsc__{label} ; Resource size
rsc__{label}:
{content}
rsc_end__{label}:
.ends

"""

TABLE_ENTRY_TEMPLATE = """
    ; {label}
    .db :rsc__{label}   ; Bank #
    .dw rsc__{label}    ; Offset
"""

WLA_INCLUDE_TEMPLATE = """
.section "Resource pointer table" free
resource_pointer_table:
    {table_entries}
.ends

{resource_entries}
"""

CONST_ENTRY_TEMPLATE = """
CONST {label} AS UINTEGER = {number}
"""



def normalize_path(path):
    return os.path.relpath(os.path.normpath(path))




class ResourceSintaxError(Exception):
    pass
    
class Resource(object):
    """Represents an resource"""

    def __init__(self, name, number, param):
        self.name = name
        self.number = number
        self._param = param

    def generate_section(self):
        """Generates the WLA-DX .section that will hold the resource"""
        return STANDARD_RESOURCE_TEMPLATE.format(
                    label = self.name,
                    content = self.generate_content())

    def generate_table_entry(self):
        """Generates the pointer table entry"""
        return TABLE_ENTRY_TEMPLATE.format(
                    label = self.name)

    def generate_include_entry(self):
        """Geneates the ZXB include file entry"""
        return CONST_ENTRY_TEMPLATE.format(
            label = self.name,
            number = self.number * 3)

    def generate_content(self):
        """Generates the textual content that represents this resource"""
        raise NotImplementedError()




class BinResource(Resource):
    """Represents a binary include resource"""

    def generate_content(self):
        """Generates the textual content that represents this resource"""
        return '\t.incbin "%s"' % normalize_path(self._param)



class Parser(object):
    """Parses the lines of the .rsc file and generates the required includes."""

    def __init__(self):
        self._types = {'bin': BinResource}
        self._resources = []

    def parse(self, lines):
        """Effects the parsing
        lines must be a list of strings.
        """

        for lin in lines:
            lin = lin.strip()
            if lin.startswith("'"):
                # Comment; do nothing.
                pass
            elif len(lin) == 0:
                # Empty; do nothing.
                pass
            else:
                # Expects a resource declaration
                res_type, res_name, params = lin.split(' ', 2)

                if res_type == None:
                    raise ResourceSintaxError('Resource type not informed.');

                if res_name == None:
                    raise ResourceSintaxError('Resource name not informed.');

                res_class = self._types[res_type]
                if res_class == None:
                    raise ResourceSintaxError('Resource type unknown: %s' %
                                              res_type)

                self._resources.append(
                    res_class(res_name, len(self._resources), params));

    def generate_wla(self):
        """Generates the contents of the WLA include file.
        Must have called parse() first.
        """
        return WLA_INCLUDE_TEMPLATE.format(
                table_entries = str.join('', [r.generate_table_entry()
                                              for r in self._resources]),
                resource_entries = str.join('', [r.generate_section()
                                                 for r in self._resources])
            )

    def generate_zxb(self):
        """Generates the contents of the ZXB include file.
        Must have called parse() first.
        """
        return str.join('', [r.generate_include_entry()
                             for r in self._resources])



class Main(object):
    """Main class"""

    def __init__(self, args):
        self._args = args

    def execute(self):
        err = self._read_arguments()
        if err > 0:
            return err

        inp = self._read_input()

        p = Parser()
        p.parse(inp)
        self._write_output(self._options.wla_file, p.generate_wla())
        self._write_output(self._options.zxb_file, p.generate_zxb())

        return 0

    def _read_input(self):
        o = open(self._options.input_file, 'r')

        try:
            inp = o.readlines()
        finally:
            o.close()

        return inp

    def _write_output(self, name, data):
        o = open(name, 'w')
        try:
            o.write(data)
        finally:
            o.close()

        return
        
    def _read_arguments(self):
        parser = self._create_option_parser()
        (options, args) = parser.parse_args()

        if len(args) != 1:
            parser.error("missing input file. (Try -h)")
            return 3

        options.input_file = os.path.basename(args[0])
        if options.zxb_file is None:
            options.zxb_file = os.path.splitext(os.path.basename(options.input_file))[0] + '.zxi'
        if options.wla_file is None:
            options.wla_file = os.path.splitext(os.path.basename(options.input_file))[0] + '.inc'

        self._options = options;
        self._args = args

        return 0

    def _create_option_parser(self):
        parser = optparse.OptionParser(usage='Usage: %prog <inputfile> [options]',
                                    version='%prog ' + VERSION,
                                    description="""Translates an .asm file generated by ZX Basic into an include file that can be used on WLA-DX.""")
        parser.add_option("--zxb", type="string", dest="zxb_file",
                help="sets ZX Basic include output file. Default is input filename with .zxi extension", default=None)
        parser.add_option("--wla", type="string", dest="wla_file",
                help="sets WLA include output file. Default is input filename with .inc extension", default=None)
        return parser
        



    
# Called when the program is invoked from the command line.
if __name__ == '__main__':
    sys.exit(Main(sys.argv).execute()) # Exit
