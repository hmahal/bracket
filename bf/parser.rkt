#lang brag

; Grammar for brainfuck in EBNF
bf-program  : (bf-op | bf-loop)*
bf-op       :   ">" | "<" | "+" | "-" | "." | ","
bf-loop     : "[" (bf-op | bf-loop)* "]"
