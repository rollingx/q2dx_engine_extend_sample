#ifndef __LWINPROC_H__
#define __LWINPROC_H__

#include "app.h"

class LWinProc
{
public:
    static int execute(UINT message, WPARAM wParam, LPARAM lParam);
};

#endif // __LWINPROC_H__