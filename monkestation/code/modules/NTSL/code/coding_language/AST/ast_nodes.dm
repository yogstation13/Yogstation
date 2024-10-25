/**
 * An abstract syntax tree (AST) is a representation of source code in a computer-friendly format. It is composed of nodes,
 * each of which represents a certain part of the source code. For example, an <IfStatement> node represents an if statement in the
 * script's source code. Because it is a representation of the source code in memory, it is independent of any specific scripting language.
 * This allows a script in any language for which a parser exists to be run by the interpreter.
 *
 * The AST is produced by an <n_Parser> object. It consists of a <GlobalBlock> with an arbitrary amount of statements. These statements are
 * run in order by an <n_Interpreter> object. A statement may in turn run another block (such as an if statement might if its condition is
 * met).
 *
 * Articles:
 * - <http://en.wikipedia.org/wiki/Abstract_syntax_tree>
 */

/**
 * Macros: Operator Precedence
 * The higher the value, the lower the priority in the precedence.
 */
#define OOP_ASSIGN 0
///Logical or ||
#define OOP_OR 1
///Logical and &&
#define OOP_AND 2
///Bitwise operations &, |
#define OOP_BIT 3
///Equality checks ==, !=
#define OOP_EQUAL 4
///Greater than, less than, etc >, <, >=, <=
#define OOP_COMPARE 5
///Addition and subtraction + -
#define OOP_ADD 6
///Multiplication and division * / %
#define OOP_MULTIPLY 7
///Exponents ^
#define OOP_POW 8
///Unary Operators !
#define OOP_UNARY 9
///Parenthesis ()
#define OOP_GROUP 10

/**
 * Node
 */
/datum/node
	///Returns line number information
	var/datum/token/token

/datum/node/proc/ToString()
	return "[type]"

/*
 * identifier
 */
/datum/node/identifier
	var/id_name

/datum/node/identifier/New(id, token)
	. = ..()
	src.id_name = id
	src.token = token

/datum/node/identifier/ToString()
	return id_name

/*
 * expression
 */
/datum/node/expression
/*
 * operator
 * See <Binary Operators> and <Unary Operators> for subtypes.
 */
/datum/node/expression/expression_operator
	var/datum/node/expression/exp
	var/tmp/name
	var/tmp/precedence

/datum/node/expression/expression_operator/New(token, exp)
	. = ..()
	if(!name)
		name = "[type]"
	src.token = token
	src.exp = exp

/datum/node/expression/expression_operator/ToString()
	return "operator: [name]"

/datum/node/expression/member
	var/datum/node/expression/object
	var/tmp/temp_object // so you can pre-eval it, used for function calls and assignments

/datum/node/expression/member/New(token)
	src.token = token
	return ..()

/datum/node/expression/member/dot
	var/datum/node/identifier/id

/datum/node/expression/member/brackets
	var/datum/node/expression/index
	var/tmp/temp_index


/*
 * FunctionCall
 */
/datum/node/expression/FunctionCall
	//Function calls can also be expressions or statements.
	var/datum/node/expression/function
	var/list/parameters = list()

/datum/node/expression/FunctionCall/New(token)
	. = ..()
	src.token = token

/*
 * literal
 */
/datum/node/expression/value/literal
	var/value

/datum/node/expression/value/literal/New(value)
	. = ..()
	src.value = value

/datum/node/expression/value/literal/ToString()
	return value

/*
 * Variable
 */
/datum/node/expression/value/variable
	///Either a node/identifier or another node/expression/value/variable which points to the object
	var/datum/node/object
	var/datum/node/identifier/id

/datum/node/expression/value/variable/New(datum/node/identifier/ident, datum/token/token)
	. = ..()
	src.token = token
	src.id = ident
	if(istext(id))
		src.id = new(id)

/datum/node/expression/value/variable/ToString()
	return id.ToString()

/datum/node/expression/value/list_init
	var/list/init_list

/datum/node/expression/value/list_init/New(datum/token/token)
	. = ..()
	src.token = token

/**
 * Reference
 */
/datum/node/expression/value/reference
	var/datum/value

/datum/node/expression/value/reference/New(value, datum/token/token)
	. = ..()
	src.token = token
	src.value = value

/datum/node/expression/value/reference/ToString()
	return "ref: [value] ([value.type])"
