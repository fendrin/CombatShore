#!/usr/bin/env python
# encoding: utf8
import wmldata, os, glob, sys
import re

"""
Module implementing a ASC parser in pure python.
"""

class Error(Exception):
    """
    This is a custom exception the parser throws on errors. It can display
    the position of the error as a tree of all files and macros leading to
    the error, with line numbers.
    """

    def __init__(self, parser, text):
        self.text = "%s:%d: %s" % (parser.filename, parser.line, text)
        for i in range(len(parser.texts)):
            parent = parser.texts[-1 - i]
            self.text += "\n " + " " * i + "from %s:%d" % (parent.filename, parent.line)

    def __str__(self):
        return self.text

class Parser:
    """
    The main parser class. An instance of this is needed for parsing.
    """

    class TextState:
        def __init__(self, filename, text, textpos, line, current_path):
            self.filename, self.text, self.textpos, self.line =\
                filename, text, textpos, line
            self.current_path = current_path
            
    def __init__(self):
        """
        Initialize a new ASCParser instance.

        """

        self.textpos = 0
        self.line = 1
    
        self.texts = []

        self.text = ""
        self.filename = ""

        self.current_path = "."

        # Whether to print current file and comments.
        self.verbose = True

    def read_encoded(self, filename):
        """
        Helper for gracefully handling non-utf8 files and fixing up non-unix
        line endings.
        """
        try:
            text = file(filename).read()
        except IOError:
            sys.stderr.write("Cannot open file %s!\n" % filename)
            return ""
        try:
            u = text.decode("utf8")
        except UnicodeDecodeError:
            u = text.decode("latin1")
        text = u
        text = text.replace("\r\n", "\n").replace("\t", " ").replace("\r", "\n")
        if text == "" or text[-1] != "\n":
            text += "\n"
        return text

    def parse_file(self, filename):
        """
        Set the parser to parse the given file.
        """
        text = self.read_encoded(filename)
        self.push_text(filename, text, cd = os.path.dirname(filename))

    def parse_stream(self, stream, binary = False):
        """
        Set the parser to parse from a file object.
        """
        text = stream.read()
        if not binary:
            text = text.replace("\r\n", "\n").replace("\t", " ").replace("\r", "\n")
        self.push_text("inline", text)

    def parse_text(self, text, binary = False):
        """
        Set the parser to directly parse from the given string.
        """
        if not binary:
            text = text.replace("\r\n", "\n").replace("\t", " ")
        self.push_text("inline", text)

    def push_text(self, filename, text, params = None, cd = None):
        """
        Recursively parse a sub-document, e.g. when a file is included or a
        macro is executed.
        """
        if self.verbose:
            sys.stderr.write("%s:%d: Now parsing %s.\n" % (self.filename,
                                                           self.line, filename))
        if not text: text = "\n"
        self.texts.append(self.TextState(self.filename, self.text, self.textpos,
            self.line, self.current_path))
        self.filename, self.text, self.params = filename, text, params
        self.textpos = 0
        self.line = 1
        if cd: self.current_path = cd

    def pop_text(self):
        """
        Finish the current text and return to parsing the caller.
        """
        textstate = self.texts.pop()
        self.filename, self.text, self.textpos, self.line =\
            textstate.filename, textstate.text, textstate.textpos, textstate.line
        self.current_path = textstate.current_path
        if self.verbose:
            sys.stderr.write("%s:%d: Back.\n" % (self.filename, self.line))

    def read_next(self):
        """Read the next character, taking care of \r and \t."""
        c = self.text[self.textpos]
        self.textpos += 1
        if c == "\n":
            self.line += 1
        return c

    def at_end(self):
        """
        Return True if the parser is at the very end of the input, that is the
        last character of the topmost input text has been read.
        """
        return self.textpos == len(self.text)

    def check_end(self):
        if self.textpos == len(self.text):
            if len(self.texts): self.pop_text()

    def peek_next(self):
        """Like read_next, but does not consume."""
        if self.textpos >= len(self.text):
       #     if len(self.texts):
       #         ts = self.texts[-1]
       #         if ts.textpos >= len(ts.text): return ""
       #         return ts.text[ts.textpos]
            return ""
        return self.text[self.textpos]

    def read_until(self, sep):
        """Read until a character inside the string sep is found."""
        mob = re.compile(".*?[" + sep + "]", re.S).match(self.text, self.textpos)
        if mob:
            found = mob.group(0)
            self.line += found.count("\n")
            self.textpos = mob.end(0)
            if self.textpos == len(self.text):
                if len(self.texts): self.pop_text()
            return found
        else:
            found = self.text[self.textpos:]
            self.line += found.count("\n")
            self.textpos = len(self.text)
            if len(self.texts) and not self.stay_in_file:
                self.pop_text()
                found += self.read_until(sep)
            return found

    def seek(self, sep):
        """ TODO """
        mob = re.compile(".*?[" + sep + "]", re.S).match(self.text, self.textpos)
        if mob:
            return  self.text[mob.end(0) -1]
        else:
            return None

    def read_while(self, sep):
        """Read while characters are inside the string sep."""
        text = ""
        while not self.at_end():
            c = self.peek_next()
            if not c in sep:
                return text
            c = self.read_next()
            text += c
        return text

    def skip_whitespace_and_newlines(self):
        self.read_while(" \t\r\n")

    def read_lines_until(self, string):
        """
        Read lines until one contains the given string, but throw away any
        comments.
        """
        text = ""
        in_string = False
        while 1:
            if self.at_end():
                return None
            line = self.read_until("\n")

            line_start = 0
            if in_string:
                string_end = line.find(']')
                if string_end < 0:
                    text += line
                    continue
                in_string = False
                line_start = string_end + 1

            elif line.lstrip().startswith(";"):
                comment = line.lstrip()
            else:
                continue

            quotation = line.find('[', line_start)
            while quotation >= 0:
                in_string = True
                string_end = line.find(']', quotation + 1)
                if string_end < 0: break
                line_start = string_end + 1
                in_string = False
                quotation = line.find('[', line_start)

            if not in_string:
                end = line.find(string, line_start)
                if end >= 0:
                    text += line[:end]
                    break
            text += line
        return text

    def skip_whitespace_inside_statement(self):
        self.read_while(" \t\r\n")
        if not self.at_end():
            c = self.peek_next()
            if c == "#":
                self.read_until("\n")
                self.skip_whitespace_inside_statement()

    def skip_whitespace(self):
        self.read_while(" ")

    def check_for(self, str):
        """Compare the following text with str."""
        return self.text[self.textpos:self.textpos + len(str)] == str

    def parse_string(self):
        text = ""
        #match_read_start = '['
        match_read_end = ']'
        while not self.at_end():
            text += self.read_until(match_read_end)
            if text[-1] == ']':
                if self.peek_next() == ']':
                    self.read_next()
                else:
                    return text[:-1]
            else:
                break
        raise Error(self, "Unclosed string")

    def parse_inside(self, data, c):
        variable = ""
        value = ""
        got_assign = False
        spaces = ""
        filename = "(None)"
        line = -1
        while 1:

            if c == "\n":
                break

            if c == ";":
                self.read_until("\n")
                break

            if not got_assign:
                if c == "=":                    
                    got_assign = True
                    translatable = False
                    filename = self.filename
                    line = self.line
                    self.skip_whitespace()
                elif c == "-":
                    if self.check_for(">"):
                        got_assign = True
                        translatable = False
                        filename = self.filename
                        line = self.line
                        #self.skip_whitespace()
                else:
                    variable += c
                         
            elif c == '[':
                # We want the textdomain at the beginning of the string,
                # the end of the string may be outside a macro and already
                # in another textdomain.                
                string = self.parse_string()
                value += string
                spaces = ""


            else:
                if c == " ":
                    spaces += c
                else:
                    if spaces:
                        value += spaces
                        spaces = ""
                    value += c
            if self.at_end(): break
            c = self.read_next()
        
        if not got_assign:
            raise Error(self, "= expected for \"%s\"" % variable)
            return None
        
        key = wmldata.DataText(variable.strip(), value, False)
        key.set_meta(filename, line)
        return key


    def parse_top(self, data, state = None):

        while 1:

            self.skip_whitespace_and_newlines()
            if self.at_end():
                if state:
                    raise Error(self, "Tag stack non-empty (%s) at end of data" % state)
                break

            c = self.peek_next()

            if c == ";": # comment                 
                line = self.read_until("\n")
            else:

                check_tag = self.seek("{}\n")

                if check_tag == "{": # open a tag 
                    name = self.read_until("{").strip(" {")
                    subdata = wmldata.DataSub(name)
                    subdata.set_meta(self.filename, self.line)
                    self.parse_top(subdata, name)
                    data.insert(subdata)
                elif check_tag == "}":
                    self.read_until("}")
                    name = self.read_until("\n").strip()
                    if state.lower() == name.lower():
                        return
                    raise Error(self, "Mismatched closing tag [%s], expected [%s]" % (name, state))
                else:

                    current = data 
                    while self.seek(">.=\n") == ".":
                        name = self.read_until(".").strip(".")
                        current = current.get_or_create_sub(name)
                    
                    subdata = self.parse_inside(current, self.read_next())
                    current.insert(subdata)


if __name__ == "__main__":
    import optparse, subprocess
    try: import psyco
    except ImportError: pass
    else: psyco.full()

    # Hack to make us not crash when we encounter characters that aren't ASCII
    sys.stdout = __import__("codecs").getwriter('utf-8')(sys.stdout)

    optionparser = optparse.OptionParser()
    optionparser.set_usage("usage: %prog [options] [filename]")
    optionparser.add_option("-p", "--path",  help = "specify wesnoth data path")
    optionparser.add_option("-C", "--color", action = "store_true",
        help = "use colored output")
    optionparser.add_option("-u", "--userpath",  help = "specify userdata path")
    optionparser.add_option("-e", "--execute",  help = "execute given WML")
    optionparser.add_option("-v", "--verbose", action = "store_true",
        help = "make the parser very verbose")
    optionparser.add_option("-n", "--no-macros", action = "store_true",
        help = "do not expand any macros")
    optionparser.add_option("-c", "--contents", action = "store_true",
        help = "display contents of every tag")
    optionparser.add_option("-j", "--to-json", action = "store_true",
        help = "output JSON version of tree")
    optionparser.add_option("-x", "--to-xml", action = "store_true",
        help = "output XML version of tree")
    options, args = optionparser.parse_args()

    if options.path:
        path = options.path
    else:
        try:
            p = subprocess.Popen(["wesnoth", "--path"], stdout = subprocess.PIPE)
            path = p.stdout.read().strip()
            path = os.path.join(path, "data")
        except OSError:
            sys.stderr.write("Could not determine Wesnoth path.\n")
            path = None

    ascparser = Parser(path, options.userpath)
    if options.no_macros:
        ascparser.no_macros = True

    if options.verbose:
        ascparser.verbose = True
        def gt(domain, x):
            print "gettext: '%s' '%s'" % (domain, x)
            return x
        ascparser.gettext = gt

    ascparser.do_preprocessor_logic = True

    if options.execute:
        wmlparser.parse_text(options.execute)
    elif args:
        wmlparser.parse_file(args[0])
    else:
        wmlparser.parse_stream(sys.stdin)

    data = wmldata.DataSub("WML")
    wmlparser.parse_top(data)

    if options.to_json:
        jsonify(data, True) # For more readable results
    elif options.to_xml:
        xmlify(data, True)
    else:
        data.debug(show_contents = options.contents, use_color = options.color)
