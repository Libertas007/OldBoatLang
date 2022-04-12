# Boat

Simple programming language which will make you a captain.

## Examples

### Hello world:

```
SAIL ON yacht
BROADCAST "Hello world!"
ARRIVE AT port
```

### Simple calculator

```
SAIL ON yacht

REQUEST PACKAGE num1
REQUEST PACKAGE num2
REQUEST BARREL result

BROADCAST "Type the first number: "
LISTEN TO num1

BROADCAST "Type the second number: "
LISTEN TO num2

REPACK num1 TO BARREL
REPACK num2 TO BARREL

ADD num1 TO result
ADD num2 TO result

BROADCAST "sum is:"
BROADCAST result

SET result TO num1
SUBTRACT num2 FROM result

BROADCAST "difference is:"
BROADCAST result

SET result TO num1
MULTIPLY result BY num2

BROADCAST "product is: "
BROADCAST result

SET result TO num1
DIVIDE result BY num2

BROADCAST "share is: "
BROADCAST result

ARRIVE AT port
```

### Truth-machine

```
SAIL ON "yacht"

REQUEST PACKAGE X
LISTEN TO X

IF X == "0":
    BROADCAST X
    ARRIVE AT "P"
END

LOOP 9999999 TIMES:
    BROADCAST X
END
```

Note that Boat doesn't allow while loops yet, so looping 9999999 times is simulating infinity...

## How to use

Write program ending in `.boat`. Then download `/build/boat.exe` and run `.\boat.exe {path to your script}` from the terminal.

## Language overview

Language is made of simple commands. Details are below.

### Variables

In Boat, there are 2 data types, `BARREL` and `PACKAGE`. `BARREL` is float and `PACKAGE` is a string.

#### `REPACK`

**Syntax**: `REPACK [BARREL|PACKAGE] TO (BARREL|PACKAGE)`

`REPACK` changes type of variable. If conversion is from PACKAGE to BARREL, the PACKAGE must be valid number.

_Examples_:

`REPACK x TO PACKAGE`

`REPACK y TO BARREL`

Doesn't return anything.

#### `REQUEST`

**Syntax**: `REQUEST (BARREL|PACKAGE) {varName}`

Creates variable `{varName}` of specified type.

_Examples_:

`REQUEST PACKAGE x`

`REQUEST BARREL y`

Returns `0` if the new variable is `BARREL` or empty string if the new variable is `PACKAGE`.

#### `RETURN` / `DROP`

**Syntax**: `RETURN {varName}` / `DROP {varName}`

Deletes variable `{varName}`.

_Examples_:

`RETURN x`

`DROP y`

Doesn't return anything.

#### `SET`

**Syntax**: `SET {varName} TO [BARREL|PACKAGE]`

Sets value of variable {varName} to specified value.

_Examples_:

`SET x TO 5`

`SET y TO "Hello world!"`

Return the new value of variable.

### Mathematical operations

#### `ADD`

**Syntax**: `ADD [BARREL] TO [BARREL]`

Adds first BARREL to the second variable of type BARREL.

_Examples_:

`ADD 5 TO x`

`ADD x TO y`

Returns the new value of variable.

#### `SUBTRACT`

**Syntax**: `SUBTRACT [BARREL] FROM [BARREL]`

Subtracts first BARREL from the second variable of type BARREL.

_Examples_:

`SUBTRACT 5 FROM x`

`SUBTRACT x FROM y`

Returns the new value of variable.

#### `DIVIDE`

**Syntax**: `DIVIDE [BARREL] BY [BARREL]`

Divides first BARREL by the second variable of type BARREL.

_Examples_:

`DIVIDE x BY 5`

`DIVIDE y BY x`

Returns the new value of variable.

#### `MULTIPLY`

**Syntax**: `MULTIPLY [BARREL] BY [BARREL]`

Multiplies first BARREL by the second variable of type BARREL.

_Examples_:

`MULTIPLY x BY 5`

`MULTIPLY y BY x`

Returns the new value of variable.

### Input / output

#### `BROADCAST`

**Syntax**: `BROADCAST [BARREL|PACKAGE]`

Prints value of the first argument to the console.

_Examples_:

`BROADCAST x`

`BROADCAST "Hello world!"`

`BROADCAST 5`

Returns the broadcasted value.

#### `LISTEN TO`

**Syntax**: `LISTEN TO {varName}`

Reads input from the console and then sets it to variable `{varName}`.

_Examples_:

`LISTEN TO x`

ReturnS the new value of variable.

### Control flow

#### `ARRIVE AT`

**Syntax**: `ARRIVE AT {whatever}`

Arrives at `{whatever}` thus terminates the program with code 0.

_Examples_:

`ARRIVE AT whatever`

Doesn't return anything.

#### `CRASH INTO`

**Syntax**: `CRASH INTO {whatever}`

Crashes into `{whatever}` thus terminates the program with code 1.

_Examples_:

`CRASH INTO whatever`

Doesn't return anything.

#### `SINK`

**Syntax**: `SINK`

Your boat sinks thus terminates the program with code 0.

_Examples_:

`SINK`

Doesn't return anything.

#### `LOOP`

**Syntax**: `LOOP [BARREL] TIMES:` or `LOOP [BARREL] TIMES AS {varName}:`

Loops over block of code ended by `END` specified by first argument. If you want to use index, use the second syntax (`LOOP [BARREL] TIMES AS {varName}:`).

_Examples_:

```
LOOP 5 TIMES:
    BROADCAST "In loop!"
END
```

```
LOOP 5 TIMES AS i:
    BROADCAST i
END
```

Doesn't return anything.

#### `IF`

**Syntax**: `IF [BARREL|PACKAGE] [OPERATOR] [BARREL|PACKAGE]:`

Executes over block of code ended by `END` if the condition is true. Supported operators are: `==`, `!=`, `<=`, `>=`, `<` and `>`.

_Examples_:

```
IF 5 == 5:
    BROADCAST "5 is equal to 5!"
END
```

### Return value

Every command in Boat returns some value. By using `()`, you can use this return value in commands.

```
SAIL ON yacht

REQUEST BARREL X
REQUEST BARREL Y

SET X TO 12
DIVIDE X BY (ADD 2 TO Y)
```

Expression in parentheses always runs first, expected value of `X` is now `6`.
