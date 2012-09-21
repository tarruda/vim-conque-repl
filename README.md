### Vim ConqueShell Repl
  
This plugin makes really easy sending input/reading output from
REPLs through vim. It has similar goals to the <a href="http://www.vim.org/scripts/script.php?script_id=2531">slime.vim plugin</a>
but it doesn't need screen or tmux and works with gvim. Instead it 
it depends on the <a href="http://www.vim.org/scripts/script.php?script_id=2771">ConqueShell plugin</a>,
so vim must be compiled with python support

### Installation

If you are using Vundle add this to your vimrc:

```vimL
Bundle 'tarruda/vim-conque-shell'
Bundle 'tarruda/vim-conque-repl'
```

Or copy vim-conque-repl.vim to the plugins directory.

### Usage

With the default configuration F5 and F6 are mapped
respectively, but only if they are not mapped yet. The mappings can be
customized by setting ```g:conque_repl_send_key``` and ```g:conque_repl_send_buffer_key```
in your vimrc.
        
The idea is that you have two buffers in split windows, one where you are
editing commands, and another where conqueshell is running a repl for some
language(python, ruby, node.js, coffeescript...) or any other process that
accepts commands interactively. So in the default setup:

  - Hitting F5 in normal or insert mode will send the line under the cursor to 
      the repl. 
  - Hitting F5 in visual mode will send the selected text to the repl. 

  - Hitting F6 in normal or insert mode will send the entire buffer to the repl. 

Unlike the default ConqueShell commands for sending text, these leave the
original buffers focused and with text selected(in case of running in visual mode), transforming vim into a
nice multi line command editor with syntax highlighting/indentation.

  This plugin works well with the <a href="http://www.vim.org/scripts/script.php?script_id=664">scratch.vim plugin</a>.
