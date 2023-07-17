
#include<shlwapi.h>
#include<stdlib.h>

#define assoc(buffer, sizep) AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, ext, NULL,buffer,sizep);
extern "C"{
#define presp(static_str) " " static_str
const char* ext = ".html";
}

DWORD getDefaultBrowser(char* &nullbuffer){
    DWORD size = 0;
    // first, get required buffer size into `size`
	HRESULT hr = assoc(NULL, &size)
	// assert(hr == S_FALSE);
	
    nullbuffer = new char[size];
    hr = assoc(nullbuffer,&size);

    // assert(hr==S_OK);
    return size;
    // remember `delete[]nullbuffer;`
	
}
char* quotedArg(const char* arg){
    size_t len = 2 + strlen(arg);
    char* res = new char[len];
    res[0] = '"';
    strcpy(res+1, arg);
    res[len-1] = '"';
    return res;
}
int main(){
    char* path;
    DWORD size = getDefaultBrowser(path);
    if (size == 0)return -1;

    const char* qpath = quotedArg(path);
    delete[] path;
    size += 2;

    const char* arg = presp("about:blank");

    char* cmd = new char[size + strlen(arg) + 1];
    strcpy(cmd, qpath);
    strcat(cmd, arg);

    system(cmd);

    delete[] qpath;
    delete[] cmd;
}