
#include<shlwapi.h>

#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "Shell32.lib")

#define F_ASSOC ASSOCF_NONE // ASSOCF_NOFIXUPS|ASSOCF_VERIFY
#define assoc(buffer, sizep) ::AssocQueryStringW(F_ASSOC,\
  ASSOCSTR_EXECUTABLE, L".html", NULL, (buffer), (sizep))

DWORD getDefaultBrowser(LPWSTR &pszPath){
    DWORD size = 0;
    assoc(NULL, &size); // get required buffer size, returns S_FALSE
    pszPath = new WCHAR[size];
    HRESULT hr = assoc(pszPath,&size); // assert(hr==S_OK);
    return size;
    // remember `delete[]pszPath;`
}

int main(){
    LPWSTR browserPath;
    DWORD len = getDefaultBrowser(browserPath);
    if (len == 0)return -1;

    ShellExecuteW(NULL, L"open", browserPath, L"about:blank", NULL, SW_SHOW);

    delete[] browserPath;
}