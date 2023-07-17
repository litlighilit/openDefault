
#include<Windows.h>
#include<shlwapi.h>

int main(){
//Get default web browser path

char wbuffPath[MAX_PATH] = {0};
DWORD dwszBuffPath;// = MAX_PATH;
AssocQueryStringA(0, ASSOCSTR_EXECUTABLE, "http", "open", wbuffPath, &dwszBuffPath);


}
