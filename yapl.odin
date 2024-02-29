package yapl

import "core:fmt"

opcode :: enum{
	CONSTANT,
	RETURN,
}

main :: proc(){
	fmt.println("YAPL!\n");
	chunk : Chunk;
	init_chunk(&chunk);
	constant := add_constant(&chunk,6.9);
	write_chunk(&chunk,u8(opcode.CONSTANT),123);
	write_chunk(&chunk,u8(constant),123);
	write_chunk(&chunk,u8(opcode.RETURN),123);
	dissasemble_chunk(&chunk, "TEST");
	free_chunk(&chunk); //in future use defer perchance
}
