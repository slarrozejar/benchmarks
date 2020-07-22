dotLabel
========

Description
-----------

This tool allows to set attributes on nodes and edges in a graph represented in the [DOT language](https://graphviz.org/doc/info/lang.html). Attribute values can be computed from the values of other attributes. **dotLabel** is written in Python and requires Python 3 to be executed.

Usage
-----
To execute this tool, simply launch the command:

    ./dotLabel.py [graph] [options]
    where:
        graph is a dot/graphviz file or - if the graph should be read from the standard input.

run command `./dotLabel.py -h` to get help on the options

Example
-------

The `dotLabel.py` tool allow to set the values of attributes on nodes and edges using command-line options `-n` and `-e` respectively. Each option is followed by an attribute assignment of the form *a=foo* that sets the value of attribute *a* to value *foo*. For instance, option `-n a=foo` specifies that the value of attribute *a* is set to *foo* for each node in the graph. The value of attributes can be computed from the value of other attributes using references. A reference *%a%* denotes the value of attribute *a*.

As an example, consider the following graph expressed in the DOT language:

    digraph example {
        n1 [a=4, b=toto];
        n2 ;
        n3 [a=6];
        n1 -> n2 [c=5, d=tata];
        n3 -> n1 [c=6];
    }

The command `./dotLabel.py example.dot -n label="%a%, %b%" -e label=edge`, where `example.dot` contains the graph above, outputs a graph in dot language whose edges are labelled "edge" and whose nodes are labelled *"%a%, %b%"* where *%a%* and *%b%* are replaced by the values of attributes *a* and *b* of the node. When a node does not possess an attribute *a*, the value of *%a%* is the empty string "". The command above outputs the following graph:

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
                    label="6, "];
            n3 -> n1        [c=6,
                    label="edge"];
    }

The value of a reference *%a%* is the value of the attribute in the input file, even when the command overwrites the attribute. For instance, the command `./dotLabel.py example.dot -n a="%b%" -n c="%a%"` will set the value of attribute *c* to the value of attribute *a* in the input file, and not the value of attribute *b*. On the example above, we end up with node *n1* as follows: `n1 [a=toto,b=toto,c=4]`.
