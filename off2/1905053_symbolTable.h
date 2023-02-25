#include<bits/stdc++.h>
#include<stdlib.h>
#include<string>
#include<algorithm>
#include <fstream>
#include <iostream>
#include <fstream>



using namespace std;
ofstream ofile;


class SymbolInfo
{
   private:

       string name;
       string type;
       SymbolInfo* nextSymbol;

    public:

     SymbolInfo()
     {

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
             ofile << "	'" << name << "'" << " already exists in the current ScopeTable"<<'\n';
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

                ofile<<"	Inserted in ScopeTable# "<< getID()<< " at position " << index+1 <<", 1\n";

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
            ofile<<"	Inserted in ScopeTable# "<< getID()<< " at position " << index+1 << ", " << pos<<'\n';
                 return true;




            }


        }
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

             ofile<<"	'"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos<<'\n';
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
                     ofile<<"	'"<<name<<"'"<<" found in ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos<<'\n';
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
                ofile << "	Deleted " <<"'"<<name<<"'"<<" from ScopeTable# "<< getID()<<" at position " << index+1 << ", " << pos <<'\n';
                return true;
        }
       //no such entry
       ofile<<"	Not found in the current ScopeTable"<<'\n';
        return false;

    }


    void print()
    {
      //index--> <name,type><name,type>...
        SymbolInfo* list = nullptr;

       for (int i = 0; i < bucketNum; i++)
       {
           ofile<<"	"<<i+1<<"--> ";
           list= arr[i];
           while(list!=nullptr)
           {
               ofile<<"<" <<list->getName()<< ","<<list->getType()<<"> ";
               list=list->getNextSymbol();
           }
           ofile<<'\n';
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
               //cout<<" < " <<listPrint->getName()<< " , "<<listPrint->getType()<<" >";
               str.append("<");
               str.append(listPrint->getName());
               str.append(",");
               str.append(listPrint->getType());
               str.append("> ");

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
             ofile << "	ScopeTable# " << ct<< " created\n";


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

             ofile << "	ScopeTable# " <<ct << " created\n";



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
                     ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" cannot be removed"<<'\n';
                     return;
                }
         ScopeTable* temp= current_scopeTable->getParentScope();
         ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" removed"<<'\n';
         delete current_scopeTable;
         current_scopeTable=temp;
     }

     void ExitFromAllScope()
     {
         while(current_scopeTable!=nullptr)
         {    ScopeTable* temp= current_scopeTable->getParentScope();
              ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<" removed"<<'\n';
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
        ofile<<"	'"<<name<<"'"<<" not found in any of the ScopeTables"<<'\n';
         return nullptr;

     }
      bool Insert(string name, string type)
     {
         bool isSuccessful= false;
         isSuccessful= current_scopeTable->Insert(name,type);

         return isSuccessful;

     }

       bool Remove(string name)
    {
        bool isSuccessful= current_scopeTable->Delete(name);
        return isSuccessful;
    }

    void printCurrentScopeTable()

     {  ofile<<"	ScopeTable# "<<current_scopeTable->getID()<<'\n';
         current_scopeTable->print();
     }

    void printAllScopeTable()
     {
         ScopeTable *currTab= current_scopeTable;
         while(currTab!=nullptr)
            {    ofile<<"	ScopeTable# "<<currTab->getID()<<'\n';
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
