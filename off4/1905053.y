%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<string>
#include<cmath>
#include "sym.h"
#include "treevertex.h"
 #define YYSTYPE TreeVertex*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;

SymbolTable *table;
vector<string> typeParameterList;
vector<string> argumentList;
vector<string> parName;
vector<SymbolInfo*> declarationList;
SymbolInfo *retType;
ofstream printlog;
ofstream errorout;
ofstream treeout;
int currentOffset=0; 
extern int line_count;
extern int total_errors;
extern int reserveLC;
extern int start_line;
int ifCount=0;
int whileCount=0;
int forCount=0;
stack<int> ifCountStack;
stack<int> whileCountStack;
stack<int> forCountStack;
vector<SymbolInfo*> symbParameterList;
string methodName;
int parameterCount=0;
int paralistEndWhere=0;
int errorIdExtra=0;
int checkSe=-1;
bool isMainDefined=false;
int reserveLineForDefinition;
vector<string> parseTree;
 int labelCount=0;
int tempCount=0;
string currentFunc="";
//CodeGen cg;
FILE *assemblyfile;
ifstream asmly;
ofstream opt;



 void printSyntaxerror(string str)
{
	//errorout  << "Line# " << line_count <<": " <<str <<"\n";
}
void yyerror(string str,int flag=0,int extra=0)
{
	//write your code
     bool isSyntaxError=false;

	//  if(flag==1)
	//  {isSyntaxError=true;
	//  printSyntaxerror(str);
	//  isSyntaxError=false;
	//  }
    //if (isSyntaxError==false)
	// if(str=="syntax error")
	// {}
	//else{
	errorout  << "Line# " << yylineno-extra <<": " <<str <<"\n";
	total_errors++;
	//}
}


vector<string>stringSplitter(const string &s)
{  string onestr = "";
    vector<string> splittedStrings;
    for (int i = 0; i < s.length(); i++) 
	{
        if (s[i] == ' '|| s[i] == ','|| s[i] == '\t')
		 {
            if (onestr != "")
			 {
                splittedStrings.push_back(onestr);
                onestr = "";
            }
        }
        else 
		{
            onestr += s[i];
        }
    }

    if (onestr != "")
	 {
        splittedStrings.push_back(onestr);
    }

    return splittedStrings;
}

string newLabel() {
	return "MYLABEL_"+to_string(labelCount++);
}
//not needed
char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}

//not needed
string getSP(string var) 
{
        string sp = "#";
        for(int i = 0, j = typeParameterList.size()-1; j>=0; j--, i++) {
                if(parName[j]== var)
				 {       cout<<endl<<"**************************************************"<<endl;
                        sp = "[BP+" + to_string(4 + 2*i) + "]";
                        break;
                }
        }
        return sp;
}

string getArrayName(const string s)
{
	stringstream ss(s);
	string item;
	while(getline(ss, item, '['))
		return item;
}

//checks if two or more different types of IDs are in same name...like int a, and a function named a
//, a function and a global variable cannot have the same symbol
bool errorID(string name,string variabletype,string type,int extra=0)
{
	if(variabletype != type)
	{
        string s = "\'" + name+"\' redeclared as different kind of symbol";
		if(extra==0)
        yyerror(s);
		else
		{
			int x=yylineno-extra;
				//cout<<"yyline non "<<yylineno<<" line "<<line<<endl;
				yyerror(s,0,x);
		}
        return true;
	}
	return false;
}


//checks if it is previously defined or not...
bool itIsdefined(SymbolInfo* it)
{
	if(it != NULL && it ->getIsDefined())
    {
        string s = "Multiple definition of " + it->name;
        yyerror(s);
        return true;
    }
    return false;
}

bool expressionReturnsVoid(string s,string type)
{
	if(s=="void")
    {
        string er = "Void cannot be used in " + type;
        yyerror(er);
        return true;
    }
	return false;
}

bool hasSameNameDiffParameter(SymbolInfo *curr, vector<string> tobeMatched,vector<string> declared) 
{       
	 
	if(tobeMatched != declared) 
    { 
		string str= "Conflicting types for \'" + curr->name+"\'";
  	 	yyerror(str);
  	 	return true;
    }
	
    return false;
}

bool isUndeclared(SymbolInfo *current, string name ,string type)
{
	if(current == NULL && type == "statement" || current == NULL && type == "variable")
    {
		string er = "Undeclared variable \'" + name+"\'";
        yyerror(er);
        return true;
    }
	else if(current == NULL && type == "factor")
	{
		//string er = "Undefined reference to "+ name;
		string er = "Undeclared function \'"+ name+"\'";
		yyerror(er);
		return true;
	}
	return false;
}

void goThroughParametersInFunction(vector<SymbolInfo*> paraL, string funcName,int line=0)
{
	int i = 0;
	while(i<paraL.size())
	{
		
			SymbolInfo *cur = table->LookupInScope(paraL[i]->name);
			if(cur) 
			{
               //check if parameter list has any duplicate name
				string str = "Redefinition of parameter \'" + paraL[i]-> name + "\'";
				if(line!=0)
				{int x=yylineno-line;
				cout<<"yyline non "<<yylineno<<" line "<<line<<endl;
				yyerror(str,0,x);}
				else
				yyerror(str);
			}
			else
                table->Insert2(paraL[i]->name, paraL[i]->type, paraL[i]->returnType, paraL[i]->variableType);
		
		i++;
	}
}

//for var_declaration
void declarationCheck(vector<SymbolInfo*> declist, string returnT,bool flag)
{
	  int i =0;
    if(returnT == "void"){
		string er="Variable or field \'"+declist[i] -> name+"\' declared void";
        yyerror(er);
        return;
    }
	
	while(i<declist.size())
	{
        SymbolInfo *current = table->Lookup(declist[i] -> name);
        declist[i]->returnType = returnT;
        if(current)
        {
            string s = "Conflicting types for\'"+declist[i]->name+"\'";
            yyerror(s);
        }
        else{
            table->Insert2(declist[i]->name, declist[i]->type,declist[i]->returnType, declist[i]->variableType);
			 string s;
            if(declist[i]->variableType=="array")
            {
                // = declist[i]->name + table->getCurrentScopeName() + " DW " + declist[i]->intToStr(declist[i]->getArraySize()) + " DUP(?)";

				if("1"==table->getCurrentScopeName()) { // global
								fprintf(assemblyfile, "%s DW %d DUP(?) ; %s[%d] declaration at Line %d\n", declist[i]->name.c_str(), declist[i]->arraySize, declist[i]->name.c_str(), declist[i]->arraySize,yylineno);
								///********************
								SymbolInfo* temp= table->Lookup(declist[i]->name);
								temp->setGlobal(true);
								//******************
							}
							else{
								for(int j=0; j<declist[i]->arraySize; j++){
									fprintf(assemblyfile, "PUSH AX \n");
									currentOffset-=2;
								}
								SymbolInfo* temp= table->Lookup(declist[i]->name);
								temp->setStackOffset(currentOffset); // arrayName[arraySize - 1] is at currentOffset[BP]
								temp->setGlobal(false);
							}
            }
            else
			
			{
                     //s = declist[i]->name + table->getCurrentScopeName() + " DW ?";
                           cout<<"**********"<< table->getCurrentScopeName()<<"  "<<declist[i]->name <<endl;
					 if("1"==table->getCurrentScopeName()) { // global
								fprintf(assemblyfile, "%s DW ? ; %s decl\n", declist[i]->name.c_str(), declist[i]->name.c_str());

									SymbolInfo* temp= table->Lookup(declist[i]->name);
								temp->setGlobal(true);
							}
							else{
								fprintf(assemblyfile, "PUSH AX  \n");
								currentOffset-=2;
								SymbolInfo* temp= table->Lookup(declist[i]->name);
								temp->setStackOffset(currentOffset);
								//cout<<"here glob"<<endl;
								temp->setGlobal(false); ////***********************************tocheck******************////
							}
			} 
           
        }
		i++;
	}

	cout<<"all okay "<<endl;
}

bool mismatchTypeError(string name,string type,string actual,int flag=0)
{
    if(type != actual)
    {
        string er= "\'" + name +"\' is not a " + actual;   //type mismatch
        yyerror(er);
        return true;
    }
    return false;
}

bool errorArgParameter(vector<string> arg,vector<string> para,string fname)
{
    if(para.size() != arg.size())

	{       
		string er="";
		if(arg.size()<para.size() )er="Too many arguments to function \'"+fname+"\'";
    	else 
		er="Too few arguments to function \'"+fname+"\'";
		yyerror(er);
		return true;
    }
    for(int i = 0; i < para.size(); i++)
	{
        if(arg[i] != para[i])
		{
            string s = "Type mismatch for argument "+to_string(i+1) +" of \'"+fname+"\'";
            yyerror(s);
            //return true;
        }
    }
	return false;
}

//OUTPUTS A SIGNED 16-BIT-INT STORED IN AX
void printPROCEDURE() {
	fprintf(assemblyfile,"\nPRINT_OUTPUT PROC ; OUTPUTS A SIGNED 16-BIT-INT STORED IN AX \n\
	LEA SI, NUM_STR \n\
    ADD SI, 5 \n\
    CMP AX, 0\n\
    JNL HERE\n\
    MOV FLAG, 1\n\
    NEG AX\n\
    HERE:\n\
        	DEC SI\n\
        	MOV DX, 0 \n\
        	MOV CX, 10\n\
        	DIV CX\n\
        	ADD DL, '0'\n\
        	MOV [SI], DL\n\
        	CMP AX, 0\n\
        	JNE HERE\n\
    CMP FLAG, 0\n\
    JNG NOT_NEG\n\
    MOV AH, 2\n\
    MOV DL, 45\n\
    INT 21H\n\
    MOV FLAG, 0\n\
	NOT_NEG:\n\
    MOV DX, SI\n\
    MOV AH, 9\n\
    INT 21H\n\
	MOV DX, OFFSET NL\n\
    MOV AH, 9\n\
    INT 21H\n\
    RET\n\
PRINT_OUTPUT ENDP\n");
}



%}

%code requires{
	#include "treevertex.h"
}
%define api.value.type {TreeVertex *}

// %code requires{
// 	#include "sym.h"
// }
// %define api.value.type {SymbolInfo *}

%token IF ELSE FOR WHILE DO INT CHAR FLOAT VOID PRINTLN BREAK DOUBLE SWITCH CASE DEFAULT RETURN CONTINUE
%token NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token COMMA SEMICOLON ADDOP MULOP INCOP DECOP LOGICOP RELOP ASSIGNOP
%token ID CONST_INT CONST_FLOAT CONST_CHAR
%left COMMA LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL RELOP LOGICOP ADDOP MULOP
%nonassoc LOWER_THAN_ELSE
%right ASSIGNOP INCOP DECOP NOT ELSE

%%

start : 
		{  //mandatory starting of any asm code
			fprintf(assemblyfile, ".MODEL SMALL\n");
		fprintf(assemblyfile, ".STACK 400H\n");
		fprintf(assemblyfile, ".DATA\n");
		fprintf(assemblyfile, ".CODE\n\tFLAG DB 0\n\tNL DB 13,10,\"$\"\n\tNUM_STR DB \"00000$\" \n");
		}


		program
	{
		//write your code in this block in all the similar blocks below
        printlog<<"start : program\n";
		$$ =  new TreeVertex("start : program", $2->getStart(), $2->getEnd());
		$$->addChild($2);
		printPROCEDURE();
		if(isMainDefined) fprintf(assemblyfile, "END MAIN\n");
		$$->print(treeout, 0);
		
	}
	;

program : program unit 
      {
         
         printlog<<"program : program unit\n";
		string sym = $1->getSymbol()->getName();                   
        sym += "\n" + $2->getSymbol()->getName();                  
		auto si = new SymbolInfo(sym,"program");
		$$ = new TreeVertex(si, "program : program unit",  $1->getStart(), $2->getEnd());
		$$->addChild($1);
		$$->addChild($2);
      }

     
	| unit
     {
        printlog<<"program : unit\n";
		string sym = $1->getSymbol()->getName();

		auto si = new SymbolInfo(sym,"program");
		$$ = new TreeVertex(si, "program : unit",  $1->getStart(), $1->getEnd());
		$$->addChild($1);
     }
	
	;
	
unit : var_declaration
     {
        printlog<<"unit : var_declaration\n";
		
		string sym = $1->getSymbol()->getName();                   
		auto si = new SymbolInfo(sym,"unit");
		$$ = new TreeVertex(si, "unit : var_declaration",  $1->getStart(), $1->getEnd());
		$$->addChild($1);
     }
     | func_declaration
     {
         printlog<<"unit : func_declaration\n";
		string sym = $1->getSymbol()->getName();                   
		auto si = new SymbolInfo(sym,"unit");
		$$ = new TreeVertex(si, "unit : func_declaration",  $1->getStart(), $1->getEnd());
		$$->addChild($1);
     }
     | func_definition
     {
        printlog<<"unit : func_definition\n";
		string sym = $1->getSymbol()->getName();                   
		auto si = new SymbolInfo(sym,"unit");
		$$ = new TreeVertex(si, "unit : func_definition",  $1->getStart(), $1->getEnd());
		$$->addChild($1);
     }
	
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
     {
        printlog<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n";
        string str=$1->getName()+" "+$2->getName()+"(" + $4->name  + ");";
		    auto si = new SymbolInfo(str);
            //printlog<<str<<"\n\n";
			$$ = new TreeVertex(si, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",  $1->getStart(), $6->getEnd());
			$$->addChild($1);
			 $$->addChild($2);
			 $$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

		

		SymbolInfo* cur = table->LookupInScope($2->getSymbol()->name);
		   

         if(cur)
		 {   
			if(!errorID(cur->name,cur->variableType,"function"))

			{    cout<<"HERE 2ND IF";
                    if(!hasSameNameDiffParameter($2->getSymbol(),typeParameterList,cur->getParameterList()))
					{    cout<<"HERE";
						 yyerror(string("Multiple declaration of ") + $2->getSymbol() -> name);
					}
			}
			paralistEndWhere=$5->getStart();

		 }
		 else

		 {   cout<<"HERE ELSE";
		
			table->Insert2($2->getSymbol()->name, "ID", $1->getSymbol()->name, "function", typeParameterList);
			paralistEndWhere=$5->getStart();
		 }
		//  methodName=$2->name;
		//  goThroughParametersInFunction(symbParameterList, methodName);
		//  methodName="";


		for(int i = 0; i<symbParameterList.size(); i++)
          {
			for(int j= i+1; j<symbParameterList.size(); j++)
			{
				if(symbParameterList[i]->name==symbParameterList[j]->name)
				{
					string str = "Redefinition of parameter \'" + symbParameterList[i]-> name + "\'";
					yyerror(str);
				}
				
			}
		  }
		cout<<"sesh print"<<endl;
		
		 typeParameterList.clear();
		 symbParameterList.clear();
		 parName.clear();

		 

     }
		| type_specifier ID LPAREN RPAREN SEMICOLON

		{


          printlog<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n";
        string str=$1->getName();
        str+=" "+$2->getName();
        str += "();";  //no parameter function

		auto si = new SymbolInfo(str);
		$$ = new TreeVertex(si, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",  $1->getStart(), $5->getEnd());
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
          $$->addChild($5);

		SymbolInfo* cur = table->LookupInScope($2->name);

         if(cur)
		 {
			if(!errorID(cur->name,cur->variableType,"function"))

			{   
				cout<<"hereeeeee2";
                    if(!hasSameNameDiffParameter($2->getSymbol(),typeParameterList,cur->getParameterList()))
					{    cout<<"here1";
						 yyerror(string("Multiple declaration of ") + $2 -> name);
					}
			}
              paralistEndWhere=$5->getStart();
		 }
		 else
		 {
			//all okay,then insert in scope table
			table->Insert2($2->name, "ID", $1->name, "function", typeParameterList);
			paralistEndWhere=$5->getStart();
		 }
		 
		}

		

		
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 

        {    
			reserveLineForDefinition=$1->getStart();
			retType=$1->getSymbol();
            methodName=$2->name;
			currentFunc=methodName;
			SymbolInfo* cur = table->LookupInScope(methodName);

			

			 if(cur)
			{   errorIdExtra=$5->getStart();
				if(!errorID(cur->name,cur->variableType,"function",errorIdExtra))

				{
                    if(cur-> getReturnType() != $1->name)
                   
					{
						  yyerror(string("Conflicting types for \'")+ methodName+"\'");
						  if($1->name=="VOID"||$1->name=="void")
						  printlog<<"FUNCTION VOID"<<endl;

					}

					if(!hasSameNameDiffParameter($2->getSymbol(),typeParameterList,cur->getParameterList()))
					{    cout<<"reached";
					     if(cur->isDefined) // if already defined generate error
						 if(!itIsdefined(cur)) 
						 cur->isDefined=true;

					}
				}
				paralistEndWhere=$5->getStart();

		 	}
		 	else
		 	{
			table->Insert2($2->name, "ID", $1->name, "function", typeParameterList,true);
			paralistEndWhere=$5->getStart();
			cout<<endl<<"fghj "<<paralistEndWhere<<endl;
		 	}

			;

           //start of the function ...prepare stack pointer
			fprintf(assemblyfile, "\n%s PROC     ;start of %s function at Line %d \n", methodName.c_str(), methodName.c_str(),yylineno);
			fprintf(assemblyfile, "\tPUSH BP\n\tMOV BP, SP\n");


		}compound_statement
		{

		printlog<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n";
        string str = $1->name+" " + $2->name+ "(" + $4->name + ")"+$7->name;                  
        

		auto si = new SymbolInfo(str);                     

    	$$ = new TreeVertex(si, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",  $1->getStart(), $7->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($7);
			paralistEndWhere=$5->getStart();
			cout<<endl<<"fghj "<<paralistEndWhere<<endl;

        retType = NULL;

                 
            
		     currentOffset=0; 
			fprintf(assemblyfile, "%s_EXIT:\n", $2->name.c_str());
			fprintf(assemblyfile, "\tMOV SP, BP ; Restoring SP before exiting\n");
			fprintf(assemblyfile, "\tPOP BP\n");
			fprintf(assemblyfile, "\tRET %d\n", 2*parameterCount); //clearing parameter's place
			fprintf(assemblyfile, "%s ENDP   ;end of %s function at Line %d\n", $2->name.c_str(),$2->name.c_str(),yylineno);

		
		//typeParameterList.clear();
		 symbParameterList.clear();
		 parName.clear();
		 methodName="";
		}
         
		| type_specifier ID LPAREN RPAREN 
		{    
			reserveLineForDefinition=$1->getStart();
				retType=$1->getSymbol();
             methodName=$2->name;
			 if(methodName == "main") isMainDefined=true;
			 currentFunc=methodName;

			 SymbolInfo* cur = table->LookupInScope(methodName);

			 if(cur)
			{   errorIdExtra=$4->getStart();
				if(!errorID(cur->name,cur->variableType,"function",errorIdExtra))

				{
                    if(cur-> getReturnType() != $1->name)
                   
					{
						cout<<"In function definition....1";
						  yyerror(string("Return type doesnn't match with the declaration in function ")+ methodName);
					}

					if(!hasSameNameDiffParameter($2->getSymbol(),typeParameterList,cur->getParameterList()))
					{
						cout<<"founddd";
						 if(!itIsdefined(cur)) 
						 cur->isDefined=true;
						 
					}
				}
				paralistEndWhere=$4->getStart();

		 	}
		 	else
		 	{
			table->Insert2($2->name, "ID", $1->name, "function", typeParameterList,true);
			paralistEndWhere=$4->getStart();
		 	}

			fprintf(assemblyfile, "\n%s PROC     ;start of %s function at line %d\n", methodName.c_str(), methodName.c_str(),yylineno);
			if(methodName=="main") 
			{
				fprintf(assemblyfile, "\tMOV AX, @DATA\n\tMOV DS, AX\n");
			}
			fprintf(assemblyfile, "PUSH BP\nMOV BP, SP\n");

		}compound_statement
		{
			printlog<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n"; //func with no parameter
        string str = $1->name+ " " + $2->name+"()"+ $6->name;                     
        auto si = new SymbolInfo(str);

		$$ = new TreeVertex(si, "func_definition : type_specifier ID LPAREN RPAREN compound_statement",  $1->getStart(), $6->getEnd());
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($6);
		paralistEndWhere=$4->getStart();
       
       
            currentOffset=0;
			fprintf(assemblyfile, "%s_EXIT:      \n", $2->getName().c_str());
			fprintf(assemblyfile, "\tMOV SP, BP ; Restoring SP before exiting from the scope\n");
			fprintf(assemblyfile, "\tPOP BP\n");
			if($2->getName()=="main")
			 {
				fprintf(assemblyfile, "\tMOV AH, 4CH\n\tINT 21H\n");
			} else 
			{
				fprintf(assemblyfile, "\tRET   ;to get back to where it was called\n");
			}

			fprintf(assemblyfile, "%s ENDP  ;end of %s function at Line %d\n", $2->getName().c_str(),$2->getName().c_str(),yylineno);
        retType = NULL;
		//typeParameterList.clear();
		 symbParameterList.clear();
		 parName.clear();
		 methodName="";
		}

		
	
	
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
         {
            typeParameterList.push_back($3->name);
           printlog<<"parameter_list  : parameter_list COMMA type_specifier ID\n";
		   string str = $1->name+ "," + $3->name+ " " + $4->name;                  
        	auto si = new SymbolInfo(str);
        	$4->getSymbol()->returnType = $3->name;
			$4->getSymbol()->variableType = "variable";
        	symbParameterList.push_back($4->getSymbol());
			parName.push_back($4->name);
           
			$$ = new TreeVertex(si, "parameter_list : parameter_list COMMA type_specifier ID",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

		 }
		| parameter_list COMMA type_specifier
		{
			 typeParameterList.push_back($3->name);
           printlog<<"parameter_list : parameter_list COMMA type_specifier\n";
		   string str = $1->name+ "," + $3->name;                        
			auto si = new SymbolInfo(str);
			SymbolInfo *it = new SymbolInfo("", "ID"); //It has no variable name ,only type is given
           it->variableType = "variable";
           it->returnType = $3->name;
          symbParameterList.push_back(it);
		   
		   $$ = new TreeVertex(si, "parameter_list : parameter_list COMMA type_specifier",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
		}
 		| type_specifier ID

		{
              typeParameterList.push_back($1->name);
			  parName.push_back($2->name);
           printlog<<"parameter_list  : type_specifier ID \n";
                string str = $1->name+" "+$2->name; 
				 auto si = new SymbolInfo(str);
             $2->getSymbol()->variableType = "variable";
        	 $2->getSymbol()->returnType = $1->name;
        	symbParameterList.push_back($2->getSymbol());
            
			$$ = new TreeVertex(si, "parameter_list : type_specifier ID",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);

	
		}
		| type_specifier

		{
               typeParameterList.push_back($1->name);
           printlog<<"parameter_list : type_specifier\n";
                string str = $1->name; 
				//str+=" "+$2->name;
				 auto si = new SymbolInfo(str);
				 SymbolInfo *it = new SymbolInfo("", "ID"); //It has no variable name ,only type is given
           	it->variableType = "variable";
           	it->returnType = $1->name;
          	symbParameterList.push_back(it);
		  
			$$ = new TreeVertex(si, "parameter_list : type_specifier",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
		}
		// |
		//  parameter_list error{
             
		// 	  	yyclearin;
		// //yyerrok;
		// 	printlog << "Error at line no " << line_count <<" : syntax error" <<"\n";
		// yyerror("Syntax error at parameter list of function definition");
		// 		$$ = new TreeVertex("parameter_list : error",  $1->getStart(), $2->getEnd());
		// 		$$->addChild($1);
		// 		$$->addChild($2);
			
		// }
	
 		;

 		
compound_statement : LCURL enter_scope statements RCURL
				{   cout<<"cmp er vitore "<<endl; 
                	//table->EnterScope();
                 //goThroughParametersInFunction(symbParameterList, methodName,paralistEndWhere);
				 cout<<"gotooooo 2  "<<$1->getStart()<<endl;
				  cout<<"asdfghjk "<<paralistEndWhere;
        		methodName = "";
        		//typeParameterList.clear();
        		//symbParameterList.clear();
				     printlog<<"compound_statement : LCURL statements RCURL\n";
                      string str = "{\n"+$3->name+"\n}";	
        			 auto si = new SymbolInfo(str, "");
        			//printlog<<str<<"\n\n";
        			string allTables=table->printAllScopeTableForLogFile();
					printlog<<allTables<<"\n\n";
        			
					
					$$ = new TreeVertex(si, "compound_statement : LCURL statements RCURL",  $1->getStart(), $4->getEnd());
					$$->addChild($1);
					//$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					//cout<<"enter scope er pore "<<table->printAllScopeTableForLogFile()<<endl;
					table->ExitScope();
					
				}
 		    | LCURL enter_scope RCURL
			{
                    
                 //goThroughParametersInFunction(symbParameterList, methodName,paralistEndWhere);
				 cout<<"goto 2  "<<yylineno;
				 cout<<"asdfghjk "<<paralistEndWhere;
        		//methodName = "";
        		//typeParameterList.clear();
        		//symbParameterList.clear();
                printlog<<"compound_statement : LCURL RCURL\n";
                    string str = "{}";	   
        			auto si = new SymbolInfo(str, "");
        			//printlog<<str<<"\n\n";
        			string allTables=table->printAllScopeTableForLogFile();
					printlog<<allTables<<endl;
					
					$$ = new TreeVertex(si, "compound_statement : LCURL RCURL",  $1->getStart(), $3->getEnd());
					$$->addChild($1);
					
					//$$->addChild($2);
					$$->addChild($3);
					table->ExitScope();
					
			}

enter_scope :
			{   //cout<<table->printAllScopeTableForLogFile()<<endl;
			cout<<"hello"<<endl;
				table->EnterScope();
				//cout<<"enter scope er pore "<<table->printAllScopeTableForLogFile()<<endl;
				if(table==NULL)cout<<"f";
				cout<<"ekhaneo ";
				if(typeParameterList.size()>0){
					//cout<<"cmp er vitore "<<endl;
					parameterCount= typeParameterList.size();
					for(int i=0; i<typeParameterList.size(); i++)
					{
						SymbolInfo* tem= new SymbolInfo(symbParameterList[i]->name, typeParameterList[i]);
						//parameter er offset set korar jonno...last parameter ta always 4[BP]te pabe
						tem->setStackOffset((typeParameterList.size()-i-1)*2+4); 
						tem->setGlobal(false);
						table->Insert3(tem->name,tem->type,tem->getStackOffset(),tem->isGlobal());
					}
				}
				//cout<<"enter scope er pore "<<table->printAllScopeTableForLogFile()<<endl;
				typeParameterList.clear();
				symbParameterList.clear();
				// //*****************
                //  string str = "";	   
        		// 	auto si = new SymbolInfo(str, "");
				// $$ = new TreeVertex(si, "compound_statement : LCURL RCURL",  $$->getStart(), $$->getEnd());//********

			}
 		    ;
 		    
		    

var_declaration : type_specifier declaration_list SEMICOLON

            {
			printlog<<"var_declaration : type_specifier declaration_list SEMICOLON\n";
            string symbol = $1->name;                // type_specifier
        	symbol += " " + $2->name + ";";          // declaration_list;
        	auto si = new SymbolInfo(symbol);
        	//check if variable declared as void....Like void a;
             declarationCheck(declarationList, $1 -> name,false);// it will generate corresponding asm code 
             //declarationList.clear();  //*****************************************************sf*********************************

			 $$ = new TreeVertex(si, "var_declaration : type_specifier declaration_list SEMICOLON",  $1->getStart(), $3->getEnd());
			 $$->addChild($1);
			 $$->addChild($2);
			 $$->addChild($3);

			// //  $$->print(cout);
			// parseTree.push_back("var_declaration: type_specifier declaration_list SEMICOLON");
			// for(auto i : parseTree){
			// 	cout << i << endl;
			// }
			}

			 
 		 ;
 		 
type_specifier	: INT
			{
				 printlog<<"type_specifier	: INT\n";
        		auto si = new SymbolInfo("int");
				 $$ = new TreeVertex(si, "type_specifier : INT", $1->getStart(), $1->getEnd());
				 $$->addChild($1);

				//parseTree.push_back("type_specifier: INT");
			}
 		| FLOAT
			{
				 printlog<<"type_specifier	: FLOAT\n";
        		auto si = new SymbolInfo("float");
				 $$ = new TreeVertex(si, "type_specifier : FLOAT", $1->getStart(), $1->getEnd());
				 $$->addChild($1);
        		//parseTree.push_back("type_specifier: FLOAT");
			}
 		| VOID
			{
			printlog<<"type_specifier	: VOID\n";
        		auto si = new SymbolInfo("void");
				 $$ = new TreeVertex(si, "type_specifier : VOID", $1->getStart(), $1->getEnd());
				 $$->addChild($1);
        		//parseTree.push_back("type_specifier: VOID");
			}

 		;
 		
declaration_list : declaration_list COMMA ID
        {
			printlog<<"declaration_list : declaration_list COMMA ID\n";
        	string symbol = $1->name+ "," + $3->name; 		
        	auto si = new SymbolInfo(symbol);
        	$3->getSymbol()->variableType = "variable";
        	declarationList.push_back($3->getSymbol());
           
				 $$ = new TreeVertex(si, "declaration_list : declaration_list COMMA ID",  $1->getStart(), $3->getEnd());
				 $$->addChild($1);
				 $$->addChild($2);
				 $$->addChild($3);
			//parseTree.push_back("declaration_list : declaration_list COMMA ID");
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD

		{
			printlog<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n";
        string symbol = $1->name + ",";                   // declaration_list,
        symbol += $3->name;                               // ID
        symbol += "[" + $5->name + "]";       // [CONST_INT]
        auto si = new SymbolInfo(symbol);
        $3->getSymbol()->variableType = "array";
		 $3->getSymbol()->setArraySize(stoi($5->name));
        declarationList.push_back($3->getSymbol());
      
	  	$$ = new TreeVertex(si, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE",  $1->getStart(), $6->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
		}  
 		  | ID

		{
          
        printlog<<"declaration_list : ID\n";
        string symbol = $1->name;
        auto si = new SymbolInfo(symbol);
        $1->getSymbol()->variableType = "variable";
        declarationList.push_back($1->getSymbol());
        
		$$ = new TreeVertex(si, "declaration_list : ID", $1->getStart(), $1->getEnd());
			$$->addChild($1);

		}
 		  | ID LTHIRD CONST_INT RTHIRD

		{
             printlog<<"declaration_list : ID LSQUARE CONST_INT RSQUARE\n";
        string symbol = $1->name+"[" + $3->name + "]"; 		
        auto si = new SymbolInfo(symbol);
        $1->getSymbol()->variableType = "array";
		 $1->getSymbol()->setArraySize(stoi($3->name)); ////=========================================================================================================
        declarationList.push_back($1->getSymbol());
        
		$$ = new TreeVertex(si, "declaration_list : ID LSQUARE CONST_INT RSQUARE",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
		}
	
 		;
 		  
statements : statement
		{
			 printlog<<"statements : statement\n";
        string symbol = $1->name; 		//statement
        auto si = new SymbolInfo(symbol);
        $$ = new TreeVertex(si, "statements : statement",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
		}
	   | statements statement
	    {

		printlog<<"statements : statements statement\n";
        string symbol = $1->name; 		//statements
        symbol+=" "+$2->name;
		auto si = new SymbolInfo(symbol);
		$$ = new TreeVertex(si, "statements : statements statement",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
		}
		
		
	   ;
	   
statement :  func_declaration 
			{
	printlog<< "Line " << yylineno << ": statement : func_declaration";
	printlog<<endl;
	total_errors++;
	printlog<<"Error at Line " << yylineno << " Invalid scoping found"<<endl;
	
	errorout  << "Line# " << yylineno <<": " << "Invalid scoping found"<<"\n";
	string str = $1->name; 		
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : func_declaration",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
			}
			
			|func_definition 
			{
	printlog<< "Line " << yylineno << ": statement : func_declaration";
	printlog<<endl;
	total_errors++;
	printlog<<"Error at Line " << reserveLineForDefinition << " Invalid scoping found"<<endl;
	errorout  << "Line# " << reserveLineForDefinition <<": " << "Invalid scoping found"<<"\n";
	string str = $1->name; 		
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : func_definition",  $1->getStart(), $1->getEnd());
			$$->addChild($1);

			}
			|
       var_declaration
		{

		printlog<<"statement : var_declaration\n";
        string str = $1->name; 		//var_declaration
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : var_declaration",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
		}
	  | expression_statement
	    {

		printlog<<"statement : expression_statement\n";
        string str = $1->name; 		
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : expression_statement",  $1->getStart(), $1->getEnd());
		$$->addChild($1);
		}
	  | compound_statement
	   {

       cout<<"csssssssss "<<endl;
		printlog<<"statement : compound_statement\n";
        string str = $1->name; 		
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : compound_statement",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
			
	   }
	  | FOR LPAREN expression_statement 
	  {

		forCount++;
		forCountStack.push(forCount);
		fprintf(assemblyfile, "%s: ; for loop starting label\n", ("START_FOR_"+to_string(forCountStack.top())).c_str());

	  }
	  expression_statement
	  {      
		     //ei line ta hocche if er decision label e...just er agei 0 ba 1 push kore aschi
           	fprintf(assemblyfile, "CMP AX, 0\n"); //condition satisfy hoile ax e 1 pabo,,noile 0...0 pele loop break korte hobe
	  	fprintf(assemblyfile, "JE %s ; loop ending condition\n", ("END_FOR_"+to_string(forCountStack.top())).c_str());
		//noile loop er vitorer kaj korte hobe
	  	fprintf(assemblyfile, "JMP %s ; loop code label\n", ("TASK_OF_FORLOOP_"+to_string(forCountStack.top())).c_str());
		//finaly loop increment ba decrement korte hobe...so ekhane label print kore baki kaj ta porer tay korte hobe
	  	fprintf(assemblyfile, "%s: ; loop iterator increase or decrease\n", ("ITER_FOR_L_"+to_string(forCountStack.top())).c_str());
	  }
	   expression RPAREN 
	   {
           fprintf(assemblyfile, "JMP %s ; restart the loop\n", ("START_FOR_"+to_string(forCountStack.top())).c_str());
		fprintf(assemblyfile, "%s: ; loop code\n", ("TASK_OF_FORLOOP_"+to_string(forCountStack.top())).c_str());
	   }
	   statement
	   {
        printlog<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n";
        string str = "for(" + $3->name+ $5->name+ $7->name + ")"+ $10->name;    
		fprintf(assemblyfile, "JMP %s ; update iterator after execution of statement\n", ("ITER_FOR_L_"+to_string(forCountStack.top())).c_str());
	  	fprintf(assemblyfile, "%s: ; end of for loop\n", ("END_FOR_"+to_string(forCountStack.top())).c_str());
	  	forCountStack.pop();
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",  $1->getStart(), $7->getEnd());
			$$->addChild($1); $$->addChild($2); $$->addChild($3); $$->addChild($5);
			$$->addChild($7); $$->addChild($8); $$->addChild($10); 
	   }
	  | if_expression statement %prec LOWER_THAN_ELSE

	   { 
		cout<<"if e aschi "<<endl;
		printlog<<"IF LPAREN expression RPAREN statement \%prec THEN\n";
		string str =$1->name+$2->name;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : IF LPAREN expression RPAREN statement",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			fprintf(assemblyfile, "%s: ; end if label\n", ("label_else_"+to_string(ifCountStack.top())).c_str());
			cout<<"if e aschi "<<endl;
		ifCountStack.pop();
		
		//expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
        

	   }
	  | if_expression statement ELSE
	   {
		fprintf(assemblyfile, "JMP %s\n", ("label_endif_"+to_string(ifCountStack.top())).c_str());
		fprintf(assemblyfile, "%s: ; else label\n", ("label_else_"+to_string(ifCountStack.top())).c_str());
	   }
	   
	    statement

	   {
        printlog<<"statement : IF LPAREN expression RPAREN statement ELSE statement\n";
		string str =  $1->name+$2->name+"\nelse\n"+$5->name;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : IF LPAREN expression RPAREN statement ELSE statement",  $1->getStart(), $5->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			//$$->addChild($3);
			$$->addChild($5);
		//expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
		 //$$->getSymbol()->setAsmCode(asmc);
		fprintf(assemblyfile, "%s: ; end if label\n", ("label_endif_"+to_string(ifCountStack.top())).c_str());
		ifCountStack.pop();
       

	   }
	  | WHILE 
	  {
			whileCount++;
		whileCountStack.push(whileCount);
		fprintf(assemblyfile, "%s: ; while loop begin\n", ("START_WHILE_"+to_string(whileCountStack.top())).c_str());
	  }
	  
	  LPAREN expression RPAREN 
	  {
		fprintf(assemblyfile, "POP CX\nCMP CX, 0\nJE %s\n", ("END_WHILE_"+to_string(whileCountStack.top())).c_str());
	  }
	  
	  statement
	   {

		printlog<<"statement : WHILE LPAREN expression RPAREN statement\n";
		string str = "while(" + $4->name+")\n"+$7->name;;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : WHILE LPAREN expression RPAREN statement",  $1->getStart(), $7->getEnd());
			$$->addChild($1);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($7);	
		 $$->getSymbol()->setReturnType("void");		
		//expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
		fprintf(assemblyfile, "JMP %s ; back to top of loop\n%s:\n", ("START_WHILE_"+to_string(whileCountStack.top())).c_str(), ("END_WHILE_"+to_string(whileCountStack.top())).c_str());
		whileCountStack.pop();
        
	   }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {

		printlog<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n";
        string symbol = "println(" ;                       //println(
        symbol += $3->name +");";                         //ID);
        auto si = new SymbolInfo(symbol);
        $$ = new TreeVertex(si, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON",  $1->getStart(), $5->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->getSymbol()->setReturnType("error");

        SymbolInfo *current = table->Lookup($3->name); //******************************************seg f**********************
		if(!isUndeclared(current,$3->name,"statement"))
            mismatchTypeError(current-> name,current->variableType,"variable");
        	//printlog<<symbol<<"\n\n";
		string vr = $3->name + table->getScopeName($3->name);
		if(current->isGlobal()) fprintf(assemblyfile, "MOV AX, %s\nCALL PRINT_OUTPUT ; argument %s in AX\n", current->getName().c_str(), current->getName().c_str());
		else fprintf(assemblyfile, "MOV AX, %d[BP]\nCALL PRINT_OUTPUT ; argument %s in AX at Line %d\n", current->getStackOffset(), current->getName().c_str(),yylineno);
	  }
	  | RETURN expression SEMICOLON

	  {
         printlog<<"statement : RETURN expression SEMICOLON\n";
        string symbol = "return " +$2->name+";";                       //return
        auto si = new SymbolInfo(symbol);
        $$ = new TreeVertex(si, "statement : RETURN expression SEMICOLON",  $1->getStart(), $3->getEnd());
		 $$->getSymbol()->setReturnType($2->getSymbol()->getReturnType());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			fprintf(assemblyfile, "POP AX\n");
		fprintf(assemblyfile, "\tJMP %s_EXIT\n", currentFunc.c_str());
        if(retType == NULL)
        {   string er="Return statement is not in  the function scope";
            yyerror(er);
        }
		else if(!(retType-> name == "float" &&  $2->getSymbol()->returnType== "int") && retType -> name != $2 ->getSymbol()->returnType)
		{
			 string er="Return type mismatch";
            yyerror(er);
           
        }
       
	  }
	  
	  ;
	  if_expression :	IF LPAREN expression RPAREN 
	{
	
         ifCount++;
		ifCountStack.push(ifCount);
		fprintf(assemblyfile, "POP AX ; expr in AX\nCMP AX, 0 ; checking what we got was true or false\n"); //ekhane dekhbe jinish ta true hoisilo na false...agei 0 ba 1 push kore aschi...0 pawa mane false hoisilo..
		// 1 pawa mane true hoisilo
		fprintf(assemblyfile, "JE %s;we got false in if expression\n", ("label_else_"+to_string(ifCountStack.top())).c_str());
		//in case of only if,the else label is the end_if label...
		string symbol="if("+$3->getName()+")";
		auto si = new SymbolInfo(symbol);
		$$ = new TreeVertex(si, "if_expression :	IF LPAREN expression RPAREN ",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			cout<<"if er oi tay aschi "<<endl;


	} 	
	  
expression_statement 	: SEMICOLON	
             {

				printlog<<"expression_statement : SEMICOLON\n";
				string str = ";" ;   		//;
				auto si = new SymbolInfo(str);
				 $$ = new TreeVertex(si, "expression_statement :  SEMICOLON", $1->getStart(), $1->getEnd());
			$$->addChild($1);
				
				
			 }		
			| expression SEMICOLON 
			{
				printlog<<"expression_statement : expression SEMICOLON\n";
				string str = $1->name+";" ;   		//;
				auto si = new SymbolInfo(str);
				 $$->getSymbol() -> setReturnType($1->getSymbol()->returnType);
			  $$ = new TreeVertex(si, "expression_statement : expression SEMICOLON",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
				fprintf(assemblyfile, "POP AX\n");
			}

			|expression error SEMICOLON {

				yyclearin;
		yyerrok;
		// 	printlog << "Error at line no " << $1->getStart() <<" : syntax error" <<"\n";
		// 	cout<<" error er start "<<$$->getStart();
		// yyerror("Syntax error at expression of expression statement");
         //cout<<" error er start "<<$1->getStart();
		auto si=new SymbolInfo("");
		auto err=new TreeVertex(si,"expression : error",$1->getStart(),$1->getEnd(),true);
		$$ = new TreeVertex(si,"expression_statement : expression SEMICOLON",  $2->getStart(), $2->getEnd());
		
		
			$$->addChild(err);
			$$->addChild($3);
				
			
	
	
	} 

			
			;
	  
variable : ID 
     {
		printlog<<"variable : ID \n";
        SymbolInfo *current = table->Lookup($1->name);	//ID declaration check
        string symbol = $1->name;		//ID
		//errorout<<"here";
		SymbolInfo *si;
        if(isUndeclared(current,$1->name,"variable"))// || (mismatchTypeError(current -> name, current->variableType, "variable")
        {
            si = new SymbolInfo(symbol);
			si->setReturnType("error");
        }
        else
           {
			if(current->isGlobal()) {
				fprintf(assemblyfile, "MOV AX, %s\nPUSH AX ; %s called\n", current->getName().c_str(), current->getName().c_str());
			} else {
				fprintf(assemblyfile, "MOV AX, %d[BP]\nPUSH AX ; %s called\n", current->getStackOffset(), current->getName().c_str());
			}
			
			si = new SymbolInfo(symbol, "", current->returnType, current -> variableType);
        //printlog<<symbol<<"\n\n";
		 si->setArraySize(current->getArraySize());
		 si->setStackOffset(current->getStackOffset());
		 

	      }
		$$ = new TreeVertex(si, "variable : ID", $1->getStart(), $1->getEnd());
		$$->addChild($1);
	 }		
	 | ID LTHIRD expression RTHIRD
	   {
		printlog<<"variable : ID LSQUARE expression RSQUARE \n";
        string symbol = $1->name+"["+$3->name+"]";		//ID
        SymbolInfo *current = table->Lookup($1->name);
         string vr = $1->name + table->getScopeName($1->name);
		SymbolInfo *si;
		if(isUndeclared(current,$1->name,"array")||mismatchTypeError(current -> name, current->variableType, "array"))
            si = new SymbolInfo(symbol, "");
        else
        {
            if($3->getSymbol()->returnType != "int")
                {    string er="Array subscript is not an integer";
					yyerror(er);
				
				}


				if(current->isGlobal()) {
					fprintf(assemblyfile, "POP BX ; popped index expr\nSHL BX, 1; as byte type..need to multiply the index by 2\nMOV SI, %s\nMOV AX, BX[SI]; actually performing BX+SI\n ; %s called\n", current->getName().c_str(), current->getName().c_str()); 
				} else {
					fprintf(assemblyfile, "POP BX ; popped index expr %s\nSHL BX, 1; as byte type..need to multiply the index by 2\nADD BX, %d\n;ADD BX, BP\nPUSH BP\nADD BP, BX\nMOV AX, [BP]\nPOP BP\n;MOV AX, [BX]\nPUSH AX ; value of %s[%s]\nPUSH BX ; index %s\n",
						$3->getName().c_str(), current->getStackOffset(), current->getName().c_str(), $3->getName().c_str(), $3->getName().c_str());
				}
            si = new SymbolInfo(symbol, "array", current->returnType, current->variableType);
			si->setArraySize(current->getArraySize());
			si->setStackOffset(current->getStackOffset());

			
        }

		  $$ = new TreeVertex(si, "variable : ID LSQUARE expression RSQUARE",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
        
	   }
	 ;
	 
 expression : logic_expression
           {
			
        string str = $1->name;		//logic_expression
		printlog<<"expression 	: logic_expression\n";
        auto si = new SymbolInfo(str, "", $1->getSymbol()->returnType);
        //printlog<<str<<"\n\n";
          $$ = new TreeVertex(si, "expression : logic_expression",  $1->getStart(), $1->getEnd());
		
    
			$$->addChild($1);

		   }	
	   | variable ASSIGNOP logic_expression 
	   {
        
		printlog<<"expression 	: variable ASSIGNOP logic_expression\n";
       
        string tempR=$3->getSymbol()->getReturnType();
		cout<<$1 ->getSymbol()-> getReturnType ()<<" s1 er rturn type";
		cout<<tempR<<" tempr"<<endl;
           expressionReturnsVoid(tempR,"expression");
        if( $1 -> getSymbol()->getReturnType() == "int" && tempR == "float")
		       yyerror("Warning: possible loss of data in assignment of FLOAT to INT");
            
        else if($1->getSymbol() -> variableType == "variable" && $1->getSymbol()->returnType != $3->getSymbol()->returnType&& $1->getSymbol()->isDefined)
        {
			string er="Type Mismatch";
            yyerror(er);
        }

		fprintf(assemblyfile, "POP AX ; r-val of assignop %s\n", $3->getName().c_str());
		string varName= $1->getSymbol()->name;
		SymbolInfo* temp = table->Lookup(getArrayName($1->getSymbol()->name));
		cout<<"************"<<temp->name<<"***********"<<endl;
		cout<<"************"<<temp->isGlobal()<<"***********"<<endl;
        if(temp->isGlobal()){
				
				fprintf(assemblyfile, "MOV %s, AX\n", temp->getName().c_str());
			} 
			else {
				
				if (varName.find("[") != string::npos)
				{
					fprintf(assemblyfile, "POP BX\n");
					fprintf(assemblyfile, ";MOV [BX], AX\nPUSH BP\nADD BP, BX\nMOV [BP], AX\nPOP BP ; assigning to %s\n", $1->getName().c_str());
				}
				else
				 {
					
					fprintf(assemblyfile, "MOV %d[BP], AX ; assigning %s to %s\n", $1->getSymbol()->getStackOffset(), $3->getName().c_str(), $1->getName().c_str());
				}
			
			}




        string symbol = $1->name;		//variable
        symbol += " = " + $3 -> name;		//= logic_expression
        auto si = new SymbolInfo(symbol, "", $1->getSymbol()->returnType);
		  $$ = new TreeVertex(si, "expression : variable ASSIGNOP logic_expression",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
		
       
	   }
	   |
	   error
	   {
         	printlog << "Error at line no " << $1->getStart() <<" : syntax error" <<"\n";
			cout<<" error er start "<<$$->getStart();
		yyerror("Syntax error at expression of expression statement");
	   }
	

	   
	   
	   ;
			
logic_expression : rel_expression 
              {
				printlog<<"logic_expression : rel_expression \n";
        string symbol = $1->name;		//rel_expression
        auto si = new SymbolInfo($1->name, "", $1->getSymbol()->returnType);
        //printlog<<symbol<<"\n\n";
		  $$ = new TreeVertex(si, "logic_expression : rel_expression",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
			  }	
		 | rel_expression LOGICOP rel_expression 
		 {
			printlog<<"logic_expression : rel_expression LOGICOP rel_expression \n"; 
         string symbol = $1->name+" "+$2->name+ " "+$3->name;		
		 string rt1=$1->getSymbol()->returnType;
		 string rt3=$3->getSymbol()->returnType;
		 bool f1,f2;
           //string t1 = cg.newTemp();
		 SymbolInfo * si;
		 f1=expressionReturnsVoid(rt1,"expression");
		 if(!f1) f2=expressionReturnsVoid(rt3,"expression");
		 if(f1==true || f2==true)si=new SymbolInfo(symbol,"");
		 else
		 	si=new SymbolInfo(symbol,"","int"); 
		    $$ = new TreeVertex(si, "logic_expression : rel_expression LOGICOP rel_expression",  $1->getStart(), $3->getEnd());

        fprintf(assemblyfile, "POP BX ;the right one \nPOP AX ; the left one\n");
			string IF_TRUE_LABEL=newLabel();
			string IF_FALSE_LABEL=newLabel();





        if($2->getSymbol()->name == "&&") 
                {   
					//jekono ekta 1 hoilei false label e jump korbe...ekta 1 hoile onno ta check korbe
					fprintf(assemblyfile, "CMP AX, 0\nJE %s\nCMP BX, 0\nJE %s\nPUSH 1\nJMP %s\n", IF_FALSE_LABEL.c_str(), IF_FALSE_LABEL.c_str(), IF_TRUE_LABEL.c_str());
				fprintf(assemblyfile, "%s:\nPUSH 0 ; total false\n%s:\n", IF_FALSE_LABEL.c_str(), IF_TRUE_LABEL.c_str());
				}
		 if($2->getSymbol()->name == "||") 
                {
					fprintf(assemblyfile, "CMP AX, 0\nJNE %s\nCMP BX, 0\nJNE %s\nPUSH 0\nJMP %s\n", IF_FALSE_LABEL.c_str(), IF_FALSE_LABEL.c_str(), IF_TRUE_LABEL.c_str());
				fprintf(assemblyfile, "%s:\nPUSH 1 ; total false\n%s:\n", IF_FALSE_LABEL.c_str(), IF_TRUE_LABEL.c_str());
				}

			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
		 }	
		 ;
			
rel_expression	: simple_expression 
            {
        printlog<<"rel_expression	: simple_expression  \n";
        string symbol = $1->name;		//simple_expression
		string rt1=$1->getSymbol()->returnType;
        auto si = new SymbolInfo(symbol, "", rt1);
		$$ = new TreeVertex(si, "rel_expression : simple_expression",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
        //printlog<<symbol<<"\n\n";

			}
		| simple_expression RELOP simple_expression	
		{
			printlog<<"rel_expression	: simple_expression RELOP simple_expression\n"; 
         string symbol = $1->name;		
         symbol += " "+$2->name; 		
         symbol += " "+$3->name;
		 string st1="";
		 string rel=$2->name;
        if(rel== "<") st1 = "JL";
        else if(rel== "<=")     st1 = "JLE";
        else if(rel== ">")      st1 = "JG";
        else if(rel == ">=")      st1 = "JGE";
        else if(rel == "==")      st1 = "JE";
        else if(rel== "!=")     st1= "JNE";			
		 string rt1=$1->getSymbol()->returnType;
		 string rt3=$3->getSymbol()->returnType;
		 bool f1,f2;
		 f1=expressionReturnsVoid(rt1,"expression");
		 SymbolInfo * si;
		 if(!f1) f2=expressionReturnsVoid(rt3,"expression");
		 if(f1==true || f2==true)si=new SymbolInfo(symbol);
		 else
		 	si=new SymbolInfo(symbol,"","int"); 

        $$ = new TreeVertex(si, "rel_expression : simple_expression RELOP simple_expression",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			fprintf(assemblyfile, "POP AX\nPOP BX ; left side value\nCMP BX, AX ; evaluating  %s at Line %d \n", $$->getName().c_str(),yylineno);
			string IF_TRUE_LABEL=newLabel(); //the checking label where decision is made...not actually true label...if true goes direct here for checking..also comes from false label
			cout<<"abcd new "<<IF_TRUE_LABEL<<endl;
			string IF_FALSE_LABEL=newLabel();
			cout<<"abcd new "<<IF_FALSE_LABEL<<endl;
			cout<<st1<<endl;

			if(rel=="<")

			{   cout<<"came 1";
					fprintf(assemblyfile, "JNL %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
			
			}
			 else if(rel=="<=")
			 {     cout<<"came 2";
					
					fprintf(assemblyfile, "JNLE %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
			
			} 
			else if(rel==">")
			{      cout<<"came 3";
					fprintf(assemblyfile, "JNG %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
		
			} else if(rel==">=")
			
			{     cout<<"came 4";
					
					fprintf(assemblyfile, "JNGE %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
			
			} else if(rel=="==")
			
			{      cout<<"came 5";
					fprintf(assemblyfile, "JNE %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
			
			} else if(rel=="!=")
			
			{    
				 cout<<"came 6";
					fprintf(assemblyfile, "JE %s;if false jump to false label\nPUSH 1 ; if %s is true\nJMP %s;		the checking label where decision is made\n", IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
				
				fprintf(assemblyfile, "%s:\nPUSH 0 ; if %s is false\n%s:\n",IF_FALSE_LABEL.c_str(), $$->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str());
							
			}

		}
		;
				
simple_expression : term
         {
			printlog <<"simple_expression : term";
	        printlog<<endl;
			string str=$1->name;
			string rt=$1->getSymbol()->returnType;
			auto si=new SymbolInfo(str,"",rt);
			$$ = new TreeVertex(si, "simple_expression : term",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
			// //$$->addChild($2);
			// //$$->addChild($3);
			
	
		 } 
		  | simple_expression ADDOP term 

		  {

			printlog<<"simple_expression : simple_expression ADDOP term \n";
			 string symbol = $1->name;		
			 //string temp = cg.newTemp();
         symbol += " "+$2->name; 		
         symbol += " "+$3->name;			
		 string rt1=$1->getSymbol()->returnType;
		 string rt3=$3->getSymbol()->returnType;
		 bool f1,f2;
		 f1=expressionReturnsVoid(rt1,"expression");

		 SymbolInfo * si;
		 if(!f1) {
			f2=expressionReturnsVoid(rt3,"expression");
		 }
		 if(f1==true || f2==true) si=new SymbolInfo(symbol,"","void");
		 else if(rt1=="float"||rt3=="float") si=new SymbolInfo(symbol,"","float"); 
		 else
		 	si=new SymbolInfo(symbol,"","int"); 
            if($2->getName()=="+")
			    //BX e bam er ta ache...karon pore pop korsi...ar bam er ta age push hoisilo
				fprintf(assemblyfile, "POP AX\nPOP BX\nADD AX, BX\nPUSH AX ; %s+%s at Line %d  pushed\n", $1->getSymbol()->getName().c_str(), $3->getSymbol()->getName().c_str(),yylineno);
			else 
				fprintf(assemblyfile, "POP AX\nPOP BX\nSUB BX, AX\nPUSH BX ; %s-%s  of Line %d  pushed\n", $1->getSymbol()->getName().c_str(), $3->getSymbol()->getName().c_str(),yylineno);  
		$$ = new TreeVertex(si, "simple_expression : simple_expression ADDOP term", $1->getStart(), $3->getEnd());
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		
		  }

		  ;
					
term :	unary_expression
    {
         printlog << "term :	unary_expression";
	        printlog<<endl;
			string str=$1->getSymbol()->name;
			string rt=$1->getSymbol()->returnType;
			auto si=new SymbolInfo(str,"",rt);
			$$ = new TreeVertex(si, "term : unary_expression",  $1->getStart(), $1->getEnd());
			
			$$->addChild($1);
		
	}
     |  term MULOP unary_expression
	 {
        printlog<<"term :	term MULOP unary_expression \n";

		string symbol = $1->name+" "+$2->name+" "+$3->name;		
		auto si = new SymbolInfo(symbol,"", "int");
		//printlog<<symbol<<"\n\n";
		string opsymbol=$2->name;
		bool zero = true;
		bool fff = true;
		string s3 = $3->name;
		//string temp = cg.newTemp();
        string op1 = $1->getSymbol()->getValueRep();
        string op2 = $3->getSymbol()->getValueRep();

        
        for(char c: $3->getSymbol()->getValueRep()) 
            if(!('0' <= c and c <= '9')) 
                fff = false;

		for(int i=0;i<s3.size();i++)
		{
			if(s3[i]!='0')
				zero = false;
		}
        string rt1=$1->getSymbol()->returnType;
		string rt3=$3->getSymbol()->returnType;
		

        
		if(expressionReturnsVoid(rt1,"expression") || expressionReturnsVoid(rt3,"expression"))
			;
		else{

            if(rt1=="float" || rt3=="float")
                $$->getSymbol()->setReturnType("float");

            if(opsymbol=="/"&&zero)
			{
				  string er="Warning: division by Zero";
					yyerror(er);
				
			}
            if(opsymbol=="%")
			{
				if(zero)
				{
					string er="Warning: division by zero i=0f=1Const=0";
					yyerror(er);
				}

				if($$->getSymbol()->getReturnType()=="float")
				{
					 string er="Operands of modulus must be integers";
					yyerror(er);
					$$->getSymbol()->setReturnType("int");
				}
				
				
			}
		}
		$$ = new TreeVertex(si, "term : term MULOP unary_expression",  $1->getStart(), $3->getEnd());
		
		if(opsymbol=="%")fprintf(assemblyfile, "MOV DX, 0 ; DX:AX = 0000:AX\nPOP BX\nPOP AX\nIDIV BX\nPUSH DX ; remainder of %s is in DX\n", $$->getSymbol()->getName().c_str());
		else if(opsymbol=="*")fprintf(assemblyfile, "POP BX\nPOP AX\nIMUL BX\nPUSH AX ; result of %s is in AX, pushed\n", $$->getSymbol()->getName().c_str());
		else fprintf(assemblyfile, "POP BX\nPOP AX\nIDIV BX\nPUSH AX ; result of %s is in AX, pushed\n", $$->getSymbol()->getName().c_str());

			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

	 }
	
     ;

unary_expression : ADDOP unary_expression 
       {
		printlog<<"unary_expression : ADDOP unary_expression\n";
		string tp=$2->getSymbol()->type;
		string rt=$2->getSymbol()->returnType;
	
        if($1->getSymbol()->name == "-") 
                fprintf(assemblyfile, "POP AX\nNEG AX ; -%s\nPUSH AX\n", $2->getSymbol()->getName().c_str());
        expressionReturnsVoid(tp,"expression");
        string symbol = $1->name+" "+$2->name;		
        auto si = new SymbolInfo(symbol, tp, rt);
		$$ = new TreeVertex(si, "unary_expression : ADDOP unary_expression",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
        

	   } 
		 | NOT unary_expression 
		 {

			printlog<<"unary_expression : NOT unary_expression\n";
		string tp=$2->getSymbol()->type;
		string rt=$2->getSymbol()->returnType;
		//string l1 = cg.newLabel();
        //string l2 = cg.newLabel();
        expressionReturnsVoid(tp,"expression");
        string symbol ="!"+$2->name;		
        auto si = new SymbolInfo(symbol, tp, rt);
		
    

		$$ = new TreeVertex(si, "unary_expression : NOT unary_expression",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			string IF_TRUE_LABEL=newLabel();
			string IF_FALSE_LABEL=newLabel();
			//AX er moddhe already ja compare korte hobe ta ache...The LHS ta ache Ax e..(if er khettre)
			//0 thakle 1 push korbo;
			fprintf(assemblyfile, "POP AX\nCMP AX, 0 ; !%s\nJNE %s\nMOV AX, 1\nJMP %s\n\
				\n%s:\nXOR AX, AX\n%s:\nPUSH AX\n"
				, $2->getSymbol()->getName().c_str(), IF_TRUE_LABEL.c_str(), IF_FALSE_LABEL.c_str(), IF_TRUE_LABEL.c_str(), IF_FALSE_LABEL.c_str());
       
		 }
		 | factor 
		 {
			printlog<<"unary_expression : factor\n";
        //expressionReturnsVoid(tp,"expression");
        string symbol =$1->name;	
		string tp=$1->getSymbol()->type;
		string rt=$1->getSymbol()->returnType;	
		auto si = new SymbolInfo(symbol, tp, rt);
			$$ = new TreeVertex(si, "unary_expression : factor",  $1->getStart(), $1->getEnd());
			$$->addChild($1);

       
		 }
	
     
		   
		 ;
	
factor	: variable 
      {
		printlog<<"factor	: variable \n";
		string tp=$1->getSymbol()->type;
		string rt=$1->getSymbol()->returnType;
        //expressionReturnsVoid(tp,"expression");
        string symbol =$1->name;	
		string vtype=$1->type;	
        auto si = new SymbolInfo(symbol, tp, rt);
			$$ = new TreeVertex(si, "factor : variable",  $1->getStart(), $1->getEnd());
			if(tp=="array")
		{
			fprintf(assemblyfile, "POP BX ; r-value, no need for index\n");
		}

		
			$$->addChild($1);

        
	  }
	| ID LPAREN argument_list RPAREN
	{
		printlog<<"factor	: ID LPAREN argument_list RPAREN\n";
		
        string symbol = $1->name+"("+$3->name+")";
       
        SymbolInfo *current = table->Lookup($1->getSymbol()->name);

		SymbolInfo *si;
        if(isUndeclared(current,$1->getSymbol()->name,"factor") || mismatchTypeError(current -> name, current -> getVariableType(), "function"))//|
		{
            si = new SymbolInfo(symbol, "");
        }

        else
		{
            errorArgParameter(current->parameterList, $3->getSymbol()->argumentList,$1->getSymbol()->name);
			for (auto i: current->parameterList)
                cout << i << ' '; 
				cout<<endl;

				for (auto i: $3->getSymbol()->argumentList)
                cout << i << " a "; 
				cout<<endl;
			
            si = new SymbolInfo(symbol, "", current->returnType);
			typeParameterList.clear();
        }

		//si = new SymbolInfo(symbol, $2->getType(), $2->returnType);
			$$ = new TreeVertex(si, "factor : ID LPAREN argument_list RPAREN",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
            fprintf(assemblyfile, "CALL %s\n", $1->getSymbol()->getName().c_str());
			if(current->returnType!="void")
			fprintf(assemblyfile, "PUSH AX ; return value of %s\n", $1->getSymbol()->getName().c_str());
        
	}
	| LPAREN expression RPAREN
	{
           string symbol = "("+$2->name+")";
		printlog<<"factor	: LPAREN expression RPAREN\n";
        auto si = new SymbolInfo(symbol, $2->getType(), $2->getSymbol()->returnType);
			$$ = new TreeVertex(si, "factor : LPAREN expression RPAREN",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
      
	}
	| CONST_INT 
	{      string symbol = $1->name;		//CONST_INT
		printlog<<"factor	: CONST_INT\n";
        auto si = new SymbolInfo(symbol, "", "int");
			$$ = new TreeVertex(si, "factor : CONST_INT",  $1->getStart(), $1->getEnd());
			fprintf(assemblyfile, "PUSH %s\n", $$->getSymbol()->getName().c_str());
			$$->addChild($1);
        
	}
	| CONST_FLOAT
	{
              string symbol = $1->name;		//CONST_INT
		printlog<<"factor	: CONST_FLOAT\n";
        auto si = new SymbolInfo(symbol, "", "float");
				 $$ = new TreeVertex(si, "factor : CONST_FLOAT", $1->getStart(), $1->getEnd());
				 $$->addChild($1);
        
	}
	| variable INCOP
	{
		 string symbol = $1->name;		//CONST_INT
		 symbol+="++";
		 string asmc;
		string temp;
		printlog<<"factor	: variable INCOP\n";
		string rt=$1->getSymbol()->returnType;
        auto si = new SymbolInfo(symbol, "", rt);
				 $$ = new TreeVertex(si, "factor	: variable INCOP", $1->getStart(), $2->getEnd());
		if($1->name == "array") 
		{
           fprintf(assemblyfile, "POP BX\nPOP AX\nINC AX ; %s++\n", $1->getSymbol()->getName().c_str());
			fprintf(assemblyfile, "PUSH BP\nADD BP, BX\nMOV [BP], AX\nPOP BP\n");
        }       
        else if($1->name!="array")
		 {
           fprintf(assemblyfile, "INC AX\nMOV %d[BP], AX\n", $1->getSymbol()->getStackOffset());
        }
				 $$->addChild($1);
				 $$->addChild($2);
       
	} 
	| variable DECOP
	{
		string symbol = $1->name;		//CONST_INT
		 symbol+="--";
		 string asmc;
		string temp;
		printlog<<"factor	: variable DECOP\n";
		string rt=$1->getSymbol()->returnType;
        auto si = new SymbolInfo(symbol, "", rt);
		 $$ = new TreeVertex(si, "factor	: variable DECOP", $1->getStart(), $2->getEnd());
		 if($1->name == "array") 
		{ fprintf(assemblyfile, "POP BX\nPOP AX\nINC AX ; %s++\n", $1->getSymbol()->getName().c_str());
			fprintf(assemblyfile, "PUSH BP\nADD BP, BX\nMOV [BP], AX\nPOP BP\n");
        }       
        else if($1->name!="array")
		 {
          fprintf(assemblyfile, "DEC AX\nMOV %d[BP], AX\n", $1->getSymbol()->getStackOffset());
        }
				 $$->addChild($1);
				 $$->addChild($2);
       
        
	}
	;
	
argument_list : arguments
          {
			string symbol = $1->name;	
			printlog<<"argument_list : arguments\n";	
        auto si = new SymbolInfo(symbol);
        si->argumentList = $1->getSymbol()->argumentList;
		$$ = new TreeVertex(si, "argument_list : arguments",  $1->getStart(), $1->getEnd());
		
		$$->addChild($1);
        
		  }


			  |

		{
			string symbol = "";	
			printlog<<"argument_list : \n";	
        auto si = new SymbolInfo(symbol);
		$$ = new TreeVertex(si, "argument_list : ", yylineno, yylineno);
				
        

		}
			  ;
	
arguments : arguments COMMA logic_expression
       {
		 printlog<<"arguments : arguments COMMA logic_expression\n";
		 string tp=$3->getSymbol()->type;
		 string rt=$3->getSymbol()->returnType;
        expressionReturnsVoid(tp,"expression");
        string symbol = $1->name+", "+$3->name	;
        auto si = new SymbolInfo(symbol, "");
        si->argumentList = $1->getSymbol()->argumentList;
        si->argumentList.push_back(rt);
		for (auto i: si->argumentList)
                cout << i << " c "; 
				cout<<endl;
			 $$ = new TreeVertex(si, "arguments : arguments COMMA logic_expression",  $1->getStart(), $3->getEnd());
			 
				 $$->addChild($1);
				 $$->addChild($2);
				 $$->addChild($3);

				 	for (auto i: $1->getSymbol()->argumentList)
                cout << i << " b "; 
				cout<<endl;
       
	   }
	      | logic_expression

		{
             printlog<<"arguments : logic_expression\n";
		 string tp=$1->getSymbol()->type;
		 string rt=$1->getSymbol()->returnType;
        expressionReturnsVoid(tp,"expression");
        string symbol = $1->name;
        auto si = new SymbolInfo(symbol);
        si->argumentList.push_back(rt);
           for (auto i: si->argumentList)
                cout << i << " larg1"; 
				cout<<endl;
		$$ = new TreeVertex(si, "arguments : logic_expression",  $1->getStart(), $1->getEnd());
		
				 $$->addChild($1);
				for (auto i: si->argumentList)
                cout << i << " larg"; 
				cout<<endl;
     

		}
	
	      ;
 

%%
int main(int argc,char *argv[])
{


	FILE* input;
	string line;
	string nextLine;
	vector<string> fragment;
	vector<string> nextFragment;
	vector<string> allLines(1500);
    if((input = fopen(argv[1], "r")) == NULL) {
        printf("Cannot Open Input File.\n");
        exit(1);
    }
	if(argc < 3){
        printlog.open("log.txt", ios::out);
        printlog.close();
        printlog.open("log.txt", ios::app);
    }
    else {
        printlog.open(argv[2], ios::out);
        printlog.close();
        printlog.open(argv[2], ios::app);
    }
    // if(argc < 4){
    //     errorout.open("error.txt", ios::out);
    //     errorout.close();
    //     errorout.open("error.txt", ios::app);
    // }
    // else {
    //     errorout.open(argv[3], ios::out);
    //     errorout.close();
    //     errorout.open(argv[3], ios::app);
    // }
   
    if(argc < 4){
        treeout.open("parsetree.txt", ios::out);
        treeout.close();
        treeout.open("parsetree.txt", ios::app);
    }
    else {
        treeout.open(argv[3], ios::out);
        treeout.close();
        treeout.open(argv[3], ios::app);
    }

	assemblyfile= fopen("asmcode.asm","w");
	fclose(assemblyfile);

	assemblyfile= fopen("asmcode.asm","a");

    yyin = input;
    table = new SymbolTable(11,0);

    yyparse(); 
    

    fclose(yyin);
  
	 fclose(assemblyfile);


	 allLines.clear();
	asmly.open("asmcode.asm");
	opt.open("optimizedCode.asm");

	while (getline (asmly,line)) 
		allLines.push_back(line);

	if(allLines.size()==0)
	 {
		asmly.close();
		opt.close();	
		return 0;
	}


///OPTIMIZATION PART HERE
	for (int i = 0; i < allLines.size()-1; i++)
    {
        if((stringSplitter(allLines[i]).size()==0))
            continue;
        if((stringSplitter(allLines[i])[0].find(";") != string::npos))
            continue;
		line=allLines[i];
        nextLine=allLines[i+1];
		fragment=stringSplitter(line);
        nextFragment=stringSplitter(nextLine);
		if(fragment[0]=="PUSH")
		{
            if(nextFragment[0]=="POP")
			{ 
                if(fragment[1]==nextFragment[1])
				{ // PUSH AX ; POP AX
				      //just make them as comment
                    allLines[i]=";"+allLines[i];
                    allLines[i+1]=";"+allLines[i+1];
                }
                else
			 { // PUSH 12 ; POP AX ;;;assign 12 to AX and pop it
                    allLines[i]=";"+allLines[i];
                    allLines[i+1]="MOV "+nextFragment[1]+", "+fragment[1];
                }
            }
        }

		if(fragment[0]=="MOV")
		{
            if(fragment[1]==fragment[2])
			{ // MOV AX, AX
                allLines[i]=";"+allLines[i];
            }
            if(nextFragment[0]=="MOV")
			{ 

                if((fragment[1]==nextFragment[2]) && (fragment[2]==nextFragment[1]))
				{ // MOV AX, BX ; MOV BX, AX
				  //so next line becomes redundant...comment it out
                    allLines[i+1]=";"+allLines[i+1];
                }
                if(fragment[1]==nextFragment[1])
				//next line ei value change hoye jacche...so 1st line ta comment kore dewa jay
				{ // MOV AX, BX ; MOV AX, CX
                    allLines[i]=";"+allLines[i];
                }
            }
        }


		if(fragment[0]=="ADD"||fragment[0]=="SUB")

		{
              if(fragment[2]=="0")
			{ // ADD AX, 0
			 //SUB AX,0
                allLines[i]=";"+allLines[i];
            }
		}

		if(fragment[0]=="MUL")

		{
              if(fragment[2]=="1")
			{ // MUL AX, 1
			 
                allLines[i]=";"+allLines[i];
            }
		}
       

	}

	for (int i = 0; i < allLines.size(); i++)
    	opt<<allLines[i]<<endl;
	asmly.close();
	opt.close();

    return 0;
}

/*
bison -d 1905053.y
flex 1905053.l
g++ lex.yy.c 1905053.tab.c -o output.out
./output.out ./input.c
*/

