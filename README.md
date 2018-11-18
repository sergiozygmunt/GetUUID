# GetUUID
GetUUID is a BASH script I wrote to allow for you to get UUIDs of varying sizes and attributes and either print them to screen or store them to the clipboard.


# Usage
The easiest way to use GetUUID is to run it in interactive mode  
`-i` is all you need  
You can add `-d` to the command call to get a diagnostic output which will help you better understand how the script works.  

## Arguments
`-i` or `--interactive` - run the script in interactive mode  
`-d` or `--diagnostics` - print diagnostic information which can help you understand how the program works  
`-n` or `--number` followed by an number (`[num]`) tells the program how many UUIDs you want. The default value is `1`.  
`-s` or `--separator` followed by a string with no spaces tells the program how you want the UUIDs separated. The default is a `-`. The UUIDs are concatenated with this in between them.  
`-c` or `--clipboard` followed by an argument, explained below

## Clipboard arguments
You need to pass one the items below after `-c` or `--clipboard`for it to do something besides the default ignore clipboard.  
  
`--clipboard 0|false` or nothing - won't touch your clipboard at all  
`--clipboard 1|savethenorompt` or `-cs` - stores the contents of your clipboard to a variable, copies the UUID output, then kindly asks you when you're ready to have the original contents of your clipboard restored.  
`--clipboard 2|overwrite` or `-co` -obliterates your current clipboard and copies the UUID. You won't get your clipboard back  

## Who made this (who can I complain to)?

Why I, Sergio Zygmunt, did. You can open an issue or submit a pull request.  
If you look at my links you can get into touch with me that way.  
