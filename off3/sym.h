#ifndef __SYM_H__
#define __SYM_H__

#include<bits/stdc++.h>
#include<stdlib.h>
#include<cstring>
#include<string>
#include<algorithm>





using namespace std;



class parameter
{
        private:

            string name, type;

        public:
            parameter(string name, string type)
            {
                this->name= name;
                this->type=type;
            }
            string getName()
            {
                return this->name;
            }

            string getType()
            {
                return this->type;
            }
            
};


class DefineFunction
{
    private:
        string name;
        string returntype;
        
        bool hasParameter;
        vector<parameter> parameterList;


    public:
        DefineFunction()
        {

        }
        DefineFunction(string n, string t, vector<parameter> p)
        {

            name=n;
            returntype=t;
            parameterList= p;
            hasParameter=true;
        }


           DefineFunction(string n, string t, vector<parameter> paralist,bool p)
        {

            name=n;
            returntype=t;
            parameterList= paralist;
            hasParameter=p;
        }

    vector<parameter> getParameterList()
    {
        return parameterList;
    }

  string getName()
    {
        return name;
    }

   string getReturnType()
    {
        return returntype;
    }
   
 

      bool ContainsParameter()
    {
       return this->hasParameter;
    }
};


class SymbolInfo
{
   public:

       string name;
       string type;
       SymbolInfo* nextSymbol;
       int size;
       bool isDefined;
        vector<parameter> parameterType;
        string variableType,returnType;
        vector<string> parameterList;
        vector<string> argumentList;

        

    

     SymbolInfo()
     {
        
            this->name = "";
            this->type = "";
            this->nextSymbol = nullptr;
            this->size=0;
            this->isDefined = false;


     }

     SymbolInfo(string name, string type) {
            this->name = name;
            this->type = type;
            this->nextSymbol = nullptr;
            this->size=0;
            this->isDefined = false;
            
        }

         SymbolInfo(string name, string type,int size) {
            this->name = name;
            this->type = type;
            this->nextSymbol = nullptr;
            this->size=size;
            this->isDefined = false;
            
        }

         SymbolInfo(string name, string type,string ret) {
            this->name = name;
            this->type = type;
            this->returnType= ret;
            this->isDefined= false;
             this->nextSymbol = nullptr;
        }

        SymbolInfo(string name, string type,string ret,string varType) {
            this->name = name;
            this->type = type;
            this->returnType= ret;
            this->variableType=varType;
            this->isDefined= false;
             this->nextSymbol = nullptr;
            
        }

        SymbolInfo(string name, string type,string ret,string varType,vector<string>paraList) {
            this->name = name;
            this->type = type;
            this->returnType= ret;
            this->variableType=varType;
            this->isDefined= false;
            this->parameterList=paraList;
             this->nextSymbol = nullptr;
        }

        SymbolInfo(string name, string type,string ret,string varType,vector<string>paraList,bool d) {
            this->name = name;
            this->type = type;
            this->returnType= ret;
            this->variableType=varType;
            this->isDefined= d;
            this->parameterList=paraList;
             this->nextSymbol = nullptr;
        }

        SymbolInfo(string name, string type,string ret,string varType,vector<string>paraList,bool d,vector<string>argl) {
            this->name = name;
            this->type = type;
            this->returnType= ret;
            this->variableType=varType;
            this->isDefined= d;
            this->parameterList=paraList;
             this->nextSymbol = nullptr;
             this->argumentList=argl;
        }

        SymbolInfo(string name) {
            this->name = name;
            //this->type = type;
            this->nextSymbol = nullptr;
            this->size=0;
            this->isDefined = false;
            
        }

     void setName(string name)
     {
        this->name=name;
     }

     string getName()
     {
        return this->name;
     }


     void setType(string type)
     {
        this->type=type;
     }

     string getType()
     {
        return this->type;
     }

     void setNextSymbol(SymbolInfo* sy)
     {
        this->nextSymbol=sy;
     }

     SymbolInfo* getNextSymbol()
     {
        return this->nextSymbol;
     }

    void setIsDefined(bool d)
    {
            this->isDefined=d;
    }    

    bool getIsDefined()
        {
            return this->isDefined;
        }


    void setReturnType(string returnType){
        this->returnType = returnType;
    }

    string getReturnType(){
        return this->returnType;
    }
     

    void setVariableType(string variable_type){
        this->variableType = variable_type;
    }


    string getVariableType()
    {
        return this->variableType;
    }

    
    vector <string> getParameterList()
    {
            return this->parameterList;
    }


    int getParameterSize()
    {
            return parameterType.size();
    }


    void setParameterType(parameter pt)
    {
        this->parameterType.push_back(pt);
    }

    parameter getParameter(int x)
    {
        return parameterType.at(x);
    }

    int getSize()
    {
        return this->size;
    }

     ~SymbolInfo()
     {

     }
};


class ScopeTable


{

  private:
      SymbolInfo** arr;
      ScopeTable* parent_scope;
      int bucketNum;
      int scopeCount;
      string id;

  public:
    ScopeTable(int num,int ct)

    {
     bucketNum=num;
     arr=new SymbolInfo*[bucketNum];

     for(int i=0;i<bucketNum;i++)
     {
         arr[i]=nullptr;
     }
     parent_scope=nullptr;
      scopeCount=ct;
    }


 void SetId(int ID)
    {
        this->id= to_string(ID);
    }


 string getID(){
    if(this->parent_scope == nullptr)
        return to_string(1);
    return this->id;
 }

 void SetId(){
    this->id =to_string(scopeCount);
 } 
     void setParentScope(ScopeTable* ps)
    {
        if(ps== nullptr)
            this->parent_scope= nullptr;
        else
            this->parent_scope= ps;
    }

    ScopeTable* getParentScope()
    {
        return this->parent_scope;
    }

    void setNumberOfBuckets(int num)
    {
        this->bucketNum= num;
    }

    int getNumberOfBuckets()
    {
        return this->bucketNum;
    }

    void SetScopeCount()
    {
        this->scopeCount++;
    }

    int GetScopeCount()
    {
        return this->scopeCount;
    }


    static unsigned long long SDBMHash(string str) {
	unsigned long long hash = 0;
	unsigned int i = 0;
	unsigned int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
    }


  bool Insert(string name,string type)
    {

        SymbolInfo* node= LookUpHelp(name);
        //already exists
        if(node!=nullptr)
        {
             //ofile << "	'" << name << "'" << " already exists in the current ScopeTable"<<'\n';
             return false;

        }

        else
        {
            SymbolInfo* temp = new SymbolInfo ;
            int index= SDBMHash(name) % bucketNum;
            SymbolInfo* curr= arr[index];
            temp->setName(name);
            temp->setType(type);
            temp->setNextSymbol(nullptr);

           //that index is empty..no need for chaining
            if(curr==nullptr)
            {
                arr[index]= temp;

                //ofile<<"	Inserted in ScopeTable# "<< getID()<< " at position " << index+1 <<", 1\n";

                return true;
            }

            //need to chain
            else
            {
                SymbolInfo* next= curr->getNextSymbol();
                int pos=2;

                while(next!=nullptr)
                {
                    curr=next;
                    next= next->getNextSymbol();
                    pos++;
                    //cout<<"insert er vitore position "<<pos<<endl;

                }
                next= temp;
                curr->setNextSymbol(next);
            //successful chaining
            //ofile<<"	Inserted in ScopeTable# "<< getID()<< " at position " << index+1 << ", " << pos<<'\n';
                 return true;




            }


        }
        return false;


    }


      bool Insert2(string name, string type="", string returnType = "", string variableType = "", vector<string>param = vector<string>(), bool Defined = false)
    {
        int index= SDBMHash(name) % bucketNum;

        SymbolInfo* node = new SymbolInfo(name,type,returnType, variableType, param, Defined);

        int c=0;

        if (arr[index] == NULL )
        {
            arr[index] = node;
            return true;
        }

        else if(arr[index] != NULL )
        {
            SymbolInfo* cur = arr[index];
            while (cur->getNextSymbol() != NULL && cur->name!=name)
            {
                cur = cur->getNextSymbol() ;
                c++;
            }

            if(cur->name!=name)
            {
                c++;
                cur->setNextSymbol(node);


                return true;
            }


        }

        delete node;
        return false;
    }



     SymbolInfo* LookUp(string name)
    {
        int index= SDBMHash(name) % bucketNum;
        int pos=1;

        SymbolInfo* item = arr[index];

   //no entry in that index
        if(item==nullptr)
        {
            return nullptr;
        }
        if(item->getName()==name)
         {

             //ofile<<"	'"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos<<'\n';
            return item;
         }
         //search in the chain
        else
        {

            SymbolInfo * nextNode= item->getNextSymbol();
            while(nextNode!=nullptr)
            {
               pos++;
                if(nextNode->getName()==name)
                {
                     //ofile<<"	'"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos<<'\n';
                    return nextNode;}

                nextNode = nextNode->getNextSymbol();

            }
        }
        //not found in chain
        return nullptr;

    }


    //helper function for insert
      SymbolInfo* LookUpHelp(string name)
    {
        int index= SDBMHash(name) % bucketNum;
        int pos=1;

        SymbolInfo* item = arr[index];

       //no entry in that index
        if(item==nullptr)
        {
            return nullptr;
        }
        if(item->getName()==name)
         {

             //ofile<<"        '"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << "," << pos<<'\n';
            return item;
         }
         //search in the chain
        else
        {

            SymbolInfo * nextNode= item->getNextSymbol();
            while(nextNode!=nullptr)
            {
               pos++;
                if(nextNode->getName()==name)
                {
                     //ofile<<"        '"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << "," << pos<<'\n';
                    return nextNode;}

                nextNode = nextNode->getNextSymbol();

            }
        }
        //not found in chain
        return nullptr;

         }



     int searchIndex(string name)
       { 

        int index= SDBMHash(name)% bucketNum;
        int pos=1;

        SymbolInfo* item = this->arr[index];
        //no item in such index
        if(item==nullptr)
        {

            return -1;
        }

        else
        {
           // int pos=0;
            SymbolInfo * nextNode= item;
            while(nextNode!=nullptr)
            {

                if(nextNode->getName()==name){
                   return pos;
                }
                nextNode = nextNode->getNextSymbol();
                pos++;
            }
        }
        return pos;

    }


    bool Delete(string name)
    {
        int index= SDBMHash(name)%bucketNum;
        int position=1;
        SymbolInfo* foundNode= LookUpHelp(name);
        int pos= searchIndex(name);

        if(foundNode!=nullptr)
        {
            //deletion
             if(arr[index]->getNextSymbol() != nullptr){
                    arr[index] = arr[index]->getNextSymbol();
                }

            else{
                    arr[index] = nullptr;
                }
                //ofile << "	Deleted " <<"'"<<name<<"'"<<" from ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos <<'\n';
                return true;
        }
       //no such entry
       //ofile<<"	Not found in the current ScopeTable"<<'\n';
        return false;

    }


    void print()
    {
      //index--> <name,type><name,type>...
        SymbolInfo* list = nullptr;

       for (int i = 0; i < bucketNum; i++)
       {
           //ofile<<"	"<<i+1<<"--> ";
           list= arr[i];
           while(list!=nullptr)
           {
               //ofile<<"<" <<list->getName()<< ","<<list->getType()<<"> ";
               list=list->getNextSymbol();
           }
           //ofile<<'\n';
       }


    }

    string printForLogFile()
    {

        string str="";
        SymbolInfo* listPrint = nullptr;
        str.append("	ScopeTable# ");
        str+=getID();
        str+='\n';
       int i;
       int j=-1;
       for ( i = 0; i < bucketNum; i++)
       {

           if(arr[i]!=NULL)
           {
            str.append("	");
            str.append(to_string(i+1));
            str.append("--> ");

           listPrint= arr[i];
           while(listPrint!=nullptr)

           {    j=i;
             string var=listPrint->variableType;
               //cout<<" < " <<listPrint->getName()<< " , "<<listPrint->getType()<<" >";
               if(var=="array"||var=="function")
               {
                 str.append("<");
               str.append(listPrint->getName());
               str.append(", ");
               string str1=listPrint->variableType;
               for (int i = 0; i < str1.size(); i++) 
               str1.at(i)= toupper(str1.at(i));
               str.append(str1);
               str.append(", ");
               string str2=listPrint->returnType;
               for (int i = 0; i < str2.size(); i++) 
               str2.at(i)= toupper(str2.at(i));
               str.append(str2);
               
               str.append("> ");
               }
               else{
               str.append("<");
               str.append(listPrint->getName());
               str.append(", ");
               string str2=listPrint->returnType;
               for (int i = 0; i < str2.size(); i++) 
               str2.at(i)= toupper(str2.at(i));
               str.append(str2);
               str.append("> ");}

               listPrint=listPrint->getNextSymbol();
           }
           
           str+='\n';
       }
       }
       
       return str;


    };

    ~ScopeTable()
    {

        for (int i = 0; i < bucketNum; i++)
        {

            delete arr[i];
        }
        delete[] arr;


    }





};


class SymbolTable
{

   private:
       ScopeTable* current_scopeTable;
       int n;//scope table  er bucketnum
       int ct;//count

       public:
    SymbolTable(int n,int ct)
    {
        current_scopeTable=nullptr;
        this->n=n;
        this->ct=ct;

        EnterScope();
    }
 void EnterScope()
     {    ct++;
         ScopeTable* latestScopeTable= new ScopeTable(n,ct);
         ScopeTable *currTab= current_scopeTable;
         //cout<<"enter scope er shuru te "<<current_scopeTable->getID()<<endl;
        if(current_scopeTable==nullptr)
        {
            current_scopeTable=latestScopeTable;
            current_scopeTable->setParentScope(nullptr);
            //current_scopeTable->SetScopeCount();

            current_scopeTable->SetId(1);
             //ofile << "	ScopeTable# " << ct<< " created\n";


        }
        else
        {    //cout<<"enter scope er shuru te "<<current_scopeTable->getID()<<endl;
              //cout<<"current scope "<< current_scopeTable->getID() <<endl;
              //string s=currTab->getID();
            latestScopeTable->setParentScope(current_scopeTable);
            current_scopeTable= latestScopeTable;
            current_scopeTable->getParentScope()->SetScopeCount();
            current_scopeTable->SetId();

            //int x=stoi(s);
            //x++;

            //cout<<"ekhon current scope "<< current_scopeTable->getID() <<endl;

            // ofile << "	ScopeTable# " <<ct << " created\n";



        }

     }

      void ExitScope()
     {
         if(current_scopeTable==nullptr)

            {


                return;
                }
                if(current_scopeTable->getID()=="1")
                {
                     //ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" cannot be removed"<<'\n';
                     return;
                }
         ScopeTable* temp= current_scopeTable->getParentScope();
        // ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" removed"<<'\n';
         delete current_scopeTable;
         current_scopeTable=temp;
     }

     void ExitFromAllScope()
     {
         while(current_scopeTable!=nullptr)
         {    ScopeTable* temp= current_scopeTable->getParentScope();
              //ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" removed"<<'\n';
              delete current_scopeTable;
              current_scopeTable=temp;

         }
     }


    //first e current scope table e khujbe..na paile er parent table e jabe
     SymbolInfo* Lookup(string name)
     {
         ScopeTable *currTable= current_scopeTable;
          SymbolInfo * node;
         while(currTable!=nullptr)
         {

            node= currTable->LookUp(name);
            if(node!=nullptr){
                return node;
            }
            currTable= currTable->getParentScope();
         }
        //ofile<<"	'"<<name<<"'"<<" not found in any of the ScopeTables"<<'\n';
         return nullptr;

     }

     SymbolInfo* LookupInScope(string name)
    {
        return ((current_scopeTable == NULL )? NULL : current_scopeTable -> LookUp(name));
    }

      bool Insert(string name, string type)
     {
         bool isSuccessful= false;
         isSuccessful= current_scopeTable->Insert(name,type);

         return isSuccessful;

     }


bool Insert2(string name, string type="", string returnType = "", string variableType = "", vector<string>param = vector<string>(), bool Defined = false)
    {

        if(current_scopeTable==NULL)
            EnterScope();

        if(current_scopeTable->Insert2(name, type, returnType, variableType, param, Defined))
        {
            return true;

            }


        return false;
    }



       bool Remove(string name)
    {
        bool isSuccessful= current_scopeTable->Delete(name);
        return isSuccessful;
    }

    void printCurrentScopeTable()

     {  //ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<'\n';
         current_scopeTable->print();
     }

    void printAllScopeTable()
     {
         ScopeTable *currTab= current_scopeTable;
         while(currTab!=nullptr)
            {    //ofile<<"	ScopeTable# "<<currTab->getID()<<'\n';
                currTab->print();

                currTab= currTab->getParentScope();
            }
     }


      string printAllScopeTableForLogFile()
     {
        
         string printAll="";
         
          ScopeTable *currTab= current_scopeTable;
           while(currTab!=nullptr)
            {    
                printAll+=currTab->printForLogFile();
                //printAll+='\n';
                currTab= currTab->getParentScope();   
     }
     return printAll;
     }

     ScopeTable * getCurrentScopeTable()
    {
        return this->current_scopeTable;
    }

   ~SymbolTable()
    {


    }




};

#endif