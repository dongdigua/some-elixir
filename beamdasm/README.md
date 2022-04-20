## beamdasm
tools for disassemble .beam files  
### solution
But I finally found a way to compile to asm directly:  
```shell
ERL_COMPILER_OPTIONS="'S'" elixirc your_file.ex
```
that will create .S file and drop an error  
Or you can use @compile attribute per module
[on elixir forum](https://elixirforum.com/t/how-to-compile-ex-code-into-s-assembly-like-erl-s/47274/7)
### some other references
One reason for I made this because VScode's [beamdasm](https://github.com/scout119/beamdasm) didn't work  
[refererce](https://medium.com/learn-elixir/disassemble-elixir-code-1bca5fe15dd1)  
there's another [repo make by a Chinese people](https://github.com/ErlGameWorld/eUtils)  
https://dashbit.co/blog/how-to-debug-elixir-erlang-compiler-performance  
http://gomoripeti.github.io/beam_by_example/  


