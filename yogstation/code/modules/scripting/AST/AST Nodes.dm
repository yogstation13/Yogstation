/*
	File: AST Nodes
	An abstract syntax tree (AST) is a representation of source code in a computer-friendly format. It is composed of nodes,
	each of which represents a certain part of the source code. For example, an <IfStatement> node represents an if statement in the
	script's source code. Because it is a representation of the source code in memory, it is independent of any specific scripting language.
	This allows a script in any language for which a parser exists to be run by the interpreter.

	The AST is produced by an <n_Parser> object. It consists of a <GlobalBlock> with an arbitrary amount of statements. These statements are
	run in order by an <n_Interpreter> object. A statement may in turn run another block (such as an if statement might if its condition is
	met).

	Articles:
	- <http://en.wikipedia.org/wiki/Abstract_syntax_tree>
*/

/*
	Macros: Operator Precedence
	The higher the value, the lower the priority in the precedence.
	
	OOP_OR				- Logical or
	OOP_AND				- Logical and
	OOP_BIT				- Bitwise operations
	OOP_EQUAL			- Equality checks
	OOP_COMPARE			- Greater than, less than, etc
	OOP_ADD				- Addition and subtraction
	OOP_MULTIPLY		- Multiplication and division
	OOP_POW				- Exponents
	OOP_UNARY			- Unary Operators
	OOP_GROUP			- Parentheses
*/
#define OOP_OR 1			//||
#define OOP_AND 2			//&&
#define OOP_BIT 3			//&, |
#define OOP_EQUAL 4		//==, !=
#define OOP_COMPARE 5	//>, <, >=, <=
#define OOP_ADD 6			//+, -
#define OOP_MULTIPLY 7 	//*, /, %
#define OOP_POW 8			//^
#define OOP_UNARY 9		//!
#define OOP_GROUP 10		//()

/*
	Class: node
*/
/node
	proc
		ToString()
			return "[src.type]"
/*
	Class: identifier
*/
/node/identifier
	var
		id_name

	New(id)
		.=..()
		src.id_name=id

	ToString()
		return id_name

/*
	Class: expression
*/
/node/expression
/*
	Class: operator
	See <Binary Operators> and <Unary Operators> for subtypes.
*/
/node/expression/operator
	var
		node/expression/exp
		tmp
			name
			precedence

	New()
		.=..()
		if(!src.name) src.name="[src.type]"

	ToString()
		return "operator: [name]"

/*
	Class: FunctionCall
*/
/node/expression/FunctionCall
	//Function calls can also be expressions or statements.
	var
		func_name
		node/identifier/object
		list/parameters=new

/*
	Class: literal
*/
/node/expression/value/literal
	var
		value

	New(value)
		.=..()
		src.value=value

	ToString()
		return src.value

/*
	Class: variable
*/
/node/expression/value/variable
	var
		node
			object		//Either a node/identifier or another node/expression/value/variable which points to the object
		node/identifier
			id


	New(ident)
		.=..()
		id=ident
		if(istext(id))id=new(id)

	ToString()
		return src.id.ToString()

/*
	Class: reference
*/
/node/expression/value/reference
	var
		datum/value

	New(value)
		.=..()
		src.value=value

	ToString()
		return "ref: [src.value] ([src.value.type])"