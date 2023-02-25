%option yylineno
%x STRINGSTATE
%x char_start
%x char_end
%x special_char_start
%x multichar_start
%x multichar_end


%{
#include<bits/stdc++.h>
#include"sym.h"
#include"1905053.tab.h"
//#include"any.tab.h"
#include<stdlib.h>
#include<string>
#include<algorithm>


using namespace std;


int line_count=1;

int total_errors=0;
string str;
string log_string="";
string token_string="";
string log_commment="";
string log_multilinecomm="";
string log_char="";
string token_char="";
int reserveLC;
int start_line;
int comment_start_line;
bool isMultiLine=false;



extern ofstream errorout;
extern ofstream printlog;
extern SymbolTable table;
extern YYSTYPE yylval;



string EscapeCharacter(string s)
          {
	if(s[1]=='t')
		return "\t";
	else if (s[1] =='n'||s[1] == '0')
		return "\n";
	else if (s[1] =='a')
		return "\a";
	else if (s[1] =='r')
		return "\r";
	else if (s[1] =='f')
		return "\f";
	else if (s[1] =='b')
		return "\b";
	else if (s[1] =='v')
		return "\v";
	else if (s[1] =='\'')
		return "\'";
	else if (s[1] =='\\')
		return "\\";
	else if (s[1] =='\"')
		return "\"";
	else return "x";
            }


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
FLOATING_POINT_LITERALS {DIGIT}+?(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?
CHARACTER [a-zA-Z0-9]
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
LOGICOP ("&&"|"||")
BITOP ("|"|"&"|"^"|"<<"|">>")

RELOP ("<"|"<="|">"|">="|"=="|"!=")
SPECIAL [ntafrbv0]
SINGLELINE_COMMENT [/][/](([\\][\n])|(.))*
MULTILINE_COMMENT (\/\*)([^\*]|\*[^\/])*(\*\/)
UNFINISHED_COMMENT ([/][*])([^\*]|\*[^\/])*



%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}

"if"	{   printlog<<"Line# "+to_string(line_count)+": Token <IF> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("IF : if", yylineno, yylineno,true); //true means it is a leaf
			return IF;
		
		}
		
"else"	{  printlog<<"Line# "+to_string(line_count)+": Token <ELSE> Lexeme "+yytext+" found"<<endl;
            yylval = new TreeVertex("ELSE : else", yylineno, yylineno,true);
			return ELSE;
		
		}

"for"	{  printlog<<"Line# "+to_string(line_count)+": Token <FOR> Lexeme "+yytext+" found"<<endl;
             yylval = new TreeVertex("FOR : for", yylineno, yylineno,true);
			return FOR;
		}


"while"	{   printlog<<"Line# "+to_string(line_count)+": Token <WHILE> Lexeme "+yytext+" found"<<endl;
              yylval = new TreeVertex("WHILE : while", yylineno, yylineno,true);
			return WHILE;
		}


"do"	{    printlog<<"Line# "+to_string(line_count)+": Token <DO> Lexeme "+yytext+" found"<<endl;
              yylval = new TreeVertex("DO : do", yylineno, yylineno,true);
			return DO;
		}



"break"	{  printlog<<"Line# "+to_string(line_count)+": Token <BREAK> Lexeme "+yytext+" found"<<endl;
             yylval = new TreeVertex("BREAK : break", yylineno, yylineno,true);
			return BREAK;
		}



"int"	{   printlog<<"Line# "+to_string(line_count)+": Token <INT> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("INT : int", yylineno, yylineno,true);
			return INT;
		}




"char"	{   printlog<<"Line# "+to_string(line_count)+": Token <CHAR> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("CHAR : char", yylineno, yylineno,true);
			return CHAR;
		}



"float"	{
	     printlog<<"Line# "+to_string(line_count)+": Token <FLOAT> Lexeme "+yytext+" found"<<endl;
	     yylval = new TreeVertex("FLOAT : float", yylineno, yylineno,true);
		 return FLOAT;
		}


"double"	{
			printlog<<"Line# "+to_string(line_count)+": Token <DOUBLE> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("DOUBLE : double", yylineno, yylineno,true);
			return DOUBLE;
		}



"void"	{   printlog<<"Line# "+to_string(line_count)+": Token <VOID> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("VOID : void", yylineno, yylineno,true);
			return VOID;
		}


"return" {  printlog<<"Line# "+to_string(line_count)+": Token <RETURN> Lexeme "+yytext+" found"<<endl;
			yylval = new TreeVertex("RETURN : return", yylineno, yylineno,true);
			return RETURN;

		}



"switch" {  printlog<<"Line# "+to_string(line_count)+": Token <SWITCH> Lexeme "+yytext+" found"<<endl;
             yylval = new TreeVertex("SWITCH : switch", yylineno, yylineno,true);
			return SWITCH;
		}


"case"	{  printlog<<"Line#"+to_string(line_count)+": Token <CASE> Lexeme "+yytext+" found"<<endl;
            yylval = new TreeVertex("CASE : case", yylineno, yylineno,true);
	     return CASE;
		}



"default"	{
			printlog<<"Line#"+to_string(line_count)+": Token <DEFAULT> Lexeme "+yytext+" found"<<endl;
			 yylval = new TreeVertex("DEAFULT : default", yylineno, yylineno,true);
			return DEFAULT;
		}


"continue"	{
			printlog<<"Line#"+to_string(line_count)+": Token <CONTINUE> Lexeme "+yytext+" found"<<endl;
			 yylval = new TreeVertex("CONTINUE : continue", yylineno, yylineno,true);
			return CONTINUE;
		}


"println"	{
	         printlog<<"Line# "+to_string(line_count)+": Token <PRINTLN> Lexeme "+yytext+" found"<<endl;
	         yylval = new TreeVertex("PRINTLN : println", yylineno, yylineno,true);
			 return PRINTLN;
        	}

{DIGIT}+ 	{
			
		SymbolInfo *si = new SymbolInfo();
		si->setName(yytext);
		si->setType("CONST_INT");
		printlog<<"Line# "+to_string(line_count)+": Token <CONST_INT> Lexeme "+yytext+" found"<<endl;
		// yylval = si;
		yylval = new TreeVertex(si, string("CONST_INT : ") + yytext, yylineno,true);
		// yylval = new TreeVertex(si);
		return CONST_INT;
			
}

{FLOATING_POINT_LITERALS} {


	SymbolInfo *si = new SymbolInfo();
		si->setName(yytext);
		si->setType("CONST_FLOAT");
		printlog<<"Line# "+to_string(line_count)+": Token <CONST_FLOAT> Lexeme "+yytext+" found"<<endl;
		// yylval= si;
		yylval = new TreeVertex(si, string("CONST_FLOAT : ") + yytext, yylineno,true);
		// yylval = new TreeVertex(si);
		return CONST_FLOAT;
			
			

}

({DIGIT}+{IDENTIFIER}+)+  {
		
		total_errors++;
}


({DIGIT}+\.{DIGIT}+\.{DIGIT}+)+ {

        		
		total_errors++;
		
}



{DIGIT}+([Ee][+-]?{DIGIT}+)+(\.{DIGIT}+)+	{

		
		total_errors++;

}



{DIGIT}+(\.[^{DIGIT}])	{

			
		total_errors++;

			
}






"+"		|

"-"		{


            SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("ADDOP");
			printlog<<"Line# "+to_string(line_count)+": Token <ADDOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("ADDOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return ADDOP;
		
		}
		

"*"		|
"/"		|
"%"		 {


	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("MULOP");
			printlog<<"Line# "+to_string(line_count)+": Token <MULOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("MULOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return MULOP;
		 
		 }	


"++" {   

	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
			printlog<<"Line# "+to_string(line_count)+": Token <INCOP> Lexeme "+yytext+" found"<<endl;
		    si->setType("INCOP");
		    // yylval = si;
			yylval = new TreeVertex(si, string("INCOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return INCOP;
			
		}

"--" {   

	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("DECOP");
			printlog<<"Line# "+to_string(line_count)+": Token <DECOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("DECOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return DECOP;
			
		}
		



{RELOP} {

	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("RELOP");
			printlog<<"Line# "+to_string(line_count)+": Token <RELOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("RELOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return RELOP;
			
		}


{LOGICOP} {


	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("LOGICOP");
			printlog<<"Line# "+to_string(line_count)+": Token <LOGICOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("LOGICOP : ") + yytext, yylineno,true);
		    return LOGICOP;
			
		}

"=" {       
	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("ASSIGNOP");
			printlog<<"Line# "+to_string(line_count)+": Token <ASSIGNOP> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("ASSIGNOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return ASSIGNOP;
			
		}


"!"		{

	        SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("NOT");
			printlog<<"Line# "+to_string(line_count)+": Token <LOGICOP> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			yylval = new TreeVertex(si, string("LOGICOP : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return NOT;
			
        }

"("		{   
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("LPAREN");
			printlog<<"Line# "+to_string(line_count)+": Token <LPAREN> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			yylval = new TreeVertex(si, string("LPAREN : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return LPAREN;
			
        }

")"		{
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("RPAREN");
			printlog<<"Line# "+to_string(line_count)+": Token <RPAREN> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			yylval = new TreeVertex(si, string("RPAREN : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return RPAREN;
			
        }

"{"		{   
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("LCURL");
			printlog<<"Line# "+to_string(line_count)+": Token <LCURL> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			yylval = new TreeVertex(si, string("LCURL : ") + yytext, yylineno,true);
			// yylval = new TreeVertex(si);
		    return LCURL;
		
        } 


"}"		{    
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("RCURL");
			printlog<<"Line# " +to_string(line_count)+": Token <RCURL> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			// yylval = new TreeVertex(si);
			yylval = new TreeVertex(si, string("RCURL : ") + yytext, yylineno,true);
		    return RCURL;
		
        }
"["		{
			
			 SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("LTHIRD");
			printlog<<"Line# "+to_string(line_count)+": Token <LSQUARE> Lexeme "+yytext+" found"<<endl;
		    // yylval = si;
			// yylval = new TreeVertex(si);
			yylval = new TreeVertex(si, string("LSQUARE : ") + yytext, yylineno,true);
		    return LTHIRD;
			
        }

"]"		{
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("RTHIRD");
			printlog<<"Line# "+to_string(line_count)+": Token <RSQUARE> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			// yylval = new TreeVertex(si);
			yylval = new TreeVertex(si, string("RSQUARE : ") + yytext, yylineno,true);
		    return RTHIRD;
			
        } 

","		{
			 SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("COMMA");
			printlog<<"Line# "+to_string(line_count)+": Token <COMMA> Lexeme "+yytext+" found"<<endl;
		    // yylval= si;
			yylval = new TreeVertex(si, "COMMA : ,", yylineno,true);
		    return COMMA;
			
        }

";"		{
	         SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("SEMICOLON");
			printlog<<"Line# "+to_string(line_count)+": Token <SEMICOLON> Lexeme "+yytext+" found\n";
		    // yylval = si;
			yylval = new TreeVertex(si, "SEMICOLON : ;", yylineno,true);
		    return SEMICOLON;
		    
        }


====commentSection========

{SINGLELINE_COMMENT}  {	
	     
		 reserveLC=line_count;
       
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}
        
        	
       
		
}

{MULTILINE_COMMENT}  {
		

        
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}		
}

{UNFINISHED_COMMENT} {
		
		for(int i = 0; i < yyleng; i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}
       
		total_errors++;
}

=========STRINGSECTION=============

"\"" {
	str = "";
	str += yytext;
	start_line = line_count;
	BEGIN STRINGSTATE;
}

<STRINGSTATE>"\\\"" {
    cout<<"original quote"<<endl; //corner case handle...if in string extra double quote is given with backslash...
	str += yytext;
}


====multilineString======

<STRINGSTATE>"\\\n"|"\\\r\n" {
	str += yytext;
    reserveLC=line_count;
	line_count++;
    isMultiLine=true;
}

====2ndquotationIsfound=======

<STRINGSTATE>"\"" {
	str += yytext;

    string tmp;
    for(int i = 0; i < str.size(); i++){

        //check if backslash is found

        if(str[i] == '\\' && (i + 1 )!= str.size())
        
        {   //new line check
            if(str[i + 1] == '\n'){
                i++;
                continue;
            }
            //new line check
            if(i + 2 < str.size() && str[i + 1] == '\r' && str[i + 2] == '\n'){
                i += 2;
                continue;
            }
            //modifying for the token
            string tempTok(1, str[i]);
            tempTok += str[i + 1];
            tempTok = EscapeCharacter(tempTok);
            cout<<"string er escape"<<endl;
            cout<<tempTok;
            if(tempTok != "x"){
                tmp += tempTok;
                i++;
            }
            continue;
        }
        
        tmp += str[i];
    }
    //log file e just jevabe ache oivabe print kore dibo....
    //but token er jonno modify kora lagbe
    
        const char *cstr = str.c_str();
        
        
        //converting string to char array
        //string temp2;
        	char arrr[tmp.length()-2]; 
            cout<<endl;
       for (int x = 1,y=0; y < (sizeof(arrr)); x++,y++) { 
             
            arrr[y] = tmp[x]; 
             //cout<<arrr[y];

            
        }
        
        
        //const char *cstrTok = temp2.c_str();
        if(isMultiLine==true)
       {
        
      
       for (int y=0; y < (sizeof(arrr)); y++) { 
             
            
           

            
        }
         
       
	   
       }
       else if(isMultiLine==false)
       {
        //fprintf(tokenout,"<SINGLE LINE STRING, ");
       for (int y=0; y < (sizeof(arrr)); y++) 
        { 
             
            
        }
       
       }
       isMultiLine=false;
	BEGIN INITIAL;
}

<STRINGSTATE>[^\n] {
	str += yytext;
}



<STRINGSTATE>[\n]|"\r\n" { 
    
    const char *cstr = str.c_str();
     
		
		total_errors++;
	    line_count++;
	    str = "";
	    BEGIN INITIAL;

}
<STRINGSTATE><<EOF>> { 
    //if string is not finished but end of file
    const char *cstr = str.c_str();
       
		total_errors++;
	    //line_count++;
	    str = "";
	    BEGIN INITIAL;

}

=======characterLiterals============

"'"	{
	log_char+=yytext;
	BEGIN char_start;
}

<char_start>["\'"] {
		log_char+=yytext;
          const char *cstr = log_char.c_str();
         
		total_errors++;
        log_char="";
		BEGIN INITIAL;

}

<char_start>{NEWLINE} {

		log_char+=yytext;
		const char *cstr = log_char.c_str();
          
		total_errors++;
		log_char="";
		line_count++;
		BEGIN INITIAL;
}

<char_start>["\\"] {
	log_char+=yytext;
	BEGIN special_char_start;
}


<special_char_start>{SPECIAL} {
	log_char+=yytext;
    const char *cstr = log_char.c_str();

	token_char=EscapeCharacter(cstr+1);
	BEGIN char_end;

}
<special_char_start>["\'"] {
	log_char+=yytext;
	const char *cstr = log_char.c_str();
        
		total_errors++;
		log_char="";
		//line_count++;
		BEGIN INITIAL;

}


<char_start>[^\n\t\r] {
	log_char+=yytext;
	token_char+=yytext;
	BEGIN char_end;
}

<char_end>["\'"] {
	log_char+=yytext;
      //cout<<"yytext is "<<yytext<<endl;
    //cout<<"log_char iis "<<log_char<<endl;
    const char *cstr = log_char.c_str();
     const char *cstrTok = token_char.c_str();
        
		SymbolInfo *si = new SymbolInfo();	
			si->setName(cstrTok);
		    si->setType("CONST_CHAR");
			//printlog<<"Line# "+to_string(line_count)+": Token <CONST_CHAR> Lexeme "+yytext+" found\n";
		   yylval = new TreeVertex(si, string("CONST_CHAR : ") + yytext, yylineno,true);
		    return CONST_CHAR;

	log_char="";
    token_char="";
    // cout<<"yytext is "<<yytext<<endl;
    // cout<<"log_char iis "<<log_char<<endl;
	BEGIN INITIAL;
}

<char_end>{NEWLINE} {

		log_char+=yytext;
         const char *cstr = log_char.c_str();
        
		total_errors++;
		log_char="";
		line_count++;
		BEGIN INITIAL;
}



<char_end>({WHITESPACE}+{NEWLINE}) {

		log_char+=yytext;
         const char *cstr = log_char.c_str();
        
		total_errors++;
		log_char="";
		line_count++;
		BEGIN INITIAL;
}

<char_end>[;] {

		//log_char+=yytext;
         const char *cstr = log_char.c_str();
     	
		total_errors++;
		log_char="";

		 SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("SEMICOLON");

		    yylval = new TreeVertex(si, "SEMICOLON : ;", yylineno,true);
		    return SEMICOLON;
		//line_count++;
        cout<<"new semiciolon rule";
		BEGIN INITIAL;
}



<char_end>[^']	{
         log_char+=yytext;
       
		BEGIN multichar_start;
		
}

<multichar_start>(.)*["\'"] {

    log_char+=yytext;
         const char *cstr = log_char.c_str();
        	
		total_errors++;
		log_char="";
		BEGIN INITIAL;

}

<char_end><<EOF>> {

		log_char+=yytext;
        const char *cstr = log_char.c_str();
     
		total_errors++;
		log_char="";
		BEGIN INITIAL;
}

{IDENTIFIER} {
			
           	SymbolInfo *si = new SymbolInfo();	
			si->setName(yytext);
		    si->setType("ID");
			printlog<<"Line# "+to_string(line_count)+": Token <ID> Lexeme "+yytext+" found\n";
		    // yylval= si;
			yylval = new TreeVertex(si, string("ID : ") + yytext, yylineno,true);
		    return ID;
          }


<<EOF>> {
	return 0;
}
. {
	printlog<<"Error at line# "+to_string(line_count)+": UNRECOGNIZED CHAR "+yytext<<endl;
		total_errors++;
}
%%
int yywrap()
{
	return 1;
}
