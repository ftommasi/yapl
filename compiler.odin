package yapl;

import "core:fmt"

Parser :: struct {
	current : Token,
	previous : Token,
	had_error : bool,
	panic_mode : bool,
}

parser : Parser;
compiling_chunk : ^Chunk;

compile :: proc(code : string, chunk : ^Chunk)  -> bool{
    init_scanner(code)
	compiling_chunk = chunk;
	parser.had_error = false;
	parser.panic_mode = false;
	advance();
	expression();
	consume(.EOF,"Expect end of expression.");
	end_compiler();//defer ???	
	return !parser.had_error;
}

advance :: proc() {
	parser.previous = parser.current;
	
	for {
		parser.current =  scan_token();
		if parser.current.type != .ERROR {
			break;
		}
		error_at_current(parser.current.start);
	}
}

error_at_current :: proc(message : string) {
	error_at(&parser.current,message);
}

error :: proc(message : string) {
	error_at(&parser.previous,message);
}

error_at :: proc(token : ^Token, message : string){
	if parser.panic_mode{
		return;
	}
	parser.panic_mode = true;
	fmt.printf("[line %d] Error", token.line);

	if token.type == .EOF {
		fmt.printf("at end");
	}else if token.type == .ERROR{
		//nothing
	}else{
		fmt.printf("at %s",token.start);
	}
	fmt.printf(": %s\n",message);
	parser.had_error = true;
}

consume :: proc(token_type : TokenType, message : string){
	if parser.current.type == token_type {
		advance();
	}
	return;
}

emit_byte :: proc(byte : u8) {
	write_chunk(current_chunk(),byte,parser.previous.line);
}

end_compiler :: proc() {
	emit_return();
}

emit_return :: proc() {
	emit_byte(u8(opcode.RETURN));
}
emit_bytes:: proc(byte1,byte2 : u8) {
	emit_byte(byte1);
	emit_byte(byte2);
}

current_chunk :: proc() -> ^Chunk{
	return compiling_chunk;
}

expression :: proc() {
}

