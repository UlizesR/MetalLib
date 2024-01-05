#ifndef _M_DEFS_H_
#define _M_DEFS_H_

#ifdef __cplusplus
extern "C" {
#endif

#define MAPI __attribute__((visibility("default")))

typedef struct MWindow MWindow;
typedef struct MView MView;

typedef char MBool;

#define MTrue 1
#define MFalse 0

#ifdef __cplusplus
}
#endif

#endif // _M_DEFS_H_