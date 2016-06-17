
#include "lj_arch.h"

LUALIB_API int luaS_needarm64fix()
{
#if LJ_GC64
	return 1;
#else
	return 0;
#endif
}
