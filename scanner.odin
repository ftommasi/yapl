package yapl;

Scanner :: struct{
    start : string,
    start_idx : int, //we are not doing ptr ops
    current : string,
    current_idx : int, //we are not doing ptr ops
    line  : i64,
}

TokenType :: enum{
    // Single-character tokens.
    LEFT_PAREN, RIGHT_PAREN,
    LEFT_BRACE, RIGHT_BRACE,
    COMMA, DOT, MINUS, PLUS,
    SEMICOLON, SLASH, STAR,
    // One or two character tokens.
    BANG, BANG_EQUAL,
    EQUAL, EQUAL_EQUAL,
    GREATER, GREATER_EQUAL,
    LESS, LESS_EQUAL,
    // Literals.
    IDENTIFIER, STRING, NUMBER,
    // Keywords.
    AND, CLASS, ELSE, FALSE,
    FOR, FUN, IF, NIL, OR,
    PRINT, RETURN, SUPER, THIS,
    TRUE, VAR, WHILE,

    ERROR, EOF
}

Token :: struct{
    type : TokenType,
    start : string,
    length : i64,
    line : i64,
}

scanner : Scanner;

init_scanner :: proc(code : string){
    scanner.start = code;
    scanner.current = code;
    scanner.line = 1; 
}

make_token :: proc(token_type : TokenType) -> (token :Token) {
    token.type = token_type;
    token.start = scanner.start;
    token.length = i64(scanner.current_idx - scanner.start_idx);
    token.line = scanner.line;
    return token;
}

error_token :: proc(error_message : string) -> (token :Token) {
    token.type = .ERROR

    //TODO: Book has something different here. We did this because we are trying to stay away from ptr ops 
    token.start = scanner.start;
    token.length = i64(scanner.current_idx - scanner.start_idx);
    token.line = scanner.line;
    //token.line = error_message;
    return token;
}

scan_token :: proc() -> Token {
    scanner.start = scanner.current;
    if is_at_end() {
        return make_token(.EOF);
    }


    c := advance();
    
    if is_alpha(u8(c)){
        return identifier();
    }

    if is_digit(u8(c)){
        return number();
    }

    switch c {
        case '(': return make_token(.LEFT_PAREN);
        case ')': return make_token(.RIGHT_PAREN);
        case '{': return make_token(.LEFT_BRACE);
        case '}': return make_token(.RIGHT_BRACE);
        case ';': return make_token(.SEMICOLON);
        case ',': return make_token(.COMMA);
        case '.': return make_token(.DOT);
        case '-': return make_token(.MINUS);
        case '+': return make_token(.PLUS);
        case '/': return make_token(.SLASH);
        case '*': return make_token(.STAR);
        case '!':
            if match('='){
                return make_token(.BANG_EQUAL);
            }else{
                return make_token(.BANG);
            }
        case '=':
            if match('='){
                return make_token(.EQUAL_EQUAL);
            }else{
                return make_token(.EQUAL);
            }
        case '<':
            if match('='){
                return make_token(.LESS_EQUAL);
            }else{
                return make_token(.LESS);
            }
        case '>':
            if match('='){
                return make_token(.GREATER_EQUAL);
            }else{
                return make_token(.GREATER);
            }
        case '"':
            return parse_string_token();
    }

    return error_token("Unexpected character");
}

is_alpha :: proc(c : u8) -> bool{
    return (c >= 'a' && c <= 'z') ||
         (c >= 'A' && c <= 'Z') ||
          c == '_';
}
is_digit :: proc(c : u8) -> bool{
    return c >= '0' && c <= '9';
}

identifier :: proc() -> Token{
     for is_alpha(peek()) || is_digit(peek()) {
         advance();
     }
  return make_token(identifier_type());
}

identifier_type :: proc() -> TokenType{
    switch scanner.start[scanner.start_idx] {
        case 'a': return check_keyword(1, 2, "nd", .AND);
        case 'c': return check_keyword(1, 4, "lass", .CLASS);
        case 'e': return check_keyword(1, 3, "lse", .ELSE);
        case 'i': return check_keyword(1, 1, "f", .IF);
        case 'n': return check_keyword(1, 2, "il", .NIL);
        case 'o': return check_keyword(1, 1, "r", .OR);
        case 'p': return check_keyword(1, 4, "rint", .PRINT);
        case 'r': return check_keyword(1, 5, "eturn", .RETURN);
        case 's': return check_keyword(1, 4, "uper", .SUPER);
        case 'v': return check_keyword(1, 2, "ar", .VAR);
        case 'w': return check_keyword(1, 4, "hile", .WHILE);
        case 'f': 
            if scanner.current_idx - scanner.start_idx > 1 {
                 switch (scanner.start[scanner.start_idx +1]) {
                    case 'a': return check_keyword(2, 3, "lse", .FALSE);
                    case 'o': return check_keyword(2, 1, "r", .FOR);
                    case 'u': return check_keyword(2, 1, "n", .FUN);
            }
        }
        case 't': 
            if scanner.current_idx - scanner.start_idx > 1 {
                 switch (scanner.start[scanner.start_idx +1]) {
                    case 'h': return check_keyword(2, 3, "is", .THIS);
                    case 'r': return check_keyword(2, 3, "rue", .TRUE);
                }
            }
    }
        
    return .IDENTIFIER;
}

check_keyword :: proc(start,length : int, rest : string, token_type : TokenType) -> TokenType{
    if scanner.current_idx - scanner.start_idx == start + length && scanner.start[scanner.start_idx + start : length] == rest[:]{
        return token_type;
    }
    return .IDENTIFIER;
}

number :: proc() -> Token{
    for is_digit(peek()){
        advance();
    }

    if peek() == '.' && is_digit(peek_next()){
        advance();
        for is_digit(peek()){
            advance();
        }
    }
    return make_token(.NUMBER);
}

parse_string_token :: proc() -> Token {
    for peek() != '"' && !is_at_end() {
        if peek() == '\n'{
            scanner.line += 1;
        }

        advance();
    }

  if is_at_end() {
      return error_token("Unterminated string.");
  }

  // The closing quote.
  advance();
  return make_token(.STRING);
}

match :: proc(expected : rune) -> bool{
    if is_at_end(){
        return false;
    }
    if rune(scanner.current[scanner.current_idx]) != expected {
        return false;
    }

    scanner.current_idx += 1;
    return true;
}


skip_whitespace :: proc() {
  for {
      c := peek();
      switch c {
      case ' ': fallthrough;
      case '\r': fallthrough;
      case '\t':
        _ = advance();
      case '\n':
        scanner.line += 1;
        _ = advance();
      case:
        return;
    }
  }
}


peek :: proc() -> u8 {
    return scanner.current[scanner.current_idx];
}

peek_next :: proc() -> u8 {
    return scanner.current[scanner.current_idx];
}

advance :: proc() -> i64 {
    scanner.current_idx += 1;
    return i64(scanner.current_idx - 1);
}

//TODO
is_at_end :: proc() -> bool {
    return false;
}
