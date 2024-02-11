
#include<stdlib.h>
#include<Windows.h>
#include<shlwapi.h>

#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "Shell32.lib")

#define F_ASSOC ASSOCF_NONE //ASSOCF_NOFIXUPS|ASSOCF_VERIFY
#define assoc(buffer, sizep) AssocQueryStringW(F_ASSOC, ASSOCSTR_EXECUTABLE, \
    L"http", L"open", (buffer), (sizep));
DWORD getDefaultBrowser(LPWSTR* pOut){
    DWORD size = 0;
    assoc(NULL, &size); // get required buffer size, returns S_FALSE
    *pOut = (LPWSTR)malloc(size * sizeof(WCHAR));
    HRESULT hr = assoc(*pOut,&size); // assert(hr==S_OK);
    return size;
    // remember `free(pOut);`
}
int main(){
    //Get default web browser path
    LPWSTR browserPath;
    DWORD len = getDefaultBrowser(&browserPath); 
    if(len == 0) return -1;

    ShellExecuteW(NULL, L"open", browserPath, L"about:blank", NULL, SW_SHOW);

    free(browserPath);
}
