dotLabel
=======

Description
-----------

This tool allows to change some attributes' value in
a graph with dot format in order to make it easier to read. The attributes can be added/changed either on nodes or on edges. **dotLabel** is
written in Python and requires Python 3 to be executed.

Usage
-----
To execute this tool, simply launch the line tool:

    ./dotLabel.py [graph] [options]
    where:
        graph must be a graphviz graph with dot format
        see -h to get help on the options
        reads from standard input if graph specified by "-".

The options can be used more than once in a line tool and the values considered will be the values of the
original graph given as parameter.

Example
-------

    digraph example {
        n1 [a=4, b=toto];
        n2 ;
        n3 [a=6, b=titi];
        n1 -> n2 [c=5, d=tata];
        n3 -> n1 [c=6];
    }

The launching of the line tool `./dotLabel.py example.dot -n label="%a%, %b%" -e label=edge` where example.dot is the dot graph above returns a graph with dot format whose edges are labelled "edge" and whose
nodes are labelled *"%a%, %b%"* where *%a%* and *%b%* are replaced by the values of their attributes
*a* and *b*. If a node doesn't possess an attribute *a* or *b*, the value will be replaced by "". The graph returned is the following:

    digraph example {
            node [label="\N"];
            n1      [a=4,
                    b=toto,
                    label="4, toto"];
            n2      [label=", "];
            n1 -> n2        [c=5,
                    d=tata,
                    label="edge"];
            n3      [a=6,
                    b=titi,
                    label="6, titi"];
            n3 -> n1        [c=6,
                    label="edge"];
    }
