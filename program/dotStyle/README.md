dotStyle
========

Description
-----------

This tool allows to apply a style on a graph represented in the [DOT language](https://graphviz.org/doc/info/lang.html). The style can be used to highlight some pieces of informations in the nodes and edges of the graph. The style applied to the nodes and the edges can be selected using conditions on the attributes of the nodes/edges. Unconditional style can also be applied on the graph. **dotStyle** is written in Python and requires Python 3 to be executed.

Usage
-----
The style(s) can be specified as command line arguments or in a JSON file. If both are provided, the command line arguments may overwrite the style provided in the JSON file. The format of the JSON style file is described below.

To execute this tool, simply run:

    ./dotStyle.py [graph] [options]
    where:
        graph is a dot/graphviz file or - if the graph should be read from the standard input.

run command `./dotStyle.py -h` to get help on the options

Example with JSON style file
----------------------------

Here is an example of a JSON file for this tool:

    {
       "style1" : {
         "object" : "node",
         "condition" : {
           "a" : "[0-9]+",
           "b" : "3"
         },
         "dotStyle" : {
            "color" : "blue",
            "style" : "filled"
            }
        },

        "style2" : {
            "object" : "edge",
            "condition" : {
                "b" : "2"
            },
            "dotStyle" : {
                "color" : "yellow"
            }
        },

        "style3" : {
            "object" : "graph",
            "dotStyle" : {
                "label" : "Example graph",
                "fontname" : "Helvetica-Oblique",
    		    "fontsize" : "36"
            }
        }
    }

A style file is made of several style sections. Each style section has a name (*style1*, *style2* and *style3* in the example above) and is made of up to three components:
- *object* is one of "graph", "node" or "edge": it specifies on which elements of the graph the style shall be applied.
- *condition* is a list of pairs *"attribute": "expression"* that is matched by all objects of the selected type such that each attribute in the condition has a value that matches the corresponding regular expression. The regular expression should follow the Python regular expression language. As an example, *style1* above matches all nodes with an attribute *a* that contains a number and an attribute *b* which has value 3. The condition is optional for nodes and edges, and no condition shall be provided for graph. If no condition is provided, all objects of the selected type match.
- finally, *dotStyle* is a list of attributes that will be added (or modified) on the selected objects. This tool can be used to set any attribute on graphs, nodes and edges. In particular, it can be used to set [attributes recognised by the graphviz tool](https://graphviz.org/doc/info/attrs.html).

All values in the JSON style file must be strings.

As an example, consider the following dot graph:

    digraph foo {
        n1 [color=blue, b=3, a=4];
        n2 ;
        n3 [color=green, label="n3", a=3];
        n1 -> n2 [color=orchid, b=2, a=5];
        n3 -> n1 [color=cyan, b=1];
    }

The command `./dotStyle.py example.dot -s example.json` where example.dot is the graph above and example.json is the JSON style file above produces the following graph:

    digraph foo {
            graph [fontname="Helvetica-Oblique",
                   fontsize=36,
                   label="Example graph"
            ];
            n1      [a=4,
                    b=3,
                    color=blue,
                    style=filled];
            n1 -> n2        [a=5,
                    b=2,
                    color=yellow];
            n3      [a=3,
                    color=green,
                    label=n3];
            n3 -> n1        [b=1,
                    color=cyan];
    }

As specified in the JSON style file, the node n1 where *a* is a positive integer and *b* equals 3 has been colored in blue and the edge `n1 -> n2` where *b* equals 2 has been colored in yellow. The other elements remain unchanged.


Command line example
--------------------

The style can also be sepcified using the command line options `-sg` for graph, `-sn` for nodes and `-se` for edges. For instance, the following command applies the same style as the JSON style file above:
`./dotStyle.py example.dot -sg label="Example graph" fontname="Helvetica-Oblique" fontsize=36 -sn "a=[0-9]+ && b=3" color=blue style=filled -se "b=2" color=yellow`

Notice that the first argument following `-sn` or `-se` is a condition that selects the nodes/edges on which the style shall be applied. The style is specified by the next arguments. Unconditional styles are specified by the empty condition *""*. Graph style `-sg` should not be given any condition.

If both a JSON style file and command line options are provided, the command line options may overwrite the style specified in the JSON file.
