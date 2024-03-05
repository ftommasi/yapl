package yapl;

import "core:fmt"

compile :: proc(code : string) {
    init_scanner(code)
    line : i64 = 1;
    for {
        token := scan_token();
        if token.line != line {
            fmt.printf("%4d ",token.line);
            line = token.line;
        }else{
            fmt.printf("    | ");
        }
        fmt.printf("%2d '%.*s'\n",token.type,token.length,token.start); // ?

        if token.type == .EOF{
            break;
        }
    }
}
