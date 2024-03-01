package yapl;

import "core:fmt"


Value :: distinct f64;
ValueArray :: BaseDynArray(Value);

//TODO(ftommasi): refactor this. there MUST be a better way
//Because chunk is a BaseDynArray that contains another BaseDynArray I am redifining. 
Chunk :: struct{
	//code : ^u8, //the book defines code as a uint8_t pointer, but really it the array portion
	code : [dynamic]u8,
	count : i32, 
	capacity : i32, 
	constants: ValueArray,
	lines: [dynamic]i32,
}

init_value_array :: proc(value_array : ^ValueArray ) {
	init_base_dyn_array(value_array);
}

write_value_array :: proc(value_array : ^ValueArray , value :Value) {
	write_base_dyn_array(value_array,value);
}

free_value_array :: proc(value_array : ^ValueArray ) {
	//delete(value_array.code);
	//how do we do this with odin?
	free_base_dyn_array(value_array);
}

add_constant :: proc(chunk : ^Chunk, value : Value) -> i32 {
	write_value_array(&chunk.constants,value);
	return chunk.constants.count - 1;
}

init_chunk :: proc(chunk : ^Chunk ) {
	chunk.code = make([dynamic]u8,0,0);
	chunk.lines = make([dynamic]i32,0,0);
	init_value_array(&chunk.constants);
}

write_chunk :: proc(chunk : ^Chunk , byte :u8, line : i32) {
	append(&chunk.code,byte);
	append(&chunk.lines,line);
	chunk.count = i32(len(chunk.code));
	chunk.capacity = i32(cap(chunk.code));
}

free_chunk :: proc(chunk : ^Chunk ) {
	delete(chunk.code);
	delete(chunk.lines);
	free_value_array(&chunk.constants);
}

dissasemble_chunk :: proc(chunk : ^Chunk, name : string){
	fmt.printf("== %v ==\n",name);
	
	offset : i32 = 0;
	for offset < chunk.count{
		offset = dissasemble_instruction(chunk,offset);	
	}
}

dissasemble_instruction :: proc(chunk : ^Chunk, offset : i32) -> i32{
	fmt.printf("%04d ", offset);
	if offset > 0 && chunk.lines[offset] == chunk.lines[offset-1]{
		fmt.printf("    | ");
	}else{
		fmt.printf("%4d ",chunk.lines[offset]);
	}

	instruction := chunk.code[offset];
	switch opcode(instruction){
		case .RETURN :
			return simple_instruction("OP_RETURN", offset);
		case .CONSTANT :
			return constant_instruction("OP_CONSTANT",chunk,offset);
		case .ADD :
			return simple_instruction("OP_ADD",offset);
		case .SUBTRACT :
			return simple_instruction("OP_SUBTRACT",offset);
		case .MULTIPLY :
			return simple_instruction("OP_MULTIPLY",offset);
		case .DIVIDE :
			return simple_instruction("OP_DIVIDE",offset);
		case .NEGATE :
			return simple_instruction("OP_NEGATE",offset);
		case:
			fmt.printf("Unknown opcode %v\n",instruction);
			return offset + 1;
	}
}

simple_instruction :: proc(name : string, offset : i32) -> i32 {
	fmt.printf("%v\n",name);
	return offset + 1;
}

constant_instruction :: proc(name : string, chunk : ^Chunk, offset : i32) -> i32 {
	constant := chunk.code[offset+1];
	fmt.printf("%-16s %14d ",name,constant);
	print_value(chunk.constants.code[constant]); //TODO(cleanup) constants.code is referred to as constants.values in book. Artifact of parapoly
	return offset + 2;
}

print_value ::proc(value : Value){
	fmt.printf("%v\n",value); //
}
