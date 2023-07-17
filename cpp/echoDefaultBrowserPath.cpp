
#include<shlwapi.h>
#include<tchar.h>
#include<iostream>

#define assoc(buffer, sizep) ::AssocQueryString(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, ext, NULL,buffer,sizep);
const char* ext = ".html";

int main(){
    DWORD size = 0;
    // first, get required buffer size into `size`
	HRESULT hr = assoc(NULL, &size)
	// assert(hr == S_FALSE);
	
    char * buffer = new char[size];
    hr = assoc(buffer,&size);
    if(hr==S_OK){
        std::cout<<buffer<<std::endl;
    }else{
        std::cerr<<"failed somehow"<<std::endl;
    }
    delete[]buffer;
	
}