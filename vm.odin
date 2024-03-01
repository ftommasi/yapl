package yapl;

import "core:fmt"

STACK_MAX :: 256;

VM :: struct{
    chunk : ^Chunk,
    ip : int, //int for indexing into chunk.code dynamic array rather tha  c-style pointer arithmetic
    stack : [STACK_MAX]Value,
    stack_top : int, // //int for indexing into chunk.code dynamic array rather tha  c-style pointer arithmetic
}

InterpretResult :: enum{
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
}

/*
* Here the VM will serve as an IR type language to be translated into actual machine code down the line
*/

init_vm :: proc(){
    reset_stack();
}


free_vm :: proc(){
}

reset_stack :: proc(){
    vm.stack_top = -1; //Equivalent of settings staack_top pointer to base pointer of stack array
}

push :: proc(value : Value) {
    //if vm.stack_top < STACK_MAX{
        vm.stack_top += 1;
        vm.stack[vm.stack_top] = value;
    //}
}

pop :: proc() -> Value{
    //value : Value = 0; //?
    //if vm.stack_top > 0{
        value := vm.stack[vm.stack_top];
        vm.stack_top -= 1;
    //}
    return value;
}

interpret :: proc(chunk : ^Chunk) -> InterpretResult{
    vm.chunk = chunk;
    vm.ip = 0; //The book uses a pointer and does pointer arithmetic and deref for speed reasons. for safety we will index with int
    return run();
}

DEBUG_TRACE_EXECUTION :: false

//TODO: this step will have to be translated to generate real machine code rather than interpret the VM code
run :: proc() -> InterpretResult{
    for {
        when DEBUG_TRACE_EXECUTION{
            for slot in 0..<vm.stack_top{
                fmt.printf("[");
                print_value(vm.stack[slot]);
                fmt.printf("]");
            }
            dissasemble_instruction(vm.chunk, (i32)(vm.ip));
        }

        instruction := read_byte();
        switch opcode(instruction){
            case .CONSTANT:
                constant := read_constant();
                push(constant);
                print_value(constant);
                fmt.printf("\n");

            case .ADD:
                binary_op(.ADD)
            case .SUBTRACT:
                binary_op(.SUBTRACT)
            case .MULTIPLY:
                binary_op(.MULTIPLY)
            case .DIVIDE:
                binary_op(.DIVIDE)
            case .NEGATE:
                push(-pop()); 

            case .RETURN:
                print_value(pop());
                fmt.printf("\n");
                return .OK;

            case :
                return .COMPILE_ERROR;
        }
    }
    return .OK; // WHAT
}

//TODO: this step will have to be translated to generate real machine code rather than interpret the VM code
binary_op :: proc(op : opcode) {
    b := pop();
    a := pop();
    #partial switch op{ //partial switch since we dont want default behavior and not all ops are binary
        case .ADD:
          push(a + b);
        case .SUBTRACT:
          push(a - b);
        case .MULTIPLY:
          push(a * b);
        case .DIVIDE:
          push(a / b);
    }
}

read_byte :: proc() -> u8 {
    next_byte := vm.chunk.code[vm.ip];
    vm.ip += 1;
    return next_byte;
}

read_constant :: proc() -> Value {
    next_byte := read_byte();
    next_constant := vm.chunk.constants.code[next_byte];
    return next_constant;
}
