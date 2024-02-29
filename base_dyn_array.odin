package yapl

BaseDynArray :: struct(T:typeid){
	//code : ^u8, //the book defines code as a uint8_t pointer, but really it the array portion
	code : [dynamic]T,
	count : i32, // unused.  Builtin to dynarray
	capacity : i32, // unused.  Builtin to dynarray
}

init_base_dyn_array :: proc(base_dyn_array : ^BaseDynArray($T) ) {
	base_dyn_array.code = make([dynamic]T,0,0);
}

write_base_dyn_array :: proc(base_dyn_array : ^BaseDynArray($T) , array_val :T) {
	append(&base_dyn_array.code,array_val);
	//we will keep track of this for parity reasons with book. odin's growable array already has its own way of computing count/capacity
	base_dyn_array.count = i32(len(base_dyn_array.code));
	base_dyn_array.capacity = i32(cap(base_dyn_array.code));
}

free_base_dyn_array :: proc(base_dyn_array : ^BaseDynArray($T) ) {
	delete(base_dyn_array.code);
}

