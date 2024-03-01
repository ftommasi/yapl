package yapl

import "core:fmt"

opcode :: enum{
	CONSTANT,
    ADD,
    SUBTRACT,
    MULTIPLY,
    DIVIDE,
	NEGATE,
	RETURN,
}

vm : VM;

main :: proc(){
    init_vm();
    defer free_vm();

	fmt.println("YAPL!\n");
	chunk : Chunk;
	init_chunk(&chunk);
	defer free_chunk(&chunk); //in future use defer perchance

	//constant := add_constant(&chunk,6.9);
	constant := add_constant(&chunk,1.2);
	write_chunk(&chunk,u8(opcode.CONSTANT),123);
	write_chunk(&chunk,u8(constant),123);

	constant = add_constant(&chunk,3.4);
	write_chunk(&chunk,u8(opcode.CONSTANT),123);
	write_chunk(&chunk,u8(constant),123);

    write_chunk(&chunk,u8(opcode.ADD),123)

	constant = add_constant(&chunk,5.6);
	write_chunk(&chunk,u8(opcode.CONSTANT),123);
	write_chunk(&chunk,u8(constant),123);

    write_chunk(&chunk,u8(opcode.DIVIDE),123)

	write_chunk(&chunk,u8(opcode.NEGATE),123);

	write_chunk(&chunk,u8(opcode.RETURN),123);
	dissasemble_chunk(&chunk, "TEST");
    interpret(&chunk);
}
