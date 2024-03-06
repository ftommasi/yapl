package yapl

import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"
import "core:strings"

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
    
    argc := len(os.args);
    if argc == 1 {
        repl();
    }else if argc == 2{
        run_file(os.args[1])
    }else{
        //Should we print to stderr or??
        fmt.printf("Usage yapl [program path]\n");
        os.exit(69);
    }

	fmt.println("YAPL!\n");
	chunk := make_chunk();
	defer free_chunk(chunk); //in future use defer perchance

}

repl :: proc() {
    stream := os.stream_from_handle(os.stdin)
    s: bufio.Scanner
    bufio.scanner_init(&s, stream)
    defer bufio.scanner_destroy(&s)
    for{
        fmt.printf("> ");
        advance_scanner := bufio.scanner_scan(&s)
        line := bufio.scanner_text(&s)
        for char in line{
            fmt.printf("%v",char);
        }
        fmt.printf("\n");
        _ = interpret(line);
    }// Read a specific amount of bytes:
}


run_file :: proc(path : string){
    file,ok := os.read_entire_file_from_filename(path);
    if !ok {
        os.exit(420); //cant copile because of error reading file
    }
    defer delete(file);

    result := interpret(strings.clone_from_bytes(file,context.temp_allocator));        

    if result ==.COMPILE_ERROR{
        os.exit(421); //compile error
    }

    //TODO: Here run time errors will probably not exist once we compile directly to machine code.
    if result ==.RUNTIME_ERROR{
        os.exit(422); //runtime error
    }
}


interpret :: proc(code :string) -> InterpretResult {

	chunk := make_chunk();
	defer free_chunk(chunk);

	if !compile(code,chunk) {
		return .COMPILE_ERROR;
	}

	vm.chunk = chunk;
	vm.ip = vm.chunk.code_idx;

	result := run();

    return .OK;
}

//TODO: delete once done
//capture early chapter examples here. 
//example :: proc(_chunk : Chunk) {
//    chunk : Chunk = _chunk
//	//constant := add_constant(&chunk,6.9);
//	constant := add_constant(&chunk,1.2);
//	write_chunk(&chunk,u8(opcode.CONSTANT),123);
//	write_chunk(&chunk,u8(constant),123);
//
//	constant = add_constant(&chunk,3.4);
//	write_chunk(&chunk,u8(opcode.CONSTANT),123);
//	write_chunk(&chunk,u8(constant),123);
//
//    write_chunk(&chunk,u8(opcode.ADD),123)
//
//	constant = add_constant(&chunk,5.6);
//	write_chunk(&chunk,u8(opcode.CONSTANT),123);
//	write_chunk(&chunk,u8(constant),123);
//
//    write_chunk(&chunk,u8(opcode.DIVIDE),123)
//
//	write_chunk(&chunk,u8(opcode.NEGATE),123);
//
//	write_chunk(&chunk,u8(opcode.RETURN),123);
//	dissasemble_chunk(&chunk, "TEST");
//    interpret(&chunk);
//}
