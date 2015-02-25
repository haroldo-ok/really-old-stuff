from version import VERSION

import sys, os, getpass
import re
import optparse





def coalesce( *values ):
    for f in values:
        if f is not None:
            return f




class ConversionError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)



###
WLA_INCLUDE_TEMPLATE = """

.section "ZX Basic code" free
__START_PROGRAM:
    {code}
    ret
.ends

.section "ZXB variable init values" free
ZXBASIC_USER_DATA_VALUES:
    {var_inits}    
ZXBASIC_USER_DATA_VALUES_END:
.ends


.ramsection "ZXBasic Variables" slot 3
ZXBASIC_USER_DATA ds 0
    {vars}
ZXBASIC_USER_DATA_END ds 0    
.ends

"""




###
WLA_MAIN_TEMPLATE = """
;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
	defaultslot     0
	; rom area
	slotsize        $4000
	slot            0       $0000
	slot            1       $4000
	slot            2       $8000
	; ram area
	slotsize        $2000
	slot            3       $C000
	slot            4       $E000
.endme

.rombankmap
	bankstotal {bank_count}
	banksize $4000
	banks {bank_count}
.endro

;==============================================================
; SDSC tag and SMS rom header
;==============================================================
.sdsctag {prg_version},"{prg_name}","{prg_notes}","{prg_author}"
.smstag


.include "{wla_lib_dir}boot.inc"


;==============================================================
; Includes
;==============================================================
.include "{wla_lib_dir}Useful functions.inc"
.include "{wla_lib_dir}BBC Micro font.inc"
.include "{wla_lib_dir}sprite.inc"
.include "{wla_lib_dir}resource.inc"

{code}

{resource}
"""




###
class WlaConverter(object):
    """Converts an ZXBasic .asm file into an WLA-DX .inc file.
    """

    def __init__(self, input = None):
        self.setInput(input)
        return


    # Accessors

    def setInput(self, input):
        if input == None:
            self._input = None
        else:
            self._input = [x.rstrip() for x in input]
            
        return self


    # The actual methods

    def convert(self, input = None):
        """Performs the conversion.

        Returns a converted list of strings.
        """

        if input != None:
            self.setInput(input)

        self._cleanup_source()
        self._separate_sections()
        self._generate_variables()
        
        #return self._cleaned
        #return self._data
        #return self._vars
        
        s = WLA_INCLUDE_TEMPLATE.format(
                code = str.join('\n', self._code),
                var_inits = str.join('\n', self._var_inits),
                vars = str.join('\n', self._vars)
            )
        # Converts _xxx to zb_xxx
        s = re.sub(r'(\W)(_\w+)', r'\1zb\2', s)
        return s.split('\n')


    def _cleanup_source(self):        
        """Removes all of the undesired statements

        The result is stored on self._cleaned
        """

        # (start-pattern, end-pattern, start-delta, end-delta)
        patterns = [
                (r'(?im)^\s*org\s+\d+\s*$', None, 0, 1), # org nnnn
                (r'(?im)^__START_PROGRAM:\s*$', r'(?im)^\s*ei\s*$', 0, 1), # Start of the program
                (r'(?im)^__END_PROGRAM:\s*$', r'(?im)^__CALL_BACK__:\s*$', -3, 2), # End of the program
                (r'(?im)^ZXBASIC_USER_DATA_END\s.*$', None, -1, 100) # Junk at end of file
            ]

        outp = self._input[:]
        for pat in patterns:
            sti = self._find_list_pattern(outp, pat[0])
            edi = coalesce(
                    self._find_list_pattern(outp, pat[1], sti + 1),
                    sti)

            outp[sti + pat[2] : edi + pat[3]] = []

        pat = re.compile(r'(?im)^#line\s+\d+\s*.*$')
        for i, v in enumerate(outp):
            if pat.match(v) != None:
                outp[i] = ';' + v

        self._cleaned = outp
        

    def _separate_sections(self):
        """Separates data from code

        Data is stored on self._data;
        Code is stored on self._code.
        """
        
        divider = self._find_list_pattern(self._cleaned, r'(?im)^ZXBASIC_USER_DATA:\s*$')
        self._code = self._cleaned[:divider]
        self._data = self._cleaned[divider + 1:]
        

    def _find_list_pattern(self, list, pat, start = 0):
        """Scans for the patterns on the list

        Returns the index of the first match, or None if not found.
        """

        if pat == None:
            return None;
        
        p = re.compile(pat)
        for i, v in enumerate(list[start:]):
            if p.match(v) != None:
                return start + i

        return None


    def _generate_variables(self):
        """Generate the variable declarations and initializations"""

        # TODO: This code does require some major cleanup
        
        self._vars = []
        self._var_inits = []

        var_dic = {} # Holds var size
        var_name = ''
        var_names = [] # To ensure correct order

        def create_var(name):
            global var_name
            
            var_name = name
            var_names.append(var_name)
            var_dic[var_name] = 0

        def inc_var_size(sz):
            global var_name
            
            var_dic[var_name] = var_dic[var_name] + sz

        # (regex, var-template, init-template)
        actions = [
                #labels
                (re.compile(r'(?im)^(\w+):\s*$'),
                 lambda m : create_var(m.group(1)),
                 lambda m : '; %s' % m.group(1)),
                #defb
                (re.compile(r'(?im)^\s*DEFB\s+(.*)$'),
                 lambda m : inc_var_size(len(m.group(1).strip().split(','))),
                 lambda m : '\t.db %s' % m.group(1)),
                #defw
                (re.compile(r'(?im)^\s*DEFW\s+(.*)$'),
                 lambda m : inc_var_size(len(m.group(1).strip().split(',')) * 2),
                 lambda m : '\t.dw %s' % m.group(1))
            ]

        for s in self._data:
            for rx, vfx, ifx in actions:
                m = rx.match(s)
                if m != None:
                    vfx(m)
                    self._var_inits.append(ifx(m))

        for name in var_names:
            self._vars.append('\t{0} ds {1}'.format(name, var_dic[name]))





###
class WlaProgram(object):
    """Turns an .inc generated by WlaConverter into a compilable .asm
    """

    def __init__(self,
                 input = None,
                 bank_count = 4,
                 prg_version = 0,
                 prg_name = "ZX Basic program",
                 prg_notes = "Generated by zxb2wla " + VERSION,
                 prg_author = "??",
                 wla_lib_dir = "./",
                 extra_includes = []):
        self._input = input
        self._bank_count = bank_count
        self._prg_version = prg_version
        self._prg_name = prg_name
        self._prg_notes = prg_notes
        self._prg_author = prg_author
        self._wla_lib_dir = wla_lib_dir
        self._extra_includes = extra_includes    


    def convert(self, input=None):
        """Performs the conversion"""
        if input != None:
            self._input = input

        self._code = str.join('\n', self._input)
        outp = WLA_MAIN_TEMPLATE.format(
                bank_count = self._bank_count,
                prg_version = self._prg_version,
                prg_name = self._prg_name,
                prg_notes = self._prg_notes,
                prg_author = self._prg_author,
                wla_lib_dir = self._wla_lib_dir,
                code = self._code,
                resource = str.join('\n', ['.include "%s"' % x for x in self._extra_includes])
            )
        
        return outp.split('\n')
    




###
class Main(object):
    """Reads the commandline and executes the program functions accordingly.
    """

    def __init__(self, args):
        self._args = args

    def execute(self):
        err = self._read_arguments()
        if err > 0:
            return err

        inp = self._read_input()

        zsc = WlaConverter(inp)
        outp = zsc.convert()

        iac = WlaProgram(outp,
                        bank_count = self._options.bank_count,
                        prg_version = self._options.prg_version,
                        prg_name = self._options.prg_name,
                        prg_notes = self._options.prg_notes,
                        prg_author = self._options.prg_author,
                        wla_lib_dir = self._options.wla_lib_dir,
                        extra_includes = self._options.extra_includes)
        outp = iac.convert()

        self._write_output(outp)

        return 0

    def _read_input(self):
        o = open(self._options.input_file, 'r')

        try:
            inp = o.readlines()
        finally:
            o.close()

        return inp


    def _write_output(self, data):
        o = open(self._options.output_file, 'w')
        try:
            o.write(str.join('\n', data))
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
        if options.output_file is None:
            options.output_file = os.path.splitext(os.path.basename(options.input_file))[0] + '.wla.asm'

        self._options = options;
        self._args = args

        return 0


    def _create_option_parser(self):
        parser = optparse.OptionParser(usage='Usage: %prog <inputfile> [options]',
                                    version='%prog ' + VERSION,
                                    description="""Translates an .asm file generated by ZX Basic into an include file that can be used on WLA-DX.""")
        parser.add_option("-o", "--output", type="string", dest="output_file",
                help="sets output file. Default is input filename with .wla.asm extension", default=None)
        parser.add_option("--banks", type="int", dest="bank_count",
                help="sets number of ROM banks. Default is 2", default=2)
        parser.add_option("--prg_version", type="float", dest="prg_version",
                help="sets compiled program version. Default is 0.0", default=0.0)
        parser.add_option("--prg_name", type="string", dest="prg_name",
                help="sets program name", default="ZX Basic program")
        parser.add_option("--notes", type="string", dest="prg_notes",
                help="sets program notes", default="Generated by zxb2wla " + VERSION)
        parser.add_option("--author", type="string", dest="prg_author",
                help="sets author name. Defaults to current user", default=self._get_current_user())
        parser.add_option("--lib_dir", type="string", dest="wla_lib_dir",
                help="sets WLA library dir", default=self._get_default_dir())
        parser.add_option("-i", "--includes", action="append", type="string", dest="extra_includes",
                help="additional WLA includes to add", default=[])
        return parser

    def _get_current_user(self):
        return getpass.getuser()
        
    def _get_default_dir(self):
        try:
            script_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
            return os.path.relpath(os.path.normpath(script_dir + "/../lib/wla")) + os.sep
        except:
            return "./"
        

        

##############
# Main routine
##############
if __name__ == '__main__':
    sys.exit(Main(sys.argv).execute()) # Exit
