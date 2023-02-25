%option noyywrap

%x STRINGSTATE
%x char_start
%x char_end
%x special_char_start
%x multichar_start
%x multichar_end


%{
#include<bits/stdc++.h>
#include"1905053_symbolTable.h"
#include<stdlib.h>
#include<string>
#include<algorithm>
#include <fstream>
#include <iostream>
#include <fstream>


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

FILE *logout;
FILE *tokenout;






SymbolTable table(10,0);


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
INCOP ("--"|"++")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
SPECIAL [ntafrbv0]
SINGLELINE_COMMENT [/][/](([\\][\n])|(.))*
MULTILINE_COMMENT (\/\*)([^\*]|\*[^\/])*(\*\/)
UNFINISHED_COMMENT ([/][*])([^\*]|\*[^\/])*



%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}

"if"	{
			fprintf(tokenout,"<IF, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
		}

"for"	{
			fprintf(tokenout,"<FOR, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
		}


"while"	{
			fprintf(tokenout,"<WHILE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		}


"do"	{
			fprintf(tokenout,"<DO, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
		}



"break"	{
			fprintf(tokenout,"<BREAK, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
		}



"int"	{
			fprintf(tokenout,"<INT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
		}




"char"	{
			fprintf(tokenout,"<CHAR, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
		}



"float"	{
			fprintf(tokenout,"<FLOAT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		}


"double"	{
			fprintf(tokenout,"<DOUBLE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}



"void"	{
			fprintf(tokenout,"<VOID, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
		}


"return"	{
			fprintf(tokenout,"<RETURN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
		}



"switch" {
			fprintf(tokenout,"<SWITCH, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
		}


"case"	{
			fprintf(tokenout,"<CASE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
		}



"default"	{
			fprintf(tokenout,"<DEFAULT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}


"continue"	{
			fprintf(tokenout,"<CONTINUE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}




{DIGIT}+ 	{
			fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
		    fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
			
}

{FLOATING_POINT_LITERALS} {


	fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
		    fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			

}

({DIGIT}+{IDENTIFIER}+)+  {
		fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,yytext);		
		total_errors++;
}


({DIGIT}+\.{DIGIT}+\.{DIGIT}+)+ {

         fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,yytext);		
		total_errors++;
		
}



{DIGIT}+([Ee][+-]?{DIGIT}+)+(\.{DIGIT}+)+	{

		fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);		
		total_errors++;

}



{DIGIT}+(\.[^{DIGIT}])	{

		fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);		
		total_errors++;

			
}






"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}
		

"*"		|
"/"		|
"%"		 {
		  fprintf(tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
		 }	


{INCOP} {
			fprintf(tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);

		}



{BITOP} {
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
		}

{RELOP} {
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
		}


{LOGICOP} {
			fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
		}

"=" {
			fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
		}


"!"		{
			fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
        }

"("		{
			fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
        }

")"		{
			fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
        }

"{"		{
			fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			table.EnterScope();
        } 


"}"		{
			fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			table.ExitScope();
        }
"["		{
			fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
        }

"]"		{
	     fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
        } 

","		{
			fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
        }

";"		{
		fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
            cout<<"old semiciolon rule\n";
        }


====commentSection========

{SINGLELINE_COMMENT}  {	
	     
		 reserveLC=line_count;
       
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}
        
        fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",reserveLC,yytext);	
       
		
}

{MULTILINE_COMMENT}  {
		

        fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_count,yytext);	
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}		
}

{UNFINISHED_COMMENT} {
		//  fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s \n",line_count,yytext);		
		// total_errors++;
		for(int i = 0; i < yyleng; i++){
			if(yytext[i] == '\n'){
				line_count++;
			}
		}
        fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",line_count,yytext);		
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
        
        //fprintf(tokenout,"<MULTI LINE STRING,%s>\n",cstrTok);
       fprintf(tokenout,"<MULTI LINE STRING, ");
       for (int y=0; y < (sizeof(arrr)); y++) { 
             
             fprintf(tokenout,"%c",arrr[y]);
           

            
        }
         fprintf(tokenout,">\n");
       
	   fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",start_line,cstr);
       
       }
       else if(isMultiLine==false)
       {
        fprintf(tokenout,"<SINGLE LINE STRING, ");
       for (int y=0; y < (sizeof(arrr)); y++) 
        { 
             
             fprintf(tokenout,"%c",arrr[y]);  
        }
         fprintf(tokenout,">\n");
	   fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",line_count,cstr);
       }
       isMultiLine=false;
	BEGIN INITIAL;
}

<STRINGSTATE>[^\n] {
	str += yytext;
}



<STRINGSTATE>[\n]|"\r\n" { 
    //if string is not finished that means without giving backslash newline is pressed then it will become an unfinished string
    const char *cstr = str.c_str();
        fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,cstr);
		total_errors++;
	    line_count++;
	    str = "";
	    BEGIN INITIAL;

}
<STRINGSTATE><<EOF>> { 
    //if string is not finished but end of file
    const char *cstr = str.c_str();
        fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,cstr);
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
          fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",line_count,cstr);	
		total_errors++;
        log_char="";
		BEGIN INITIAL;

}

<char_start>{NEWLINE} {

		log_char+=yytext;
		const char *cstr = log_char.c_str();
          fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s",line_count,cstr);	
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
         fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,cstr);		
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

        fprintf(tokenout,"<CONST_CHAR, %s>\n",cstrTok);
			fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,cstrTok);

	log_char="";
    token_char="";
    // cout<<"yytext is "<<yytext<<endl;
    // cout<<"log_char iis "<<log_char<<endl;
	BEGIN INITIAL;
}

<char_end>{NEWLINE} {

		log_char+=yytext;
         const char *cstr = log_char.c_str();
         fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s",line_count,cstr);		
		total_errors++;
		log_char="";
		line_count++;
		BEGIN INITIAL;
}



<char_end>({WHITESPACE}+{NEWLINE}) {

		log_char+=yytext;
         const char *cstr = log_char.c_str();
         fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s",line_count,cstr);		
		total_errors++;
		log_char="";
		line_count++;
		BEGIN INITIAL;
}

<char_end>[;] {

		//log_char+=yytext;
         const char *cstr = log_char.c_str();
         fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,cstr);		
		total_errors++;
		log_char="";
        fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
		//line_count++;
        cout<<"new semiciolon rule";
		BEGIN INITIAL;
}



<char_end>[^']	{
         log_char+=yytext;
        //  const char *cstr = log_char.c_str();
        //  fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s \n",line_count,cstr);		
		// total_errors++;
		// log_char="";
		BEGIN multichar_start;
		
}

<multichar_start>(.)*["\'"] {

    log_char+=yytext;
         const char *cstr = log_char.c_str();
         fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",line_count,cstr);		
		total_errors++;
		log_char="";
		BEGIN INITIAL;

}

<char_end><<EOF>> {

		log_char+=yytext;
        const char *cstr = log_char.c_str();
         fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,cstr);		
		total_errors++;
		log_char="";
		BEGIN INITIAL;
}

{IDENTIFIER} {
			
            fprintf(tokenout,"<ID, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);

			bool flag= table.Insert(yytext, "ID" );

			if(flag==true){
				 string str=table.printAllScopeTableForLogFile();
                 const char *cstr = str.c_str();
                fprintf(logout,"%s",cstr);		
				cout<<"aschi";
               
              }
			else if(flag==false)
			{
				fprintf(logout,"	%s already exisits in the current ScopeTable\n",yytext);
			}
          }


<<EOF>> { 
	string str=table.printAllScopeTableForLogFile();
                 const char *cstr = str.c_str();
                fprintf(logout,"%s",cstr);
                fprintf(logout,"Total lines: %d\n",line_count);
                fprintf(logout,"Total errors: %d\n",total_errors);
	return 0;
}

. {
	fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",line_count,yytext);
		total_errors++;
}

%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	//table.print();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
