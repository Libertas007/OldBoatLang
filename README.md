# Boat

Simple programming language which will make you a captain.

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

#### `REQUEST`

**Syntax**: `REQUEST (BARREL|PACKAGE) {varName}`

Creates variable `{varName}` of specified type.

_Examples_:
`REQUEST PACKAGE x`
`REQUEST BARREL y`

#### `RETURN` / `DROP`

**Syntax**: `RETURN {varName}` / `DROP {varName}`

Deletes variable `{varName}`.

_Examples_:
`RETURN x`
`DROP y`

#### `SET`

**Syntax**: `SET {varName} TO [BARREL|PACKAGE]`

Sets value of variable {varName} to specified value.

_Examples_:
`SET x TO 5`
`SET y TO "Hello world!"`

### Mathematical operations

#### `ADD`

**Syntax**: `ADD [BARREL] TO [BARREL]`

Adds first BARREL to the second variable of type BARREL.

_Examples_:
`ADD 5 TO x`
`ADD x TO y`

#### `SUBTRACT`

**Syntax**: `SUBTRACT [BARREL] FROM [BARREL]`

Subtracts first BARREL from the second variable of type BARREL.

_Examples_:
`SUBTRACT 5 FROM x`
`SUBTRACT x FROM y`

#### `DIVIDE`

**Syntax**: `DIVIDE [BARREL] BY [BARREL]`

Divides first BARREL by the second variable of type BARREL.

_Examples_:
`DIVIDE x BY 5`
`DIVIDE y BY x`

#### `MULTIPLY`

**Syntax**: `MULTIPLY [BARREL] BY [BARREL]`

Multiplies first BARREL by the second variable of type BARREL.

_Examples_:
`MULTIPLY x BY 5`
`MULTIPLY y BY x`

### Input / output

#### `BROADCAST`

**Syntax**: `BROADCAST [BARREL|PACKAGE]`

Prints value of the first argument to the console.

_Examples_:
`BROADCAST x`
`BROADCAST "Hello world!"`
`BROADCAST 5`

#### `LISTEN TO`

**Syntax**: `LISTEN TO {varName}`

Reads input from the console and then sets it to variable `{varName}`.

_Examples_:
`BROADCAST x`
`BROADCAST "Hello world!"`
`BROADCAST 5`
