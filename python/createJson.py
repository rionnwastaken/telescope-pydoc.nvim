import pydoc
import sys
import io
import json
import builtins
import inspect
import re
import os
from pathlib import Path
from typing import List


script_dir = Path(__file__).parent
data_file  = script_dir.parent / "data" / "pydoc_keywords.json"

opts = {}
opts['force_write'] = False


if (len( sys.argv ) > 1):
    
    if (sys.argv[1] == '-f'):
        opts['force_write'] = True



if data_file.is_file() and opts.get('force_write') == False:
    print("Not writing")
    exit(0)




def getText(func):
    sys.stdout = buffer = io.StringIO()
    func()
    sys.stdout = sys.__stdout__  # restore stdout
    output = buffer.getvalue()
    return output


def filterLines(lines):
    filtered_lines = []
    for line in lines:
        skip = False
        l = len(line)

        if (l <=0): break



        for i in line.split():
            filtered_lines.append(i)
    return filtered_lines


H = pydoc.Helper()



v = [H.listkeywords,H.listmodules,H.listsymbols,H.listtopics]
keywords = {
        "keywords": H.listkeywords,
        "modules": H.listmodules,
        "symbols":H.listsymbols,
        "topics":H.listtopics,
        "builtins":dir(__builtins__)
    }


data = {}

# print( type(keywords['builtints']) )
# exit(0)
            
for key in keywords:
    if type(keywords[key]) == list:
        data[key] = keywords[key]
        continue

    output = getText(keywords[key])
    lines = output.split("\n")
    lines = lines[6:]
    lines =filterLines(lines)
    data[key] = lines

jason = json.dumps(data,indent=4)

with open(data_file,"w") as f:
    f.write(jason)





