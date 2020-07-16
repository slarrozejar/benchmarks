dotStyle
=======

Description
-----------

This tool allows to apply a style on a graph with dot format. The style(s) are applied depending on
some conditions on the edges or on the nodes of the graph and
allows to highlight some pieces of informations with the same style for different graphs. **dotStyle** is written in Python and
requires Python 3 to be executed.

Usage
-----
The style(s) can be specified in the line tool and in this case can be applied either on nodes or on edges.
It can also be specified in a json file.
The format of the json file is the following:

    {
       "style1" : {
         "object" : obj,
         "condition" : {
           attr1 : val1,
           attr2 : val2,
           ...
         },
         "dotStyle" : {
            attr1 : val1,
            attr2 : val2,
            ...
            }
        },
        "style2" : ...
    }

where *obj* can be either "node" or "edge" to specify on what the style will be applied. *attri* can be either an existing attribute in the graph or a new one. *vali* is the value *attri* should verify in the condition section, it can be a regular expression (with Python semantics). If all *attri* have value *vali* in the condition section then values *vali* from the dotStyle section will be given to the corresponding *attri*.

To execute this tool, launch the line tool:

    ./dotStyle.py [graph] [options]
    where:
        graph must be a graphviz graph with dot format
        see -h to get help on the options
        reads from standard input if no graph is provided.
