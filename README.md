# Mini Caml Interpreter

This project description, written in French, is for an interpreter for a subset of OCaml, called Mini-ML. The interpreter is written in OCaml as well. OCAMLCEPTION !!!

Mini-ML consists of a series of type definitions, followed by a single expression to evaluate. It supports common arithmetic and logical operations, mutable data structures, conditionals, and recursive functions. The semantics and syntax are the same as with OCaml, and any Mini-ML program is also a OCaml program expected to produce the same result.

The project is divided into three parts (for each part we had to change one file):

- **Syntax Analysis**: This involves implementing a lexer and a parser to create an Abstract Syntax Tree (AST) from the source code. The lexer and parser should remove all ambiguities. (files: mmllexer.mll and mmlparser.mly)

- **Type Checking**: This involves ensuring that all expressions are coherent and checking if operations are correctly applied. For example, checking if only mutable fields are modified and no two types have common field names. (file: typechecker.ml)

- **Interpretation**: This involves evaluating expressions to produce a value and update memory. The memory can contain function closures and data structures and is dynamic. (file: interpreter.ml)


The project also offers an intermediate program, mmlcat, to test the syntax analysis. It takes a Mini-ML file as input, performs syntax analysis, and outputs a program corresponding to the tree.

Once completed, the mmli program will be a complete interpreter for Mini-ML.



## Acknowledgements
This project wouldn't have been possible without the contributions and guidance of Adam Sekkat, my project partner, and Professor Thibaut BALABONSKI.

You can find more about the project here: __[link to the project website](https://www.lri.fr/~blsk/CompilationLDD3/dm-mml.html)__

***

Should you have any queries or require further clarification on any aspect of the project, feel free to raise an issue on GitHub.

I hope you find the project as enlightening and informative as I did during its creation :)
