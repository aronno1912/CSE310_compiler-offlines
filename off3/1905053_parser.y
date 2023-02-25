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
vector<SymbolInfo*> declarationList;
SymbolInfo *retType;
ofstream printlog;
ofstream errorout;
ofstream treeout;
extern int line_count;
extern int total_errors;
extern int reserveLC;
extern int start_line;
vector<SymbolInfo*> symbParameterList;
string methodName;
int paralistEndWhere=0;
int errorIdExtra=0;
int checkSe=-1;
int reserveLineForDefinition;
vector<string> parseTree;
 


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
void declarationCheck(vector<SymbolInfo*> declist, string returnT)
{
	  int i =0;
    if(returnT == "void"){
		string er="Variable or field \'"+declist[i] -> name+"\' declared void";
        yyerror(er);
        return;
    }
	
	while(i<declist.size())
	{
        SymbolInfo *current = table->LookupInScope(declist[i] -> name);
        declist[i]->returnType = returnT;
        if(current)
        {
            string s = "Conflicting types for\'"+declist[i]->name+"\'";
            yyerror(s);
        }
        else{
            table->Insert2(declist[i]->name, declist[i]->type,declist[i]->returnType, declist[i]->variableType);
        }
		i++;
	}
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

start : program
	{
		//write your code in this block in all the similar blocks below
        printlog<<"start : program\n";
		$$ =  new TreeVertex("start : program", $1->getStart(), $1->getEnd());
		$$->addChild($1);

		$$->print(treeout, 0); //parseTree print,initial spacing is 0
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
		}
         
		| type_specifier ID LPAREN RPAREN 
		{    
			reserveLineForDefinition=$1->getStart();
				retType=$1->getSymbol();
             methodName=$2->name;
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
       
        retType = NULL;
		}

			| type_specifier ID LPAREN parameter_list error RPAREN compound_statement {
				
		yyclearin;
		//yyerrok;
			printlog << "Error at line no " << $6->getEnd() <<" : syntax error" <<"\n";
			int extra=yylineno-$6->getEnd();
		yyerror("Syntax error at parameter list of function definition",0,extra);
		cout<<endl<<"para er error "<<$1->getStart()<<" "<< $6->getEnd()<<endl;
		auto si=new SymbolInfo("");
		auto err=new TreeVertex(si,"parameter_list : error",$6->getEnd(),$6->getEnd(),true);
		$$ = new TreeVertex(si,"func_definition : type_specifier ID LPAREN parameter_list RPAREN",  $1->getStart(), $6->getEnd());
		
		$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild(err);
			
			$$->addChild($6);
	
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

 		
compound_statement : LCURL 
				{    
                	table->EnterScope();
                 goThroughParametersInFunction(symbParameterList, methodName,paralistEndWhere);
				 cout<<"gotooooo 2  "<<$1->getStart()<<endl;
				  cout<<"asdfghjk "<<paralistEndWhere;
        		methodName = "";
        		typeParameterList.clear();
        		symbParameterList.clear();


				}statements RCURL
				{      printlog<<"compound_statement : LCURL statements RCURL\n";
                      string str = "{\n"+$3->name+"\n}";	
        			 auto si = new SymbolInfo(str, "");
        			//printlog<<str<<"\n\n";
        			string allTables=table->printAllScopeTableForLogFile();
					printlog<<allTables<<"\n\n";
        			table->ExitScope();
					
					$$ = new TreeVertex(si, "compound_statement : LCURL statements RCURL",  $1->getStart(), $4->getEnd());
					$$->addChild($1);
					$$->addChild($3);
					$$->addChild($4);
				}
 		    | LCURL 
			{
                    
                table->EnterScope();
                 goThroughParametersInFunction(symbParameterList, methodName,paralistEndWhere);
				 cout<<"goto 2  "<<yylineno;
				 cout<<"asdfghjk "<<paralistEndWhere;
        		methodName = "";
        		typeParameterList.clear();
        		symbParameterList.clear();
               

			}RCURL
            {       printlog<<"compound_statement : LCURL RCURL\n";
                    string str = "{}";	   
        			auto si = new SymbolInfo(str, "");
        			//printlog<<str<<"\n\n";
        			string allTables=table->printAllScopeTableForLogFile();
					printlog<<allTables<<endl;
        			table->ExitScope();
					
					$$ = new TreeVertex(si, "compound_statement : LCURL RCURL",  $1->getStart(), $3->getEnd());
					$$->addChild($1);
					$$->addChild($3);
			}
		    

var_declaration : type_specifier declaration_list SEMICOLON

            {
			printlog<<"var_declaration : type_specifier declaration_list SEMICOLON\n";
            string symbol = $1->name;                // type_specifier
        	symbol += " " + $2->name + ";";          // declaration_list;
        	auto si = new SymbolInfo(symbol);
        	//check if variable declared as void....Like void a;
             declarationCheck(declarationList, $1 -> name);
             declarationList.clear();

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

			 |type_specifier declaration_list error SEMICOLON
    	{
        //$$ = $1;
		cout<<"here";
        //errorout<<$$ -> name<<"\n\n";
		printlog << "Error at line no " << line_count <<" : syntax error" <<"\n";
		yyerror("Syntax error at declaration list of variable declaration",1);
		yyclearin;
		auto si=new SymbolInfo("");
		cout<<endl<<"decla er error "<<$1->getStart()<<" "<< $4->getEnd()<<endl;
		auto err=new TreeVertex(si,"declaration_list : error",yylineno,yylineno,true);
		$$ = new TreeVertex(si,"var_declaration : type_specifier declaration_list SEMICOLON",  $1->getStart(), $4->getEnd());
		
		$$->addChild($1);
			$$->addChild(err);
			
			$$->addChild($4);
		//yyerrok;
        
		
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
	   
statement : 

         func_declaration 
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
|
func_definition 
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

       
		printlog<<"statement : compound_statement\n";
        string str = $1->name; 		
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : compound_statement",  $1->getStart(), $1->getEnd());
			$$->addChild($1);
	   }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	   {

        printlog<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n";
        string str = "for(" + $3->name+ $4->name+ $5->name + ")"+ $7->name;                         
                                  
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",  $1->getStart(), $7->getEnd());
			$$->addChild($1); $$->addChild($2); $$->addChild($3); $$->addChild($4);
			$$->addChild($5); $$->addChild($6); $$->addChild($7); 
	   }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE

	   {
		printlog<<"IF LPAREN expression RPAREN statement \%prec THEN\n";
		string str = "if(" + $3->name+")"+$5->name;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : IF LPAREN expression RPAREN statement",  $1->getStart(), $5->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
		expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
        

	   }
	  | IF LPAREN expression RPAREN statement ELSE statement

	   {
        printlog<<"statement : IF LPAREN expression RPAREN statement ELSE statement\n";
		string str = "if(" + $3->name+")"+$5->name+"\nelse\n"+$7->name;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : IF LPAREN expression RPAREN statement ELSE statement",  $1->getStart(), $7->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);
		expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
       

	   }
	  | WHILE LPAREN expression RPAREN statement
	   {

		printlog<<"statement : WHILE LPAREN expression RPAREN statement\n";
		string str = "while(" + $3->name+")\n"+$5->name;;                         
        auto si = new SymbolInfo(str);
        $$ = new TreeVertex(si, "statement : WHILE LPAREN expression RPAREN statement",  $1->getStart(), $5->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);			
		expressionReturnsVoid($3->getSymbol()->getReturnType(),"if");
        
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

        SymbolInfo *current = table->LookupInScope($3->name);
		if(!isUndeclared(current,$3->name,"statement"))
            mismatchTypeError(current-> name,current->variableType,"variable");
        	//printlog<<symbol<<"\n\n";
	  }
	  | RETURN expression SEMICOLON

	  {
         printlog<<"statement : RETURN expression SEMICOLON\n";
        string symbol = "return " +$2->name+";";                       //return
        auto si = new SymbolInfo(symbol);
        $$ = new TreeVertex(si, "statement : RETURN expression SEMICOLON",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
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
        }
        else
            si = new SymbolInfo(symbol, "", current->returnType, current -> variableType);
        //printlog<<symbol<<"\n\n";

		$$ = new TreeVertex(si, "variable : ID", $1->getStart(), $1->getEnd());
		$$->addChild($1);
	 }		
	 | ID LTHIRD expression RTHIRD
	   {
		printlog<<"variable : ID LSQUARE expression RSQUARE \n";
        string symbol = $1->name+"["+$3->name+"]";		//ID
        SymbolInfo *current = table->Lookup($1->name);
        
		SymbolInfo *si;
		if(isUndeclared(current,$1->name,"array")||mismatchTypeError(current -> name, current->variableType, "array"))
            si = new SymbolInfo(symbol, "");
        else
        {
            if($3->getSymbol()->returnType != "int")
                {    string er="Array subscript is not an integer";
					yyerror(er);
				
				}
            si = new SymbolInfo(symbol, "", current->returnType, current->variableType);
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

		 SymbolInfo * si;
		 f1=expressionReturnsVoid(rt1,"expression");
		 if(!f1) f2=expressionReturnsVoid(rt3,"expression");
		 if(f1==true || f2==true)si=new SymbolInfo(symbol,"");
		 else
		 	si=new SymbolInfo(symbol,"","int"); 
		    $$ = new TreeVertex(si, "logic_expression : rel_expression LOGICOP rel_expression",  $1->getStart(), $3->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

           //printlog<<symbol<<"\n\n";
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
		string s3 = $3->name;
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
        expressionReturnsVoid(tp,"expression");
        string symbol ="!"+$2->name;		
        auto si = new SymbolInfo(symbol, tp, rt);
		$$ = new TreeVertex(si, "unary_expression : NOT unary_expression",  $1->getStart(), $2->getEnd());
			$$->addChild($1);
			$$->addChild($2);
       
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
        auto si = new SymbolInfo(symbol, tp, rt);
			$$ = new TreeVertex(si, "factor : variable",  $1->getStart(), $1->getEnd());
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
        }

		//si = new SymbolInfo(symbol, $2->getType(), $2->returnType);
			$$ = new TreeVertex(si, "factor : ID LPAREN argument_list RPAREN",  $1->getStart(), $4->getEnd());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
        
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
		printlog<<"factor	: variable INCOP\n";
		string rt=$1->getSymbol()->returnType;
        auto si = new SymbolInfo(symbol, "", rt);
				 $$ = new TreeVertex(si, "factor	: variable INCOP", $1->getStart(), $2->getEnd());
				 $$->addChild($1);
				 $$->addChild($2);
       
	} 
	| variable DECOP
	{
		string symbol = $1->name;		//CONST_INT
		 symbol+="--";
		printlog<<"factor	: variable DECOP\n";
		string rt=$1->getSymbol()->returnType;
        auto si = new SymbolInfo(symbol, "", rt);
		 $$ = new TreeVertex(si, "factor	: variable DECOP", $1->getStart(), $2->getEnd());
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
    if(argc < 4){
        errorout.open("error.txt", ios::out);
        errorout.close();
        errorout.open("error.txt", ios::app);
    }
    else {
        errorout.open(argv[3], ios::out);
        errorout.close();
        errorout.open(argv[3], ios::app);
    }

	 if(argc < 5){
        treeout.open("parsetree.txt", ios::out);
        treeout.close();
        treeout.open("parsetree.txt", ios::app);
    }
    else {
        treeout.open(argv[3], ios::out);
        treeout.close();
        treeout.open(argv[3], ios::app);
    }


    yyin = input;
    table = new SymbolTable(11,0);

    yyparse(); 
    //string lTreeVertexTables=table ->printAllScopeTableForLogFile();
      //printlog<<lTreeVertexTables<<endl;
    printlog << "Total Lines: " << yylineno << endl;
    printlog << "Total Errors: " << total_errors << endl;

    fclose(yyin);
    printlog.close();
    errorout.close();
	treeout.close();

    return 0;
}

