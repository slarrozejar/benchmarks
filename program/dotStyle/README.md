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

To execute this tool, launch the line tool:

    ./dotStyle.py [graph] [options]
    where:
        graph must be a graphviz graph with dot format
        see -h to get help on the options
        reads from standard input if no graph is provided.

Example with json file
----------------------

Here is an example of a json file for this tool:

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
        }
    }

*object* can be either "node" or "edge", it specifies on which elements of the graph the style will be applied.
The elements of *condition* are attributes in use in the graph with the expression they should match so that the style is applied on the element considered.
The elements of *dotStyle* are attributes already in use in the
graph or new ones with their new value.
All elements in the file must be strings.

    digraph foo {
        n1 [color=blue, b=3, a=4];
        n2 ;
        n3 [color=green, label="n3", a=3];
        n1 -> n2 [color=orchid, b=2, a=5];
        n3 -> n1 [color=cyan, b=1];
    }

The launching of the line tool `./dotStyle.py example.dot -s example.json` where example.dot is the graph above and example.json is the json example above produces the following graph:

    digraph foo {
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

As specified in the json file, the node n1 where *a* is a positive integer and *b* equals 3 have been colored in blue and the edge `n1 -> n2` where *b* equals 2 has been colored in yellow. The other elements remain unchanged.
