#ifndef MAC_ERROR_H_
#define MAC_ERROR_H_


#ifdef __cplusplus
extern "C" {
#endif

typedef enum 
{
    MAC_ERROR_INIZIALIZATION_FAILED = -1,
    MAC_ERROR_WINDOW_CREATION_FAILED,
    MAC_ERROR_WINDOW_NOT_FOUND,
} MAC_Error;


void mac_error_message(MAC_Error error);

#ifdef __cplusplus
}
#endif

#endif // MAC_ERROR_H_