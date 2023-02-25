#ifndef __TreeVertex_H__
#define __TreeVertex_H__

#include<iostream>
#include<string>
#include<vector>
#include"sym.h"

using namespace std;

class TreeVertex
{
private:
    int start, end;
    SymbolInfo *s;
    string info;    

    vector<TreeVertex *> child;
public:
    string name;
    string type;
    bool leaf=false;

    TreeVertex(string info, int start, int end,bool leaf=false)
        : info(info), start(start), end(end),leaf(leaf)
    {
        s = nullptr;
    }

    TreeVertex( SymbolInfo *si, string info, int start,bool leaf=false)
        : info(info), start(start), end(start) ,leaf(leaf)
    {
        //s = new SymbolInfo(si->name, si->type, si->returnType, si->variableType, si->parameterList , si->isDefined,si->argumentList);
        s=si;
        name = si->name;
        type = si->type;
    
    }

    TreeVertex( SymbolInfo *si, string info, int start, int end,bool leaf=false)
        :  info(info), start(start), end(end),leaf(leaf)
    {
        //s = new SymbolInfo(si->name, si->type, si->returnType, si->variableType, si->parameterList , si->isDefined,si->argumentList);
        s=si;
        name = si->name;
        type = si->type;
     
    }

    void addChild(TreeVertex * nod){
        end = nod->getEnd();
        child.push_back(nod);
    }

    void print(ostream &os, int space,bool f=false){
        for(int i = 0; i < space; i++) os << " ";
        if(f==true)
        os << info << "	<Line: " << start << ">" <<endl;
        else
        os << info << " 	<Line: " << start << "-" << end << ">" << endl;  // 	<Line: 1-23>
        for(auto i: child){
            if (i->leaf== true)
            i->print(os, space+1,true);
            else
            i->print(os, space+1);

        }
    }

    int getStart(){ return start;}
    int getEnd(){ return end;}
    string getName(){
        return s->getName();
    }
    string getType(){
        return s->getType();
    }


    SymbolInfo* getSymbol(){ return s;}

    vector<TreeVertex *> getChild(){
        return child;
    }

    ~TreeVertex(){
        
    }
};


#endif