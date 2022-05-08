# LxLang

LxLang is a programing language.
lx = Alex

## Why?

For my own curiosity

## Syntax:

### Assignment:

Variables start with a lowercase letter and may contain upper and lower case letters, numbers, and underscores:

```
my_variable = 42 : Int8
```

Constants can only contain uppercase letters, numbers, and underscores:

```
MY_CONTSTANT = 42 : Int8
```

### Blocks

Blocks are sections of code that create a new scope, they also inherit the parent scope:

```
{
  # ...
}
```

Blocks can be assigned to variables:

```
my_block = {}
```

Blocks can define parameters:

```
my_block = { in x : Int8 }
```

...and define return types:

```
pass_through = { in x : Int8, out Int8
  return x
}
```

Blocks can also invoke methods

```
add = { in x : Int8, y : Int8 out Int8 ret x + y }
add(1, 2) # => 3
```

## Contributors

- [Alex Clink](https://github.com/SleepingInsomniac) - creator and maintainer
